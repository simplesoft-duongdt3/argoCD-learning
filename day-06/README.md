# 📅 Ngày 6: Quản Lý Nhiều Cluster (Multi-cluster)

## 🎯 Mục tiêu hôm nay
- Hiểu kiến trúc Hub-and-Spoke của ArgoCD
- Add một cluster bên ngoài vào ArgoCD
- Deploy ứng dụng từ Cluster A sang Cluster B

---

## 📖 Lý thuyết

### Kiến trúc Hub-and-Spoke

```
┌────────────────────────────────────────────────────────┐
│                  HUB-AND-SPOKE MODEL                   │
│                                                        │
│         ┌─────────────────────┐                        │
│         │   HUB CLUSTER       │                        │
│         │   (ArgoCD Server)   │                        │
│         │                     │                        │
│         │  📋 Manage all apps │                        │
│         │  🔍 Monitor state   │                        │
│         │  🔄 Sync changes    │                        │
│         └──────┬──────────────┘                        │
│                │                                       │
│       ┌────────┼────────┐                              │
│       ▼        ▼        ▼                              │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐                  │
│  │ Spoke 1 │ │ Spoke 2 │ │ Spoke 3 │                  │
│  │ (Dev)   │ │ (Stage) │ │ (Prod)  │                  │
│  │         │ │         │ │         │                  │
│  │ 🔧 Apps │ │ 🔧 Apps │ │ 🔧 Apps │                  │
│  └─────────┘ └─────────┘ └─────────┘                  │
│                                                        │
│  ArgoCD chỉ cần cài trên HUB cluster                  │
│  Spoke clusters không cần cài ArgoCD                   │
└────────────────────────────────────────────────────────┘
```

### Cách ArgoCD quản lý nhiều cluster

1. **In-cluster (mặc định)**: ArgoCD tự biết cluster mà nó đang chạy
2. **External cluster**: ArgoCD dùng **kubeconfig/ServiceAccount** để kết nối cluster khác
3. ArgoCD tạo một **ServiceAccount** trên cluster remote với quyền quản lý resources

### Yêu cầu tài nguyên

| Số lượng Clusters | CPU | Memory | Lưu ý |
|-------------------|-----|--------|-------|
| 1-5 | 2 core | 4 GB | Mặc định |
| 5-50 | 4 core | 8 GB | Nên dùng HA mode |
| 50+ | 8+ core | 16+ GB | Cần Sharding |

---

## 🔧 Thực hành

### Bước 1: Tạo 2 Minikube clusters

```bash
# Chạy script tự động
chmod +x scripts/setup-multi-cluster.sh
./scripts/setup-multi-cluster.sh
```

Hoặc thực hiện thủ công:
```bash
# Cluster 1: Hub (ArgoCD chạy ở đây)
minikube start --profile hub-cluster --cpus=4 --memory=8192 --driver=docker

# Cluster 2: Spoke (cluster được quản lý)
minikube start --profile spoke-cluster --cpus=2 --memory=4096 --driver=docker

# Kiểm tra
kubectl config get-contexts
# → Phải thấy 2 contexts: hub-cluster và spoke-cluster
```

### Bước 2: Cài ArgoCD trên Hub cluster

```bash
# Chuyển sang Hub cluster
kubectl config use-context hub-cluster

# Cài ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Port-forward
kubectl port-forward svc/argocd-server -n argocd 8080:443 &
```

### Bước 3: Add Spoke cluster vào ArgoCD

```bash
# Chạy script
chmod +x scripts/add-cluster.sh
./scripts/add-cluster.sh
```

Hoặc thủ công:
```bash
# ArgoCD CLI login
ADMIN_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
argocd login localhost:8080 --username admin --password "$ADMIN_PASS" --insecure

# Add spoke cluster
argocd cluster add spoke-cluster --name spoke-cluster

# Kiểm tra
argocd cluster list
# → Phải thấy 2 clusters
```

### Bước 4: Deploy ứng dụng lên Spoke cluster

```bash
# Tạo Application deploy lên spoke cluster
kubectl apply -f argocd/app-remote-cluster.yaml

# Sync
argocd app sync nginx-on-spoke

# Kiểm tra trên spoke cluster
kubectl config use-context spoke-cluster
kubectl get pods -n remote-demo
kubectl get svc -n remote-demo

# Quay lại hub cluster
kubectl config use-context hub-cluster
```

---

## ❓ FAQ

### Q: ArgoCD tốn bao nhiêu tài nguyên khi quản lý hàng trăm cluster?
**A:** ArgoCD khá nhẹ! Mỗi cluster thêm khoảng **50-100MB RAM**. Với hàng trăm clusters, bạn nên:
- Bật **HA mode** (3 replicas cho API Server)
- Dùng **Controller Sharding** để phân tải
- Tăng Redis cache

### Q: Nếu mất kết nối tới spoke cluster thì sao?
**A:** ArgoCD sẽ đánh dấu application là **Unknown** status. Khi kết nối được khôi phục, ArgoCD tự reconcile và sync lại.

### Q: Có thể dùng ArgoCD trên EKS/GKE/AKS không?
**A:** Có! ArgoCD hỗ trợ mọi Kubernetes cluster miễn là có kubeconfig hoặc ServiceAccount token hợp lệ.

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 05 — Kustomize](../day-05/)
> **⏭️ Ngày tiếp:** [Day 07 — App of Apps Pattern](../day-07/)

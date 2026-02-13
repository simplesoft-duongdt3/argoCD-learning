# 📅 Ngày 1: Nhập Môn GitOps & Cài Đặt ArgoCD

## 🎯 Mục tiêu hôm nay
- Hiểu GitOps là gì và tại sao nó quan trọng
- Cài đặt ArgoCD lên Kubernetes cluster
- Login vào ArgoCD UI & CLI

---

## 📖 Lý thuyết

### GitOps là gì?

**GitOps** là phương pháp triển khai ứng dụng sử dụng **Git làm nguồn sự thật duy nhất** (single source of truth). Mọi thay đổi trên hệ thống production đều phải đi qua Git.

### So sánh: Cách truyền thống vs GitOps

```
┌─────────────────────────────────────────────────────────────┐
│                    CÁCH TRUYỀN THỐNG (Push-based)           │
│                                                             │
│  Developer → CI Pipeline → kubectl apply → K8s Cluster     │
│                                                             │
│  ❌ Ai cũng có thể "kubectl apply" trực tiếp               │
│  ❌ Không biết trạng thái thực sự trên cluster              │
│  ❌ Không có audit trail                                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    GITOPS (Pull-based)                      │
│                                                             │
│  Developer → Git Commit → ArgoCD (Pull) → K8s Cluster      │
│                                                             │
│  ✅ Git là single source of truth                           │
│  ✅ ArgoCD tự detect drift và sửa chữa                     │
│  ✅ Mọi thay đổi đều có audit trail trong Git               │
└─────────────────────────────────────────────────────────────┘
```

### ArgoCD là gì?

ArgoCD là một **Continuous Delivery tool** cho Kubernetes, hoạt động theo mô hình **Pull-based GitOps**:

1. **Khai báo** trạng thái mong muốn trong Git (YAML/Helm/Kustomize)
2. ArgoCD **theo dõi** Git repo liên tục
3. ArgoCD **so sánh** trạng thái Git với trạng thái thực tế trên cluster
4. ArgoCD **đồng bộ** (sync) nếu phát hiện khác biệt

### Kiến trúc ArgoCD

```
┌──────────────────────────────────────────────────────┐
│                    ArgoCD Server                      │
│                                                      │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ API      │  │ Repository   │  │ Application   │  │
│  │ Server   │  │ Server       │  │ Controller    │  │
│  │          │  │              │  │               │  │
│  │ (UI+API) │  │ (Clone Git)  │  │ (Sync/Diff)  │  │
│  └──────────┘  └──────────────┘  └───────────────┘  │
│                                                      │
│  ┌──────────────────┐  ┌──────────────────────────┐  │
│  │ Redis            │  │ Dex (SSO)                │  │
│  │ (Cache)          │  │ (Authentication)         │  │
│  └──────────────────┘  └──────────────────────────┘  │
└──────────────────────────────────────────────────────┘
```

---

## 🔧 Thực hành: Cài đặt ArgoCD

### Cách 1: Cài bằng Manifest (Khuyến nghị cho người mới)

```bash
# Bước 1: Tạo namespace
kubectl create namespace argocd

# Bước 2: Cài đặt ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Bước 3: Chờ tất cả Pod sẵn sàng (~2-3 phút)
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

# Bước 4: Kiểm tra
kubectl get pods -n argocd
```

### Cách 2: Cài bằng Helm

```bash
# Bước 1: Thêm Helm repo
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Bước 2: Cài đặt
helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --set server.service.type=NodePort

# Bước 3: Kiểm tra
kubectl get pods -n argocd
```

### Truy cập ArgoCD UI

```bash
# Port-forward để truy cập UI
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Mở trình duyệt: https://localhost:8080
# Username: admin
# Password: lấy bằng lệnh dưới đây

# Lấy password admin
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### Cài ArgoCD CLI

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd-linux-amd64 \
  https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Login qua CLI
argocd login localhost:8080 --username admin --password <YOUR_PASSWORD> --insecure
```

---

## ❓ FAQ

### Q: ArgoCD có thay thế Jenkins/GitLab CI không?
**A:** Không! ArgoCD chỉ lo phần **CD** (Continuous Delivery). Bạn vẫn cần Jenkins/GitLab CI cho phần **CI** (build, test, push image). Flow đầy đủ:

```
CI (Jenkins/GitLab)              CD (ArgoCD)
─────────────────               ──────────────
Build → Test → Push Image   →   Git commit YAML → ArgoCD Sync → K8s
```

### Q: ArgoCD khác gì Flux?
**A:** Cả hai đều là GitOps tool, nhưng ArgoCD có **UI mạnh mẽ**, dễ dùng hơn cho team lớn. Flux nhẹ hơn và "Kubernetes-native" hơn.

### Q: ArgoCD có chạy được trên Minikube không?
**A:** Có! ArgoCD cần khoảng **2 CPU + 4GB RAM**. Hãy đảm bảo Minikube có đủ tài nguyên.

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

## 🧹 Cleanup

```bash
# Nếu muốn xóa ArgoCD (KHÔNG nên xóa nếu còn tiếp tục khóa học)
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl delete namespace argocd
```

---

> **⏭️ Ngày tiếp theo:** [Day 02 — Kết nối Repository & Ứng dụng đầu tiên](../day-02/)

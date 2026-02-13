# ✏️ Bài tập Ngày 6: Multi-cluster Deployment

## 🎯 Mục tiêu
- Setup 2 Minikube clusters (Hub + Spoke)
- Add Spoke cluster vào ArgoCD
- Deploy ứng dụng cross-cluster

---

## Bài tập 1: Setup Multi-cluster

1. Chạy script setup:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/setup-multi-cluster.sh
   ```

2. Kiểm tra 2 clusters đang chạy:
   ```bash
   kubectl config get-contexts
   minikube status --profile hub-cluster
   minikube status --profile spoke-cluster
   ```

---

## Bài tập 2: Add Spoke Cluster

1. Chạy script:
   ```bash
   ./scripts/add-cluster.sh
   ```

2. Kiểm tra cluster đã được add:
   ```bash
   argocd cluster list
   ```
   
   **Mong đợi:** 2 clusters (in-cluster + spoke-cluster)

---

## Bài tập 3: Cross-cluster Deployment

1. Sửa file `argocd/app-remote-cluster.yaml`:
   - Thay `<SPOKE_CLUSTER_SERVER>` bằng server URL từ `argocd cluster list`
   - Thay `<YOUR_USERNAME>` bằng GitHub username

2. Apply:
   ```bash
   kubectl apply -f argocd/app-remote-cluster.yaml
   argocd app sync nginx-on-spoke
   ```

3. Kiểm tra trên spoke cluster:
   ```bash
   kubectl config use-context spoke-cluster
   kubectl get all -n remote-demo
   
   # Quay lại hub cluster
   kubectl config use-context hub-cluster
   ```

4. Quan sát trên ArgoCD UI:
   - App `nginx-on-spoke` phải hiển thị cluster khác với apps khác

---

## Bài tập 4: Cleanup

```bash
./scripts/cleanup.sh

# Tạo lại cluster mặc định cho các ngày tiếp theo
minikube start --cpus=4 --memory=8192 --driver=docker
```

---

## ✅ Checklist hoàn thành

- [ ] Tạo 2 Minikube clusters thành công
- [ ] ArgoCD cài trên Hub cluster
- [ ] Add Spoke cluster vào ArgoCD (`argocd cluster list` thấy 2 clusters)
- [ ] Deploy Nginx lên Spoke cluster qua ArgoCD
- [ ] Kiểm tra pods đang chạy trên Spoke cluster
- [ ] Cleanup clusters thành công

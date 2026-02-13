# ✏️ Bài tập Ngày 2: Deploy Ứng dụng Đầu Tiên

## 🎯 Mục tiêu
- Tạo một Git repo chứa Kubernetes manifests
- Deploy ứng dụng qua ArgoCD
- Thay đổi code trên Git và xem ArgoCD tự động detect

---

## Bài tập 1: Tạo repo và deploy

1. Tạo repo mới trên GitHub: `argocd-demo-app`
2. Copy các file từ `manifests/` vào repo
3. Push lên GitHub
4. Tạo ArgoCD Application (UI hoặc CLI)
5. Sync application

**Kiểm tra:**
```bash
# App phải ở trạng thái Synced + Healthy
argocd app get nginx-demo

# Pods phải Running
kubectl get pods -n demo-app

# Truy cập Nginx
kubectl port-forward svc/nginx-demo -n demo-app 9090:80 &
curl http://localhost:9090
```

---

## Bài tập 2: Thay đổi và quan sát Auto-detect

1. Sửa `deployment.yaml` trên Git: thay `replicas: 2` thành `replicas: 3`
2. Commit & Push
3. Quan sát ArgoCD UI:
   - Status sẽ chuyển sang **OutOfSync** (chờ tối đa 3 phút do polling)
   - Click **SYNC** để đồng bộ
4. Kiểm tra:
   ```bash
   kubectl get pods -n demo-app
   # Phải thấy 3 pods
   ```

---

## Bài tập 3: Thử kết nối Private Repo (Nâng cao)

1. Tạo một **Personal Access Token** trên GitHub:
   - Settings → Developer Settings → Personal Access Tokens → Fine-grained tokens
   - Scope: Read access to repository
2. Thêm private repo vào ArgoCD:
   ```bash
   argocd repo add https://github.com/<USERNAME>/private-repo.git \
     --username <USERNAME> \
     --password <TOKEN>
   ```
3. Kiểm tra:
   ```bash
   argocd repo list
   ```

---

## ✅ Checklist hoàn thành

- [ ] Tạo được Git repo chứa manifests
- [ ] Deploy ứng dụng Nginx qua ArgoCD thành công
- [ ] Application ở trạng thái Synced + Healthy
- [ ] Thay đổi replicas trên Git, ArgoCD detect OutOfSync
- [ ] Sync lại thành công, pods tăng lên đúng số lượng

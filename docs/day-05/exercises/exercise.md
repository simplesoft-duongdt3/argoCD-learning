# ✏️ Bài tập Ngày 5: Kustomize Multi-Environment

## 🎯 Mục tiêu
- Deploy 2 môi trường (Dev, Prod) từ cùng base code
- Thay đổi replicas giữa Dev và Prod bằng Kustomize
- Quan sát sự khác biệt trên ArgoCD UI

---

## Bài tập 1: Render và so sánh

```bash
# Render Dev
kubectl kustomize kustomize/overlays/dev/ > /tmp/dev-rendered.yaml

# Render Prod
kubectl kustomize kustomize/overlays/prod/ > /tmp/prod-rendered.yaml

# So sánh
diff /tmp/dev-rendered.yaml /tmp/prod-rendered.yaml
```

**Câu hỏi:** Liệt kê tất cả điểm khác nhau giữa Dev và Prod.

---

## Bài tập 2: Deploy lên ArgoCD

1. Push thư mục `kustomize/` lên Git repo
2. Tạo 2 ArgoCD Applications:
   ```bash
   kubectl apply -f argocd/app-dev.yaml
   kubectl apply -f argocd/app-prod.yaml
   ```
3. Sync cả hai:
   ```bash
   argocd app sync kustomize-dev
   argocd app sync kustomize-prod
   ```
4. Kiểm tra:
   ```bash
   # Dev: 2 pods
   kubectl get pods -n kustomize-dev
   
   # Prod: 5 pods
   kubectl get pods -n kustomize-prod
   ```

---

## Bài tập 3: Thay đổi Replicas

1. Sửa file `kustomize/overlays/dev/kustomization.yaml`:
   - Thay `replicas: 2` thành `replicas: 3`
2. Commit & Push lên Git
3. Quan sát ArgoCD tự động sync
4. Kiểm tra:
   ```bash
   kubectl get pods -n kustomize-dev
   # → 3 pods
   ```

---

## Bài tập 4: Thêm overlay cho Staging (Nâng cao)

1. Tạo thư mục `kustomize/overlays/staging/kustomization.yaml`:
   - Kế thừa từ `../../base`
   - replicas: 3
   - namePrefix: `staging-`
   - namespace: `kustomize-staging`
   - labels: `environment: staging`

2. Tạo ArgoCD Application mới cho staging

3. Deploy và kiểm tra

---

## ✅ Checklist hoàn thành

- [ ] Render thành công Dev và Prod manifests
- [ ] Deploy 2 môi trường qua ArgoCD
- [ ] Dev có 2 pods, Prod có 5 pods
- [ ] Thay đổi replicas qua Git → ArgoCD tự sync
- [ ] (Nâng cao) Thêm môi trường Staging thành công

# ✏️ Bài tập Ngày 8: ApplicationSet

## 🎯 Mục tiêu
- Tạo ApplicationSet với List Generator
- Tạo ApplicationSet với Git Generator
- Thêm folder mới → auto-deploy

---

## Bài tập 1: List Generator

1. Apply ApplicationSet:
   ```bash
   kubectl apply -f argocd/appset-list.yaml
   ```
2. Kiểm tra 3 apps tạo tự động:
   ```bash
   argocd app list
   # → web-dev, web-staging, web-prod
   ```
3. Cleanup:
   ```bash
   kubectl delete applicationset appset-list-demo -n argocd
   ```

---

## Bài tập 2: Git Generator

1. Push thư mục `apps/` (app-1, app-2, app-3) lên Git repo
2. Apply ApplicationSet:
   ```bash
   kubectl apply -f argocd/appset-git.yaml
   ```
3. Kiểm tra 3 apps:
   ```bash
   argocd app list
   # → app-1, app-2, app-3
   ```

---

## Bài tập 3: Auto-deploy khi tạo folder mới 🚀

1. Tạo folder `apps/app-4/` trên Git:
   ```bash
   mkdir -p apps/app-4
   # Tạo deployment.yaml cho app-4
   # Commit & Push
   ```

2. Chờ ArgoCD detect (tối đa 3 phút)

3. Kiểm tra:
   ```bash
   argocd app list
   # → app-1, app-2, app-3, app-4 ← MỚI!
   ```

---

## Bài tập 4: Xóa folder → Auto-delete

1. Xóa folder `apps/app-4/` khỏi Git
2. Commit & Push
3. ApplicationSet sẽ tự xóa Application `app-4`

---

## ✅ Checklist hoàn thành

- [ ] List Generator tạo 3 apps tự động
- [ ] Git Generator tạo apps từ folder structure
- [ ] Thêm folder mới → app mới tự động xuất hiện  
- [ ] Xóa folder → app tự động bị xóa

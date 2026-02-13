# ✏️ Bài tập Ngày 7: App of Apps Pattern

## 🎯 Mục tiêu
- Tạo Root Application quản lý tất cả child apps
- Thêm/xóa app mới qua Git
- Thiết kế cấu trúc Git chuẩn

---

## Bài tập 1: Deploy App of Apps

1. Push thư mục `apps/` và `manifests/` lên Git repo (sửa URL repo trong các file YAML)
2. Tạo Root Application:
   ```bash
   kubectl apply -f apps/root-app.yaml
   ```
3. Sync root app:
   ```bash
   argocd app sync root-app
   ```
4. Kiểm tra tất cả apps:
   ```bash
   argocd app list
   # → root-app, frontend, backend, database
   ```

---

## Bài tập 2: Thêm app mới qua Git

1. Tạo file `apps/children/cache-app.yaml` cho một app mới (ví dụ: Memcached)
2. Tạo manifests tương ứng tại `manifests/cache/`
3. Commit & Push → Root App tự detect và tạo child app mới
4. Kiểm tra:
   ```bash
   argocd app list
   # → root-app, frontend, backend, database, cache
   ```

---

## Bài tập 3: Xóa app qua Git

1. Xóa file `apps/children/cache-app.yaml` khỏi Git
2. Commit & Push
3. Root App sẽ Prune → Child app `cache` bị xóa
4. Kiểm tra:
   ```bash
   argocd app list
   # → cache app không còn
   ```

---

## Bài tập 4: Thiết kế cấu trúc Git chuẩn (Nâng cao)

Thiết kế cấu trúc Git cho tổ chức có:
- 3 teams (platform, frontend, backend)
- 2 environments (dev, prod)
- Mỗi team có 2-3 microservices

**Vẽ diagram cấu trúc thư mục và giải thích.**

---

## ✅ Checklist hoàn thành

- [ ] Root App tạo thành công, quản lý 3 child apps
- [ ] Tất cả child apps Synced + Healthy
- [ ] Thêm app mới qua Git → tự detect
- [ ] Xóa app qua Git → tự prune
- [ ] (Nâng cao) Thiết kế cấu trúc Git cho tổ chức lớn

# ✏️ Bài tập Ngày 9: RBAC & Projects

## 🎯 Mục tiêu
- Tạo AppProject giới hạn namespace
- Tạo user "developer" chỉ có quyền view
- Test phân quyền

---

## Bài tập 1: Tạo AppProject

1. Apply:
   ```bash
   kubectl apply -f argocd/appproject-team-a.yaml
   ```
2. Kiểm tra:
   ```bash
   argocd proj get team-a
   ```
3. Thử tạo app trong project team-a deploy vào namespace **không được phép**:
   ```bash
   argocd app create test-forbidden \
     --project team-a \
     --repo https://github.com/<YOUR_USERNAME>/argocd-demo-app.git \
     --path manifests \
     --dest-server https://kubernetes.default.svc \
     --dest-namespace forbidden-namespace
   # → Expected: Error - namespace không nằm trong allowed destinations
   ```

---

## Bài tập 2: Tạo User Developer (View-only)

1. Apply RBAC:
   ```bash
   kubectl apply -f argocd/rbac-configmap.yaml
   ```

2. Tạo user:
   ```bash
   kubectl patch configmap argocd-cm -n argocd --type merge -p '
   data:
     accounts.developer: "apiKey, login"
     accounts.developer.enabled: "true"
   '
   ```

3. Đặt password:
   ```bash
   argocd account update-password \
     --account developer \
     --new-password Dev@12345 \
     --current-password <ADMIN_PASSWORD>
   ```

---

## Bài tập 3: Test phân quyền

1. Login bằng developer:
   ```bash
   argocd login localhost:8080 --username developer --password Dev@12345 --insecure
   ```

2. Test các quyền:
   ```bash
   # ✅ Xem apps (được phép)
   argocd app list

   # ❌ Sync app (không được phép)
   argocd app sync nginx-demo
   # → PermissionDenied

   # ❌ Xóa app (không được phép)
   argocd app delete nginx-demo
   # → PermissionDenied
   ```

3. Login lại bằng admin để tiếp tục:
   ```bash
   argocd login localhost:8080 --username admin --password <ADMIN_PASSWORD> --insecure
   ```

---

## ✅ Checklist hoàn thành

- [ ] AppProject `team-a` tạo thành công
- [ ] Project giới hạn namespace đúng
- [ ] User `developer` tạo thành công
- [ ] Developer chỉ xem, không sync/delete
- [ ] Test forbidden namespace bị chặn

# ✏️ Bài tập Ngày 1: Login & Đổi Password Admin

## 🎯 Mục tiêu
- Login vào ArgoCD UI thành công
- Login vào ArgoCD CLI thành công
- Đổi mật khẩu admin qua CLI

---

## Bài tập 1: Login vào UI

1. Mở terminal và chạy port-forward:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 8080:443 &
   ```
2. Mở trình duyệt, truy cập `https://localhost:8080`
3. Chấp nhận certificate tự ký (self-signed)
4. Đăng nhập với username `admin` và password lấy từ script

> **📸 Chụp ảnh màn hình dashboard ArgoCD sau khi login thành công**

---

## Bài tập 2: Login vào CLI & Đổi Password

1. Lấy mật khẩu admin:
   ```bash
   ./scripts/get-admin-password.sh
   ```

2. Login qua CLI:
   ```bash
   argocd login localhost:8080 --username admin --password <PASSWORD> --insecure
   ```

3. Đổi mật khẩu admin:
   ```bash
   argocd account update-password \
     --current-password <OLD_PASSWORD> \
     --new-password <NEW_PASSWORD>
   ```

4. Kiểm tra login lại với mật khẩu mới:
   ```bash
   argocd login localhost:8080 --username admin --password <NEW_PASSWORD> --insecure
   ```

---

## Bài tập 3: Khám phá ArgoCD CLI

Chạy các lệnh sau và ghi chú kết quả:

```bash
# Xem version
argocd version

# Xem danh sách cluster đang quản lý
argocd cluster list

# Xem danh sách repository (chưa có)
argocd repo list

# Xem danh sách application (chưa có)
argocd app list

# Xem thông tin tài khoản hiện tại
argocd account get-user-info
```

---

## ✅ Checklist hoàn thành

- [ ] Login vào ArgoCD UI thành công
- [ ] Login vào ArgoCD CLI thành công
- [ ] Đổi mật khẩu admin thành công
- [ ] Chạy được các lệnh CLI cơ bản
- [ ] Chạy `scripts/verify.sh` thành công (tất cả passed)

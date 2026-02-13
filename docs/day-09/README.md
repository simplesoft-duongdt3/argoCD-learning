# 📅 Ngày 9: Bảo Mật — RBAC & Projects

## 🎯 Mục tiêu hôm nay
- Hiểu ArgoCD Projects (AppProject) và phân quyền
- Tạo Project giới hạn namespace
- Tạo user với quyền view-only
- Tìm hiểu cách tích hợp SSO

---

## 📖 Lý thuyết

### AppProject

**AppProject** giới hạn những gì ArgoCD Application có thể làm:

```
┌──────────────────────────────────────────────────────┐
│                    AppProject                        │
│                                                      │
│  Giới hạn:                                           │
│  ┌────────────────────────────────────────────────┐  │
│  │ 📁 Source Repos:  Chỉ được lấy code từ repo A │  │
│  │ 🎯 Destinations:  Chỉ deploy vào namespace X  │  │
│  │ 📦 Resources:    Chỉ tạo Deployment, Service  │  │
│  │ 👥 Roles:        Ai được làm gì               │  │
│  └────────────────────────────────────────────────┘  │
│                                                      │
│  ⚠️ Project "default" cho phép TẤT CẢ              │
│  → Production nên tạo project riêng                  │
└──────────────────────────────────────────────────────┘
```

### RBAC (Role-Based Access Control)

ArgoCD RBAC dùng **Casbin policy format**:

```
# Format: p, <role>, <resource>, <action>, <project>/<object>
p, role:developer, applications, get, */*, allow
p, role:developer, applications, sync, team-a/*, deny
p, role:admin, applications, *, */*, allow

# Gán user vào role
g, john, role:developer
g, admin, role:admin
```

### Các Action trong RBAC

| Resource | Actions |
|----------|---------|
| **applications** | get, create, update, delete, sync, override |
| **clusters** | get, create, update, delete |
| **repositories** | get, create, update, delete |
| **projects** | get, create, update, delete |
| **logs** | get |

---

## 🔧 Thực hành

### Bước 1: Tạo AppProject

```bash
# Xem file mẫu
cat argocd/appproject-team-a.yaml

# Apply
kubectl apply -f argocd/appproject-team-a.yaml

# Kiểm tra
argocd proj list
argocd proj get team-a
```

### Bước 2: Cấu hình RBAC

```bash
# Xem RBAC policy
cat argocd/rbac-configmap.yaml

# Apply
kubectl apply -f argocd/rbac-configmap.yaml

# Kiểm tra RBAC
argocd admin settings rbac can role:developer get applications '*/*' --policy-file argocd/rbac-configmap.yaml
```

### Bước 3: Tạo Local User

```bash
# Thêm user vào argocd-cm ConfigMap
kubectl patch configmap argocd-cm -n argocd --type merge -p '
data:
  accounts.developer: "apiKey, login"
  accounts.developer.enabled: "true"
'

# Đặt password cho user
argocd account update-password \
  --account developer \
  --new-password Dev@12345 \
  --current-password <ADMIN_PASSWORD>

# Test login
argocd login localhost:8080 --username developer --password Dev@12345 --insecure
```

### Bước 4: Test phân quyền

```bash
# Login bằng developer
argocd login localhost:8080 --username developer --password Dev@12345 --insecure

# Thử xem apps (OK - có quyền get)
argocd app list

# Thử sync app (FAIL - không có quyền sync)
argocd app sync nginx-demo
# → Expected: PermissionDenied
```

---

## ❓ FAQ

### Q: Làm sao tích hợp SSO (Google/Okta) vào ArgoCD?
**A:** ArgoCD tích hợp SSO thông qua **Dex** (built-in) hoặc OIDC trực tiếp. Xem file mẫu `argocd/argocd-cm-sso.yaml` để tham khảo cấu hình Google OAuth.

Các bước:
1. Tạo OAuth App trên Google/Okta
2. Cấu hình `argocd-cm` ConfigMap với OIDC settings
3. Map OIDC groups → ArgoCD roles trong RBAC

### Q: Có nên dùng project `default` trên production?
**A:** **Không!** Project `default` cho phép deploy **bất kỳ repo** vào **bất kỳ namespace**. Production nên có project riêng với giới hạn chặt.

---

## 📚 Bài tập & Ôn tập

- [📝 Bài tập thực hành](exercises/exercise.md)
- [❓ Câu hỏi ôn tập (30 câu)](questions.md)

---

> **⏮️ Ngày trước:** [Day 08 — ApplicationSet](../day-08/)
> **⏭️ Ngày tiếp:** [Day 10 — Canary & Blue/Green](../day-10/)

# 📅 Ngày 8: ApplicationSet & Tự Động Hóa Quy Mô Lớn

## 🎯 Mục tiêu hôm nay
- Hiểu ApplicationSet Generators (List, Git, Cluster)
- Tự động tạo hàng loạt Application từ template
- Dùng Git Generator để auto-deploy khi có folder mới

---

## 📖 Lý thuyết

### ApplicationSet là gì?

ApplicationSet là **controller** cho phép bạn tạo nhiều ArgoCD Application từ **một template duy nhất**. Thay vì viết 100 file YAML cho 100 apps, bạn chỉ cần 1 ApplicationSet.

```
┌───────────────────────────────────────────────────────┐
│                  ApplicationSet                       │
│                                                       │
│  Template:                                            │
│  ┌─────────────────────────────┐                      │
│  │ name: {{name}}              │                      │
│  │ path: apps/{{name}}         │                      │
│  │ namespace: {{name}}         │                      │
│  └─────────────────────────────┘                      │
│           +                                           │
│  Generator:                                           │
│  ┌─────────────────────────────┐                      │
│  │ - name: app-1               │   Kết quả:          │
│  │ - name: app-2               │ → 3 Applications    │
│  │ - name: app-3               │   được tạo tự động  │
│  └─────────────────────────────┘                      │
└───────────────────────────────────────────────────────┘
```

### 3 Generator chính

| Generator | Data source | Use case |
|-----------|-------------|----------|
| **List** | Danh sách hardcode | Biết trước tên apps |
| **Git** | Thư mục/file trong Git | Auto-detect apps mới |
| **Cluster** | Danh sách clusters | Deploy cùng app lên nhiều clusters |

### List Generator

```yaml
generators:
  - list:
      elements:
        - name: app-1
          env: dev
        - name: app-2
          env: prod
```

### Git Generator (Directory)

```yaml
generators:
  - git:
      repoURL: https://github.com/user/repo.git
      revision: HEAD
      directories:
        - path: apps/*    # Mỗi folder = 1 Application
```

### Cluster Generator

```yaml
generators:
  - clusters: {}    # Tạo app cho MỌI cluster đã registered
```

---

## 🔧 Thực hành

### Bước 1: List Generator

```bash
# Xem file mẫu
cat argocd/appset-list.yaml

# Apply
kubectl apply -f argocd/appset-list.yaml

# Kiểm tra apps đã được tạo
argocd app list
```

### Bước 2: Git Generator

```bash
# Xem cấu trúc apps/
tree apps/
# apps/
# ├── app-1/
# │   ├── deployment.yaml
# │   └── service.yaml
# ├── app-2/
# │   └── ...
# └── app-3/
#     └── ...

# Apply ApplicationSet với Git Generator
kubectl apply -f argocd/appset-git.yaml

# Kiểm tra
argocd app list
```

### Bước 3: Tạo folder mới → Auto-deploy 🚀

```bash
# Tạo app-4 folder trên Git
mkdir -p apps/app-4
cat <<EOF > apps/app-4/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-4
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-4
  template:
    metadata:
      labels:
        app: app-4
    spec:
      containers:
        - name: app
          image: nginx:1.25-alpine
          ports:
            - containerPort: 80
EOF

# Commit & Push
# → ApplicationSet tự detect folder mới và tạo Application!
```

### Bước 4: Cluster Generator (Nếu có multi-cluster từ Day 06)

```bash
kubectl apply -f argocd/appset-cluster.yaml
# → Tạo 1 app trên mỗi cluster đã registered
```

---

## ❓ FAQ

### Q: Làm sao để ngăn chặn việc ApplicationSet tạo ra quá nhiều rác trên Cluster?
**A:** Sử dụng các chiến lược:
1. **`preserveResourcesOnDeletion: true`**: Không xóa resources khi xóa ApplicationSet
2. **`ignoreApplicationDifferences`**: Bỏ qua khác biệt nhất định
3. **Sync Policy thận trọng**: Không bật auto-sync + prune ngay
4. **Git path filter**: Chỉ match folders cụ thể

### Q: ApplicationSet vs App of Apps?
**A:** 
- **ApplicationSet** = Tự động tạo apps **giống nhau** từ template
- **App of Apps** = Quản lý apps **khác nhau** một cách tường minh

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 07 — App of Apps](../day-07/)
> **⏭️ Ngày tiếp:** [Day 09 — Bảo mật RBAC](../day-09/)

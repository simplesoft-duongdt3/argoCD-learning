# 📅 Ngày 7: App of Apps Pattern

## 🎯 Mục tiêu hôm nay
- Hiểu pattern "App of Apps" để quản lý hàng trăm ứng dụng
- Tạo Root Application quản lý Child Applications
- Thiết kế cấu trúc Git chuẩn cho mô hình này

---

## 📖 Lý thuyết

### Vấn đề: Quản lý nhiều Applications

Khi team lớn lên, bạn có hàng chục/trăm ArgoCD Applications. Nếu tạo thủ công từng cái → **rối, khó quản lý, không scalable**.

### Giải pháp: App of Apps

```
┌─────────────────────────────────────────────────────┐
│                  APP OF APPS PATTERN                │
│                                                     │
│  ┌─────────────────────────┐                        │
│  │     ROOT APPLICATION    │                        │
│  │  (Quản lý tất cả apps) │                        │
│  └──────────┬──────────────┘                        │
│             │                                       │
│    ┌────────┼────────┬──────────┐                   │
│    ▼        ▼        ▼          ▼                   │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐               │
│  │ App  │ │ App  │ │ App  │ │ App  │               │
│  │ FE   │ │ BE   │ │ DB   │ │ ...  │               │
│  └──────┘ └──────┘ └──────┘ └──────┘               │
│                                                     │
│  ✅ Chỉ cần quản lý 1 root app                     │
│  ✅ Thêm app mới = thêm 1 file YAML vào Git        │
│  ✅ Xóa app = xóa 1 file YAML khỏi Git             │
└─────────────────────────────────────────────────────┘
```

### Cấu trúc Git

```
repo/
├── apps/                          ← Root App trỏ đến đây
│   ├── root-app.yaml              ← Root Application
│   └── children/                  ← Child Applications  
│       ├── frontend-app.yaml
│       ├── backend-app.yaml
│       └── database-app.yaml
└── manifests/                     ← Actual K8s manifests
    ├── frontend/
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── backend/
    │   ├── deployment.yaml
    │   └── service.yaml
    └── database/
        ├── statefulset.yaml
        └── service.yaml
```

### App of Apps vs ApplicationSet

| | App of Apps | ApplicationSet |
|---|-------------|----------------|
| **Cách tạo app** | Mỗi app = 1 YAML file | Template tự động generate |
| **Linh hoạt** | Cao (mỗi app cấu hình riêng) | Trung bình (dùng template) |
| **Khi nào dùng** | Apps khác nhau nhiều | Apps giống nhau, khác vài param |
| **Scale** | Tốt (đến ~100 apps) | Tuyệt vời (1000+ apps) |

---

## 🔧 Thực hành

### Bước 1: Xem cấu trúc mẫu

```bash
tree apps/ manifests/
```

### Bước 2: Push lên Git

```bash
# Push toàn bộ thư mục day-07 lên repo
# Hoặc copy apps/ và manifests/ vào repo riêng
```

### Bước 3: Tạo Root Application

```bash
# Áp dụng root app
kubectl apply -f apps/root-app.yaml

# Sync root app → tự động tạo các child apps
argocd app sync root-app

# Kiểm tra
argocd app list
# → Phải thấy: root-app, frontend, backend, database
```

### Bước 4: Quan sát ArgoCD UI

1. Mở ArgoCD UI
2. Bạn sẽ thấy Root App và 3 Child Apps
3. Click vào Root App → thấy 3 child Application resources
4. Click vào mỗi child → thấy actual K8s resources

### Bước 5: Thêm app mới

```bash
# Tạo file child app mới
cat <<EOF > apps/children/monitoring-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monitoring
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/<YOUR_USERNAME>/argocd-demo-app.git
    targetRevision: HEAD
    path: manifests/monitoring
  destination:
    server: https://kubernetes.default.svc
    namespace: monitoring
  syncPolicy:
    automated:
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF

# Commit & push → ArgoCD tự create app mới!
```

---

## ❓ FAQ

### Q: App of Apps hay ApplicationSet tốt hơn?
**A:** Phụ thuộc vào use case:
- **App of Apps**: Khi mỗi app có cấu hình riêng biệt, team muốn kiểm soát chi tiết
- **ApplicationSet**: Khi nhiều app giống nhau, chỉ khác vài tham số (name, namespace, env)

Nhiều team **dùng cả hai**: App of Apps cho top-level grouping, ApplicationSet cho dynamic generation.

### Q: Root App bị xóa thì sao?
**A:** Phụ thuộc vào `finalizer`:
- Có `resources-finalizer.argocd.argoproj.io`: Xóa root → xóa tất cả children + resources
- Không có finalizer: Xóa root → children vẫn tồn tại (orphaned)

---

## 📚 Bài tập & Ôn tập

- [📝 Bài tập thực hành](exercises/exercise.md)
- [❓ Câu hỏi ôn tập (30 câu)](questions.md)

---

> **⏮️ Ngày trước:** [Day 06 — Multi-cluster](../day-06/)
> **⏭️ Ngày tiếp:** [Day 08 — ApplicationSet](../day-08/)

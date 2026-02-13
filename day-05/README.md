# 📅 Ngày 5: Kustomize — "Vũ Khí" Bí Mật

## 🎯 Mục tiêu hôm nay
- Hiểu Kustomize là gì và Base/Overlays pattern
- Tạo cấu trúc multi-environment (Dev, Prod) với Kustomize
- Deploy 2 môi trường khác nhau từ cùng một code gốc qua ArgoCD

---

## 📖 Lý thuyết

### Kustomize là gì?

Kustomize cho phép bạn **tùy chỉnh Kubernetes YAML** mà không cần template engine. Thay vì dùng biến `{{ .Values.xxx }}` như Helm, Kustomize dùng **patches** và **overlays**.

```
┌──────────────────────────────────────────────────────┐
│                Kustomize Structure                    │
│                                                      │
│  base/                   ← Code gốc (chung)         │
│  ├── deployment.yaml                                 │
│  ├── service.yaml                                    │
│  └── kustomization.yaml                              │
│                                                      │
│  overlays/                                           │
│  ├── dev/                ← Tùy chỉnh cho Dev        │
│  │   └── kustomization.yaml  (replicas: 1)          │
│  └── prod/               ← Tùy chỉnh cho Prod      │
│      └── kustomization.yaml  (replicas: 5)          │
└──────────────────────────────────────────────────────┘
```

### So sánh Helm vs Kustomize

| Tiêu chí | Helm | Kustomize |
|----------|------|-----------|
| **Cách hoạt động** | Template engine (Go template) | Patch overlays |
| **Độ phức tạp** | Cao (cần học template syntax) | Thấp (chỉ cần biết YAML) |
| **Package sharing** | Tuyệt vời (Helm repos) | Không phù hợp |
| **Multi-env** | `values-{env}.yaml` | `overlays/{env}/` |
| **Tích hợp kubectl** | Cần cài riêng | Built-in (`kubectl -k`) |
| **ArgoCD support** | ✅ Tốt | ✅ Tốt |
| **Khi nào dùng** | Chia sẻ chart công khai | Quản lý config nội bộ |

### Khi nào nên dùng Kustomize?

- ✅ Quản lý **nhiều môi trường** (dev, staging, prod) từ cùng base
- ✅ Không muốn học template syntax phức tạp
- ✅ Team nhỏ, config nội bộ
- ❌ Không phù hợp để chia sẻ package công khai (dùng Helm)

---

## 🔧 Thực hành

### Bước 1: Xem cấu trúc Kustomize

```bash
# Cấu trúc đã chuẩn bị sẵn
tree kustomize/
# kustomize/
# ├── base/
# │   ├── deployment.yaml
# │   ├── service.yaml
# │   └── kustomization.yaml
# └── overlays/
#     ├── dev/
#     │   └── kustomization.yaml
#     └── prod/
#         └── kustomization.yaml
```

### Bước 2: Test Kustomize locally

```bash
# Render cho môi trường Dev
kubectl kustomize kustomize/overlays/dev/

# Render cho môi trường Prod
kubectl kustomize kustomize/overlays/prod/

# So sánh 2 output → thấy sự khác biệt (replicas, labels, env vars)
```

### Bước 3: Push lên Git & Deploy qua ArgoCD

```bash
# Push thư mục kustomize/ lên repo Git
# Sau đó tạo 2 ArgoCD Applications

# Deploy môi trường Dev
kubectl apply -f argocd/app-dev.yaml

# Deploy môi trường Prod
kubectl apply -f argocd/app-prod.yaml

# Sync cả hai
argocd app sync kustomize-dev
argocd app sync kustomize-prod
```

### Bước 4: So sánh 2 môi trường

```bash
# Dev: 2 replicas
kubectl get pods -n kustomize-dev

# Prod: 5 replicas
kubectl get pods -n kustomize-prod

# Xem labels khác nhau
kubectl get deployment -n kustomize-dev -o jsonpath='{.items[0].metadata.labels}' | jq
kubectl get deployment -n kustomize-prod -o jsonpath='{.items[0].metadata.labels}' | jq
```

---

## ❓ FAQ

### Q: Nên dùng Helm hay Kustomize?
**A:** Phụ thuộc vào use case:
- **Helm**: Khi cần chia sẻ chart, deploy third-party apps (Redis, PostgreSQL), complex templating
- **Kustomize**: Khi quản lý internal apps, multi-environment, đơn giản hơn

Nhiều team **dùng cả hai**: Helm cho third-party, Kustomize cho internal apps.

### Q: ArgoCD tự detect Kustomize không cần cấu hình gì đặc biệt không?
**A:** Đúng! ArgoCD tự nhận diện thư mục có file `kustomization.yaml` và dùng Kustomize để render.

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 04 — Làm việc với Helm Charts](../day-04/)
> **⏭️ Ngày tiếp:** [Day 06 — Quản lý nhiều Cluster](../day-06/)

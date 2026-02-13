# 🚀 Khóa Học ArgoCD 10 Ngày — Kế Hoạch Thiết Kế

Thiết kế khóa học ArgoCD/GitOps 10 ngày, mỗi ngày 1 thư mục chứa đầy đủ lý thuyết, file cấu hình, script, và bài tập để học viên tiến hành thực hành ngay lập tức mà không cần tìm kiếm thêm tài liệu.

## User Review Required

> [!IMPORTANT]
> Mỗi ngày sẽ tạo 1 thư mục `day-XX/` chứa:
> - `README.md` — Lý thuyết + FAQ + hướng dẫn chi tiết từng bước
> - `manifests/` hoặc `helm/` hoặc `kustomize/` — Các file YAML sẵn sàng dùng
> - `exercises/` — Bài tập có hướng dẫn + đáp án
> - `scripts/` — Script tự động hóa (setup, verify, cleanup)

> [!WARNING]
> Khóa học yêu cầu **Minikube** hoặc **K3s** đã cài sẵn. Ngày 6 (Multi-cluster) cần 2 cluster chạy song song.

## Proposed Changes

### Cấu trúc tổng thể

```
argoCD/
├── requirements.md
├── README.md                    ← [NEW] Overview & hướng dẫn setup ban đầu
├── day-01/                      ← Nhập môn GitOps & Cài đặt ArgoCD
├── day-02/                      ← Kết nối Repository & App đầu tiên  
├── day-03/                      ← Sync Strategies & Phục hồi sự cố
├── day-04/                      ← Helm Charts
├── day-05/                      ← Kustomize
├── day-06/                      ← Multi-cluster
├── day-07/                      ← App of Apps Pattern
├── day-08/                      ← ApplicationSet
├── day-09/                      ← Bảo mật (RBAC & Projects)
└── day-10/                      ← Canary & Blue/Green (Argo Rollouts)
```

---

### Root

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/README.md)
- Tổng quan khóa học, prerequisites, cách cài Minikube/K3s
- Bảng lộ trình 10 ngày với link tới từng thư mục
- Hướng dẫn clone repo và bắt đầu

---

### Day 01 — Nhập môn GitOps & Cài đặt ArgoCD

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-01/README.md)
- Lý thuyết GitOps (so sánh Push-based vs Pull-based)
- Hướng dẫn cài ArgoCD bằng Manifest + Helm (cả 2 cách)
- FAQ: ArgoCD vs Jenkins/GitLab CI

#### [NEW] day-01/scripts/
- `install-argocd.sh` — Script cài ArgoCD tự động
- `get-admin-password.sh` — Lấy password admin
- `verify.sh` — Kiểm tra ArgoCD đã cài thành công

#### [NEW] day-01/exercises/
- `exercise.md` — Login UI + đổi password qua CLI

---

### Day 02 — Kết nối Repository & Ứng dụng đầu tiên

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-02/README.md)
- Khái niệm Application trong ArgoCD
- Hướng dẫn kết nối Git repo (public + private)
- Webhook vs Polling

#### [NEW] day-02/manifests/
- `namespace.yaml`, `deployment.yaml`, `service.yaml` — App Nginx mẫu

#### [NEW] day-02/argocd/
- `application.yaml` — ArgoCD Application manifest

#### [NEW] day-02/exercises/
- `exercise.md` — Tạo Deployment, push Git, xem auto-sync

---

### Day 03 — Sync Strategies & Phục hồi sự cố

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-03/README.md)
- Manual vs Automatic Sync, Prune, Self-heal
- Demo xóa resource và quan sát ArgoCD khôi phục

#### [NEW] day-03/argocd/
- `application-auto-sync.yaml` — App với Automated Sync + Self-heal + Prune

#### [NEW] day-03/manifests/
- Deployment + Service cho bài test phục hồi

#### [NEW] day-03/exercises/
- `exercise.md` — Cấu hình Self-heal và Prune, test phục hồi

---

### Day 04 — Làm việc với Helm Charts

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-04/README.md)
- Cách ArgoCD render Helm template
- Deploy Redis/WordPress qua Helm

#### [NEW] day-04/argocd/
- `helm-app-redis.yaml` — ArgoCD App cho Redis Helm chart
- `helm-app-wordpress.yaml` — ArgoCD App cho WordPress

#### [NEW] day-04/helm/
- `custom-values.yaml` — Override values mẫu

#### [NEW] day-04/exercises/
- `exercise.md` — Override values.yaml từ UI ArgoCD

---

### Day 05 — Kustomize

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-05/README.md)
- Kustomize là gì, Base + Overlays pattern
- So sánh Helm vs Kustomize

#### [NEW] day-05/kustomize/
- `base/` — deployment.yaml, service.yaml, kustomization.yaml
- `overlays/dev/` — kustomization.yaml (2 replicas)
- `overlays/prod/` — kustomization.yaml (5 replicas)

#### [NEW] day-05/argocd/
- `app-dev.yaml`, `app-prod.yaml` — 2 ArgoCD App cho 2 môi trường

#### [NEW] day-05/exercises/
- `exercise.md` — Thay đổi replicas giữa Dev/Prod

---

### Day 06 — Quản lý nhiều Cluster

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-06/README.md)
- Kiến trúc Hub-and-Spoke
- Hướng dẫn add external cluster

#### [NEW] day-06/scripts/
- `setup-multi-cluster.sh` — Tạo 2 cluster Minikube
- `add-cluster.sh` — Add cluster vào ArgoCD
- `cleanup.sh` — Xóa cluster phụ

#### [NEW] day-06/argocd/
- `app-remote-cluster.yaml` — Deploy app sang cluster khác

#### [NEW] day-06/exercises/
- `exercise.md` — Deploy cross-cluster

---

### Day 07 — App of Apps Pattern

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-07/README.md)
- Pattern App of Apps, khi nào nên dùng
- So sánh App of Apps vs ApplicationSet

#### [NEW] day-07/apps/
- `root-app.yaml` — Root Application
- `children/` — 3 child apps mẫu (frontend, backend, database)

#### [NEW] day-07/manifests/
- `frontend/`, `backend/`, `database/` — Manifest cho từng child app

#### [NEW] day-07/exercises/
- `exercise.md` — Thiết kế cấu trúc Git chuẩn

---

### Day 08 — ApplicationSet

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-08/README.md)
- Generator types: List, Git, Cluster
- Tự động tạo app từ folder structure

#### [NEW] day-08/argocd/
- `appset-list.yaml` — List Generator
- `appset-git.yaml` — Git Generator
- `appset-cluster.yaml` — Cluster Generator

#### [NEW] day-08/apps/
- `app-1/`, `app-2/`, `app-3/` — 3 app mẫu cho Git Generator

#### [NEW] day-08/exercises/
- `exercise.md` — Git Generator auto-deploy khi tạo folder mới

---

### Day 09 — Bảo mật (RBAC & Projects)

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-09/README.md)
- AppProject, RBAC policy, SSO overview
- Phân quyền theo namespace

#### [NEW] day-09/argocd/
- `appproject-team-a.yaml` — Project giới hạn namespace
- `rbac-configmap.yaml` — RBAC policy
- `argocd-cm-sso.yaml` — Mẫu cấu hình SSO (tham khảo)

#### [NEW] day-09/exercises/
- `exercise.md` — Tạo user Developer view-only

---

### Day 10 — Canary & Blue/Green (Argo Rollouts)

#### [NEW] [README.md](file:///Users/teamcumahay/Documents/argoCD/day-10/README.md)
- Argo Rollouts là gì, khác gì ArgoCD
- Canary vs Blue/Green strategy

#### [NEW] day-10/scripts/
- `install-argo-rollouts.sh` — Cài Argo Rollouts
- `verify.sh` — Kiểm tra cài đặt

#### [NEW] day-10/manifests/
- `rollout-canary.yaml` — Canary deployment (10% traffic)
- `rollout-bluegreen.yaml` — Blue/Green deployment
- `service.yaml`, `ingress.yaml`

#### [NEW] day-10/exercises/
- `exercise.md` — Rollback khi Canary bị lỗi

---

## Verification Plan

### Manual Verification
- Mở từng thư mục `day-XX/` và kiểm tra:
  - `README.md` có đầy đủ lý thuyết, hướng dẫn từng bước, FAQ
  - Tất cả YAML file đều hợp lệ (có thể `kubectl apply --dry-run=client`)
  - Script có quyền execute và có header bash
  - Bài tập có hướng dẫn rõ ràng + đáp án

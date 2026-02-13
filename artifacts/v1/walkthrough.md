# Walkthrough: Khóa Học ArgoCD 10 Ngày

## Tổng quan
Đã thiết kế và tạo xong khóa học ArgoCD/GitOps 10 ngày với **65 files** trải đều 10 thư mục `day-XX/`.

## Cấu trúc mỗi ngày

| Thành phần | Mô tả |
|---|---|
| `README.md` | Lý thuyết chi tiết + diagram + FAQ |
| `manifests/` hoặc `argocd/` | YAML sẵn sàng `kubectl apply` |
| `scripts/` | Bash scripts tự động (đã chmod +x) |
| `exercises/exercise.md` | Bài tập + checklist hoàn thành |

## Nội dung từng ngày

| Ngày | Files | Highlight |
|------|-------|-----------|
| **01** | 5 files | Script cài ArgoCD, verify, lấy password |
| **02** | 6 files | Nginx manifests, ArgoCD Application YAML |
| **03** | 4 files | Auto-sync + self-heal + prune config |
| **04** | 5 files | Helm apps cho Redis & WordPress |
| **05** | 8 files | Kustomize base + overlays (dev/prod) |
| **06** | 6 files | Multi-cluster scripts (setup, add, cleanup) |
| **07** | 9 files | Root app + 3 child apps + 3 service manifests |
| **08** | 7 files | 3 ApplicationSet generators + 3 sample apps |
| **09** | 5 files | AppProject, RBAC ConfigMap, SSO reference |
| **10** | 7 files | Canary + Blue/Green Rollout manifests |

## Xác minh
- ✅ Tất cả 65 files đã tạo thành công
- ✅ Tất cả scripts `.sh` có quyền execute
- ✅ Cấu trúc thư mục đúng theo implementation plan

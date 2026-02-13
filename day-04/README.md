# 📅 Ngày 4: Làm Việc Với Helm Charts

## 🎯 Mục tiêu hôm nay
- Hiểu cách ArgoCD render Helm template
- Deploy ứng dụng phức tạp (Redis) bằng Helm qua ArgoCD
- Override `values.yaml` từ giao diện ArgoCD

---

## 📖 Lý thuyết

### Helm trong ArgoCD

ArgoCD hỗ trợ Helm charts **native** — không cần cài Helm CLI trên máy. ArgoCD tự:

1. Clone Helm chart từ repo
2. Render template với `values.yaml`
3. Apply kết quả lên cluster

```
┌──────────────────────────────────────────────────┐
│              ArgoCD + Helm Flow                  │
│                                                  │
│  Helm Repo/Git ──→ ArgoCD ──→ helm template ──→  │
│                       ↓                          │
│              Rendered YAML ──→ kubectl apply     │
│                                                  │
│  ⚠️ ArgoCD KHÔNG chạy "helm install"             │
│     Nó chỉ render template rồi apply YAML       │
└──────────────────────────────────────────────────┘
```

### 3 cách dùng Helm trong ArgoCD

| Cách | Source | Mô tả |
|------|--------|--------|
| **Helm Repo** | `repoURL: https://charts.bitnami.com/bitnami` | Chart từ Helm repository |
| **Git Repo** | `repoURL: https://github.com/user/repo.git` | Chart nằm trong Git repo |
| **OCI Registry** | `repoURL: oci://registry.example.com/charts` | Chart dạng OCI |

### Override Values

```yaml
# Cách 1: Inline values trong Application
spec:
  source:
    helm:
      values: |
        replicaCount: 3
        service:
          type: NodePort

# Cách 2: valueFiles
spec:
  source:
    helm:
      valueFiles:
        - values-production.yaml

# Cách 3: parameters (từng key)
spec:
  source:
    helm:
      parameters:
        - name: replicaCount
          value: "3"
        - name: service.type
          value: NodePort
```

---

## 🔧 Thực hành

### Bước 1: Deploy Redis bằng Helm qua ArgoCD

```bash
# Áp dụng Application cho Redis
kubectl apply -f argocd/helm-app-redis.yaml

# Hoặc qua CLI
argocd app create redis \
  --repo https://charts.bitnami.com/bitnami \
  --helm-chart redis \
  --revision 19.6.4 \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace redis \
  --sync-option CreateNamespace=true \
  --helm-set architecture=standalone \
  --helm-set auth.enabled=false

# Sync
argocd app sync redis
```

### Bước 2: Kiểm tra

```bash
# Xem app status
argocd app get redis

# Xem pods
kubectl get pods -n redis

# Test Redis
kubectl exec -it redis-master-0 -n redis -- redis-cli ping
# → PONG
```

### Bước 3: Override values từ UI

1. Mở ArgoCD UI → Click vào app `redis`
2. Click **APP DETAILS** → **PARAMETERS**
3. Thay đổi giá trị, ví dụ: `replica.replicaCount` = `2`
4. Click **SAVE** → **SYNC**

### Bước 4: Deploy WordPress (Nâng cao)

```bash
kubectl apply -f argocd/helm-app-wordpress.yaml
argocd app sync wordpress
```

---

## ❓ FAQ

### Q: Có cần cài Helm CLI trên máy để ArgoCD chạy không?
**A:** **Không!** ArgoCD tự tích hợp Helm engine bên trong. Nó chạy `helm template` (không phải `helm install`) rồi apply YAML trực tiếp. Bạn chỉ cần Helm CLI nếu muốn debug template locally.

### Q: Khi nào nên dùng Helm qua ArgoCD thay vì `helm install` thẳng?
**A:** Luôn luôn dùng ArgoCD nếu bạn theo GitOps! `helm install` không có audit trail, drift detection, hay rollback tự động.

### Q: Helm hooks có hoạt động với ArgoCD không?
**A:** Có, nhưng ArgoCD chuyển đổi Helm hooks thành [ArgoCD resource hooks](https://argo-cd.readthedocs.io/en/stable/user-guide/resource_hooks/). Hành vi có thể hơi khác.

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 03 — Sync Strategies & Phục hồi sự cố](../day-03/)
> **⏭️ Ngày tiếp:** [Day 05 — Kustomize](../day-05/)

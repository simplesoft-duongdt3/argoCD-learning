# ✏️ Bài tập Ngày 10: Canary & Blue/Green Deployment

## 🎯 Mục tiêu
- Deploy Canary rollout và quan sát traffic shifting
- Thực hiện Rollback khi Canary lỗi
- Deploy Blue/Green rollout

---

## Bài tập 1: Canary Deployment

1. Cài Argo Rollouts:
   ```bash
   chmod +x scripts/*.sh
   ./scripts/install-argo-rollouts.sh
   ./scripts/verify.sh
   ```

2. Deploy Canary:
   ```bash
   kubectl create namespace canary-demo
   kubectl apply -f manifests/rollout-canary.yaml -n canary-demo
   kubectl apply -f manifests/service.yaml -n canary-demo
   ```

3. Kiểm tra trạng thái:
   ```bash
   kubectl argo rollouts get rollout canary-demo -n canary-demo --watch
   ```

4. Trigger update (đổi image):
   ```bash
   kubectl argo rollouts set image canary-demo \
     canary-demo=argoproj/rollouts-demo:yellow \
     -n canary-demo
   ```

5. Quan sát canary steps:
   - 10% traffic → pause 60s
   - 30% traffic → pause 60s
   - 60% traffic → **chờ manual promote**

6. Promote:
   ```bash
   kubectl argo rollouts promote canary-demo -n canary-demo
   ```

---

## Bài tập 2: Rollback khi Canary lỗi 🚨

1. Trigger update mới:
   ```bash
   kubectl argo rollouts set image canary-demo \
     canary-demo=argoproj/rollouts-demo:red \
     -n canary-demo
   ```

2. Trong khi canary đang ở 10-30%, **abort** ngay:
   ```bash
   kubectl argo rollouts abort canary-demo -n canary-demo
   ```

3. Kiểm tra rollback thành công:
   ```bash
   kubectl argo rollouts get rollout canary-demo -n canary-demo
   # → Status: Degraded (abort) hoặc đã rollback về version trước
   ```

4. Retry để quay lại trạng thái Healthy:
   ```bash
   kubectl argo rollouts retry rollout canary-demo -n canary-demo
   ```

---

## Bài tập 3: Blue/Green Deployment

1. Deploy Blue/Green:
   ```bash
   kubectl create namespace bluegreen-demo
   kubectl apply -f manifests/rollout-bluegreen.yaml -n bluegreen-demo
   ```

2. Port-forward 2 services:
   ```bash
   # Active (Blue)
   kubectl port-forward svc/bluegreen-active -n bluegreen-demo 9091:80 &
   
   # Preview (Green)
   kubectl port-forward svc/bluegreen-preview -n bluegreen-demo 9092:80 &
   ```

3. Trigger update:
   ```bash
   kubectl argo rollouts set image bluegreen-demo \
     bluegreen-demo=argoproj/rollouts-demo:green \
     -n bluegreen-demo
   ```

4. Kiểm tra:
   - `http://localhost:9091` → Blue (version cũ)
   - `http://localhost:9092` → Green (version mới, đang preview)

5. Promote:
   ```bash
   kubectl argo rollouts promote bluegreen-demo -n bluegreen-demo
   ```

6. Sau promote: cả 2 URL đều trỏ về Green

---

## Bài tập 4: Dashboard UI

```bash
kubectl argo rollouts dashboard &
# Mở http://localhost:3100
# Xem visualization của rollout process
```

---

## ✅ Checklist hoàn thành

- [ ] Argo Rollouts cài thành công
- [ ] Canary deployment chạy với traffic shifting
- [ ] Rollback (abort) canary thành công
- [ ] Blue/Green deployment chạy
- [ ] Preview vs Active service hoạt động đúng
- [ ] Promote Blue/Green thành công

---

> 🎉 **Chúc mừng! Bạn đã hoàn thành khóa học ArgoCD 10 ngày!**
>
> Bạn đã nắm được:
> - ✅ GitOps fundamentals
> - ✅ ArgoCD installation & configuration
> - ✅ Sync strategies & self-healing
> - ✅ Helm & Kustomize integration
> - ✅ Multi-cluster management
> - ✅ App of Apps & ApplicationSet patterns
> - ✅ RBAC & security
> - ✅ Progressive delivery (Canary & Blue/Green)

# ✏️ Bài tập Ngày 3: Sync Strategies & Phục hồi sự cố

## 🎯 Mục tiêu
- Cấu hình Self-heal cho ứng dụng
- Cấu hình Prune cho ứng dụng
- Quan sát ArgoCD tự phục hồi sau sự cố

---

## Bài tập 1: Bật Auto Sync + Self-heal

1. Áp dụng Application với auto-sync:
   ```bash
   kubectl apply -f argocd/application-auto-sync.yaml
   ```

2. Kiểm tra cấu hình:
   ```bash
   argocd app get nginx-demo -o yaml | grep -A5 syncPolicy
   ```

**Kết quả mong đợi:** `selfHeal: true`, `prune: true`

---

## Bài tập 2: Test Self-heal

1. Xóa tất cả pods:
   ```bash
   kubectl delete pods --all -n demo-app
   ```

2. Quan sát trên ArgoCD UI: status chuyển từ Healthy → Progressing → Healthy

3. Kiểm tra pods đã được tạo lại:
   ```bash
   kubectl get pods -n demo-app
   ```

4. Thử scale trực tiếp:
   ```bash
   kubectl scale deployment nginx-demo -n demo-app --replicas=10
   sleep 15
   kubectl get pods -n demo-app
   # → ArgoCD rollback về 2 replicas
   ```

---

## Bài tập 3: Test Prune

1. Kiểm tra ConfigMap tồn tại:
   ```bash
   kubectl get configmap nginx-config -n demo-app
   ```

2. Trên Git repo, xóa phần ConfigMap khỏi manifest, commit & push

3. Chờ ArgoCD auto-sync (hoặc `argocd app sync nginx-demo`)

4. Kiểm tra ConfigMap đã bị xóa:
   ```bash
   kubectl get configmap nginx-config -n demo-app
   # Expected: Error from server (NotFound)
   ```

---

## Bài tập 4: Chống Prune cho resource quan trọng

1. Thêm annotation vào Service để ngăn ArgoCD xóa:
   ```yaml
   metadata:
     annotations:
       argocd.argoproj.io/sync-options: Prune=false
   ```

2. Xóa Service khỏi Git, commit & push

3. Kiểm tra Service vẫn tồn tại trên cluster (vì Prune=false)

---

## ✅ Checklist hoàn thành

- [ ] Bật Auto Sync + Self-heal + Prune thành công
- [ ] Xóa pods → ArgoCD tự tạo lại
- [ ] Scale trực tiếp → ArgoCD rollback về giá trị Git
- [ ] Xóa resource khỏi Git → Prune xóa trên cluster
- [ ] Annotation Prune=false ngăn xóa thành công

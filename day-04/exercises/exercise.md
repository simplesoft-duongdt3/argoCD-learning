# ✏️ Bài tập Ngày 4: Helm Charts với ArgoCD

## 🎯 Mục tiêu
- Deploy Redis bằng Helm qua ArgoCD
- Override values trực tiếp từ ArgoCD UI
- Hiểu cách ArgoCD render Helm template

---

## Bài tập 1: Deploy Redis

1. Apply Application:
   ```bash
   kubectl apply -f argocd/helm-app-redis.yaml
   ```

2. Chờ sync hoàn tất:
   ```bash
   argocd app wait redis --health
   ```

3. Test Redis:
   ```bash
   kubectl exec -it redis-master-0 -n redis -- redis-cli
   > SET hello "ArgoCD Day 4"
   > GET hello
   > exit
   ```

---

## Bài tập 2: Override Values từ UI

1. Mở ArgoCD UI → Click app `redis`
2. Click **APP DETAILS** → Tab **PARAMETERS**
3. Thử thay đổi:
   - Tìm parameter `auth.enabled` → Đổi thành `true`
   - Click **SAVE**
4. Quan sát ArgoCD tự sync thay đổi
5. Test lại Redis (lúc này cần password):
   ```bash
   kubectl exec -it redis-master-0 -n redis -- redis-cli
   > AUTH <password>
   ```

---

## Bài tập 3: Xem Helm Template đã render

```bash
# Xem manifest đã được ArgoCD render
argocd app manifests redis

# So sánh với helm template local (nếu có Helm CLI)
helm template redis oci://registry-1.docker.io/bitnamicharts/redis \
  --values helm/custom-values.yaml
```

---

## Bài tập 4: Deploy WordPress (Nâng cao)

1. Apply Application:
   ```bash
   kubectl apply -f argocd/helm-app-wordpress.yaml
   ```

2. Chờ sync (~3-5 phút):
   ```bash
   argocd app wait wordpress --health --timeout 300
   ```

3. Truy cập WordPress:
   ```bash
   kubectl port-forward svc/wordpress -n wordpress 8888:80 &
   # Mở http://localhost:8888
   # Login: admin / argocd-demo
   ```

---

## ✅ Checklist hoàn thành

- [ ] Redis deploy thành công qua Helm + ArgoCD
- [ ] Test Redis CLI (SET/GET) thành công
- [ ] Override values từ UI thành công
- [ ] Xem được rendered manifests
- [ ] (Nâng cao) WordPress deploy thành công

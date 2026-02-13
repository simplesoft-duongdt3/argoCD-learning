# 📅 Ngày 3: Sync Strategies & Phục Hồi Sự Cố

## 🎯 Mục tiêu hôm nay
- Hiểu sự khác nhau giữa Manual Sync vs Automatic Sync
- Cấu hình Self-heal và Prune
- Quan sát ArgoCD tự phục hồi khi có ai đó xóa tay resource

---

## 📖 Lý thuyết

### Sync Strategies

```
┌─────────────────────────────────────────────────────────────┐
│                    SYNC STRATEGIES                          │
│                                                             │
│  ┌─────────────────┐     ┌──────────────────────────────┐   │
│  │ MANUAL SYNC     │     │ AUTOMATIC SYNC               │   │
│  │                 │     │                              │   │
│  │ • User click    │     │ • ArgoCD tự sync khi Git     │   │
│  │   "SYNC" button │     │   thay đổi                   │   │
│  │ • An toàn hơn   │     │ • Nhanh hơn                  │   │
│  │ • Cho production│     │ • Cho dev/staging             │   │
│  └─────────────────┘     └──────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │ SYNC OPTIONS                                        │    │
│  │                                                     │    │
│  │ 🔄 Self-heal: Tự sửa khi cluster bị drift          │    │
│  │    (ai đó kubectl edit/delete trực tiếp)            │    │
│  │                                                     │    │
│  │ 🗑️  Prune: Tự xóa resource trên cluster khi        │    │
│  │    resource đó bị xóa khỏi Git                     │    │
│  │                                                     │    │
│  │ ⚠️  Prune + Self-heal = Full automation             │    │
│  │    (Cẩn thận khi dùng trên production!)             │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

### So sánh các Sync Options

| Option | Mô tả | Rủi ro | Khuyến nghị |
|--------|--------|--------|-------------|
| **Manual Sync** | User phải click Sync | Chậm | Production |
| **Auto Sync** | Tự sync khi Git thay đổi | Trung bình | Staging |
| **Self-heal** | Tự sửa khi cluster bị thay đổi trực tiếp | Thấp | Mọi môi trường |
| **Prune** | Tự xóa resource không còn trong Git | **Cao** | Cẩn thận! |

### Self-heal hoạt động như thế nào?

```
Developer (accidentally):
  kubectl delete pod nginx-demo-xxx -n demo-app
  
ArgoCD (5 giây sau):
  ⚠️ Cluster drift detected!
  🔄 Re-syncing to match Git state...
  ✅ Pod recreated automatically
```

### Prune hoạt động như thế nào?

```
Trước:
  Git: deployment.yaml, service.yaml, configmap.yaml
  Cluster: Deployment, Service, ConfigMap

Sau khi xóa configmap.yaml khỏi Git:
  Git: deployment.yaml, service.yaml
  
  Prune=false: Cluster vẫn có ConfigMap (orphaned resource)
  Prune=true:  Cluster tự xóa ConfigMap ✅
```

---

## 🔧 Thực hành

### Bước 1: Deploy ứng dụng với Manual Sync (từ Day 02)

```bash
# Kiểm tra app từ day-02 vẫn đang chạy
argocd app get nginx-demo

# Nếu chưa có, tạo lại
kubectl apply -f ../day-02/argocd/application.yaml
argocd app sync nginx-demo
```

### Bước 2: Cấu hình Automatic Sync + Self-heal + Prune

```bash
# Áp dụng Application mới với auto-sync
kubectl apply -f argocd/application-auto-sync.yaml
```

Hoặc cập nhật app hiện tại qua CLI:
```bash
argocd app set nginx-demo \
  --sync-policy automated \
  --self-heal \
  --auto-prune
```

### Bước 3: Test Self-heal 🔥

```bash
# Xóa TẤT CẢ pods (mô phỏng sự cố)
kubectl delete pods --all -n demo-app
echo "⏳ Chờ 10 giây..."
sleep 10

# ArgoCD sẽ tự tạo lại pods!
kubectl get pods -n demo-app
# → Pods mới đã được tạo tự động
```

```bash
# Thử thay đổi replicas trực tiếp trên cluster
kubectl scale deployment nginx-demo -n demo-app --replicas=5
echo "⏳ Chờ 15 giây..."
sleep 15

# ArgoCD sẽ rollback về giá trị trong Git (replicas: 2)
kubectl get pods -n demo-app
# → Chỉ còn 2 pods
```

### Bước 4: Test Prune

```bash
# 1. Tạo thêm một ConfigMap trong Git repo
cat <<EOF > /tmp/test-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: test-config
  namespace: demo-app
data:
  environment: "testing"
EOF

# 2. Thêm vào Git, commit, push
# 3. Chờ ArgoCD auto-sync (hoặc manual sync)
# 4. Kiểm tra ConfigMap đã được tạo
kubectl get configmap test-config -n demo-app

# 5. Xóa file configmap khỏi Git, commit, push
# 6. Chờ ArgoCD auto-sync
# 7. ConfigMap sẽ tự bị xóa (vì Prune=true)
kubectl get configmap test-config -n demo-app  # Not Found
```

---

## ❓ FAQ

### Q: `Prune` có nguy hiểm không?
**A:** Có! Nếu bạn **vô tình xóa file YAML khỏi Git**, ArgoCD sẽ xóa resource tương ứng trên cluster. Best practice:
- **Dev/Staging:** Bật Prune an toàn
- **Production:** Dùng `Prune` với annotation chống xóa:
  ```yaml
  metadata:
    annotations:
      argocd.argoproj.io/sync-options: Prune=false
  ```

### Q: Self-heal có ảnh hưởng performance không?
**A:** Không đáng kể. ArgoCD kiểm tra drift mỗi vài giây nhưng chỉ reconcile khi phát hiện thay đổi.

### Q: Làm sao tắt Auto-sync tạm thời?
**A:** Dùng CLI:
```bash
argocd app set nginx-demo --sync-policy none
```

---

## 📚 Bài tập & Ôn tập

- [📝 Bài tập thực hành](exercises/exercise.md)
- [❓ Câu hỏi ôn tập (30 câu)](questions.md)

---

> **⏮️ Ngày trước:** [Day 02 — Kết nối Repository & Ứng dụng đầu tiên](../day-02/)
> **⏭️ Ngày tiếp:** [Day 04 — Làm việc với Helm Charts](../day-04/)

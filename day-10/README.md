# 📅 Ngày 10: Triển Khai Nâng Cao — Canary & Blue/Green

## 🎯 Mục tiêu hôm nay
- Hiểu Argo Rollouts và sự khác biệt với ArgoCD
- Cấu hình Canary deployment (10% traffic)
- Cấu hình Blue/Green deployment
- Thực hiện Rollback khi Canary lỗi

---

## 📖 Lý thuyết

### Vấn đề với Kubernetes Deployment

Kubernetes Deployment mặc định dùng **Rolling Update**: thay thế pods cũ dần dần. Nhưng:
- ❌ Không kiểm soát được % traffic
- ❌ Không có analysis tự động (kiểm tra lỗi trước khi chuyển hoàn toàn)
- ❌ Rollback chậm

### Argo Rollouts

**Argo Rollouts** là Kubernetes controller bổ sung các chiến lược deploy nâng cao:

```
┌────────────────────────────────────────────────────────┐
│              DEPLOYMENT STRATEGIES                     │
│                                                        │
│  ┌──────────────────┐  ┌────────────────────────────┐  │
│  │  CANARY           │  │  BLUE/GREEN                │  │
│  │                   │  │                            │  │
│  │  10% → 30% → 100%│  │  Blue (old) ──┐            │  │
│  │                   │  │               ├→ Switch    │  │
│  │  Dần dần chuyển   │  │  Green (new)──┘            │  │
│  │  traffic sang     │  │                            │  │
│  │  phiên bản mới    │  │  Chuyển đổi                │  │
│  │                   │  │  ngay lập tức              │  │
│  └──────────────────┘  └────────────────────────────┘  │
│                                                        │
│  ┌──────────────────────────────────────────────────┐  │
│  │  ArgoCD vs Argo Rollouts                         │  │
│  │                                                  │  │
│  │  ArgoCD:     GitOps CD tool (sync Git → K8s)     │  │
│  │  Rollouts:   Progressive delivery controller     │  │
│  │                                                  │  │
│  │  Chúng BỔ TRỢ nhau, không thay thế nhau!        │  │
│  └──────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────┘
```

### Canary Flow

```
Step 1: setWeight 10%   ──→  10% users thấy version mới
        pause: {duration: 60s}     (chờ 60s, kiểm tra metrics)
        
Step 2: setWeight 30%   ──→  30% users thấy version mới
        pause: {duration: 60s}

Step 3: setWeight 60%   ──→  60% users thấy version mới
        pause: {}              (chờ manual promote)
        
Step 4: setWeight 100%  ──→  100% users chuyển sang version mới
```

### Blue/Green Flow

```
Trước:
  ┌─────────────┐          ┌─────────────┐
  │ Blue (v1)   │ ◄── LB ──│  Users      │
  │ ACTIVE      │          │             │
  └─────────────┘          └─────────────┘
  ┌─────────────┐
  │ Green (v2)  │  ← Preview (testing)
  │ PREVIEW     │
  └─────────────┘

Sau khi promote:
  ┌─────────────┐
  │ Blue (v1)   │  ← Sẽ bị scale down
  │ OLD         │
  └─────────────┘
  ┌─────────────┐          ┌─────────────┐
  │ Green (v2)  │ ◄── LB ──│  Users      │
  │ ACTIVE      │          │             │
  └─────────────┘          └─────────────┘
```

---

## 🔧 Thực hành

### Bước 1: Cài đặt Argo Rollouts

```bash
chmod +x scripts/install-argo-rollouts.sh
./scripts/install-argo-rollouts.sh
```

### Bước 2: Deploy Canary Rollout

```bash
# Tạo namespace
kubectl create namespace canary-demo

# Deploy Rollout + Service
kubectl apply -f manifests/rollout-canary.yaml -n canary-demo
kubectl apply -f manifests/service.yaml -n canary-demo

# Xem status
kubectl argo rollouts get rollout canary-demo -n canary-demo --watch
```

### Bước 3: Trigger Canary Update

```bash
# Cập nhật image → trigger canary
kubectl argo rollouts set image canary-demo \
  canary-demo=argoproj/rollouts-demo:yellow \
  -n canary-demo

# Quan sát canary steps
kubectl argo rollouts get rollout canary-demo -n canary-demo --watch
# → Thấy 10% traffic → 30% → pause (chờ promote)
```

### Bước 4: Promote hoặc Abort

```bash
# Promote: chuyển 100% traffic sang version mới
kubectl argo rollouts promote canary-demo -n canary-demo

# HOẶC Abort: rollback ngay lập tức
kubectl argo rollouts abort canary-demo -n canary-demo
```

### Bước 5: Deploy Blue/Green Rollout

```bash
# Tạo namespace
kubectl create namespace bluegreen-demo

# Deploy
kubectl apply -f manifests/rollout-bluegreen.yaml -n bluegreen-demo

# Trigger update
kubectl argo rollouts set image bluegreen-demo \
  bluegreen-demo=argoproj/rollouts-demo:green \
  -n bluegreen-demo

# Xem preview
kubectl argo rollouts get rollout bluegreen-demo -n bluegreen-demo --watch

# Promote
kubectl argo rollouts promote bluegreen-demo -n bluegreen-demo
```

### Bước 6: Argo Rollouts Dashboard (UI)

```bash
# Mở dashboard
kubectl argo rollouts dashboard -n canary-demo &
# Truy cập: http://localhost:3100
```

---

## ❓ FAQ

### Q: Sự khác biệt giữa ArgoCD và Argo Rollouts?
**A:**
| | ArgoCD | Argo Rollouts |
|---|--------|---------------|
| **Chức năng** | GitOps CD | Progressive Delivery |
| **Quản lý** | Git → K8s sync | Traffic shifting |
| **Resource** | Application | Rollout |
| **Quan hệ** | Bổ trợ nhau! | Bổ trợ nhau! |

**Flow kết hợp:** Git commit → ArgoCD sync → Argo Rollouts thực hiện canary/blue-green

### Q: Có cần Istio/Nginx Ingress cho Canary không?
**A:** Argo Rollouts hỗ trợ nhiều traffic managers:
- **Không cần gì**: Dùng basic replica-based splitting
- **Nginx Ingress**: Canary header/weight-based
- **Istio**: VirtualService traffic splitting (chính xác nhất)
- **AWS ALB**: Weighted target groups

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 09 — Bảo mật (RBAC & Projects)](../day-09/)
>
> 🎉 **Chúc mừng bạn đã hoàn thành khóa học ArgoCD 10 ngày!**

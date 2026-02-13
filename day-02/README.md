# 📅 Ngày 2: Kết Nối Repository & Ứng Dụng Đầu Tiên

## 🎯 Mục tiêu hôm nay
- Hiểu khái niệm "Application" trong ArgoCD
- Kết nối Git repository (Public & Private)
- Deploy ứng dụng Nginx đầu tiên qua ArgoCD

---

## 📖 Lý thuyết

### Application trong ArgoCD

**Application** là đơn vị cơ bản nhất trong ArgoCD. Nó định nghĩa:

| Thành phần | Mô tả |
|------------|--------|
| **Source** | Git repo + path chứa manifests |
| **Destination** | Cluster + namespace để deploy |
| **Sync Policy** | Manual hay Automatic |

```yaml
# Cấu trúc cơ bản của một Application
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  source:
    repoURL: https://github.com/user/repo.git   # Lấy YAML từ đâu?
    targetRevision: HEAD                          # Branch nào?
    path: manifests                               # Thư mục nào?
  destination:
    server: https://kubernetes.default.svc        # Deploy lên cluster nào?
    namespace: default                            # Namespace nào?
```

### Application States (Trạng thái)

```
┌──────────────────────────────────────────────────────────────┐
│                    ArgoCD App States                         │
│                                                              │
│  Sync Status:                                                │
│  ┌──────────┐  ┌───────────────┐  ┌───────────────────────┐  │
│  │ Synced   │  │ OutOfSync     │  │ Unknown               │  │
│  │ (Git=K8s)│  │ (Git≠K8s)     │  │ (Chưa biết)           │  │
│  └──────────┘  └───────────────┘  └───────────────────────┘  │
│                                                              │
│  Health Status:                                              │
│  ┌──────────┐  ┌───────────────┐  ┌───────────────────────┐  │
│  │ Healthy  │  │ Progressing   │  │ Degraded              │  │
│  │ (OK)     │  │ (Đang chạy)   │  │ (Có lỗi)              │  │
│  └──────────┘  └───────────────┘  └───────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

### Webhook vs Polling

| | Webhook | Polling |
|---|---------|---------|
| **Cách hoạt động** | GitHub gửi thông báo khi có push | ArgoCD tự kiểm tra Git mỗi 3 phút |
| **Tốc độ** | Gần như tức thì | Delay tối đa 3 phút |
| **Setup** | Cần cấu hình webhook trên GitHub | Mặc định, không cần cấu hình |
| **Khi nào nên dùng** | Production | Development/Learning |

---

## 🔧 Thực hành

### Bước 1: Chuẩn bị manifests ứng dụng

Trong thư mục này đã có sẵn các file manifests cho ứng dụng Nginx:

```bash
# Xem cấu trúc
ls manifests/
# namespace.yaml  deployment.yaml  service.yaml
```

### Bước 2: Push manifests lên Git

```bash
# Tạo một repo mới trên GitHub (ví dụ: argocd-demo-app)
# Sau đó push các file manifests lên

mkdir -p /tmp/argocd-demo-app/manifests
cp manifests/* /tmp/argocd-demo-app/manifests/

cd /tmp/argocd-demo-app
git init
git add .
git commit -m "Initial commit: Nginx app manifests"
git remote add origin https://github.com/<YOUR_USERNAME>/argocd-demo-app.git
git push -u origin main
```

### Bước 3: Tạo Application trên ArgoCD

**Cách 1: Qua CLI**
```bash
argocd app create nginx-demo \
  --repo https://github.com/<YOUR_USERNAME>/argocd-demo-app.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace demo-app
```

**Cách 2: Qua YAML (khuyến nghị)**
```bash
# Sửa file argocd/application.yaml với repo URL của bạn
kubectl apply -f argocd/application.yaml
```

**Cách 3: Qua UI**
1. Mở ArgoCD UI → Click **"+ NEW APP"**
2. Điền thông tin:
   - Application Name: `nginx-demo`
   - Project: `default`
   - Repository URL: `https://github.com/<YOUR_USERNAME>/argocd-demo-app.git`
   - Path: `manifests`
   - Cluster: `https://kubernetes.default.svc`
   - Namespace: `demo-app`
3. Click **CREATE**

### Bước 4: Sync Application

```bash
# Sync qua CLI
argocd app sync nginx-demo

# Hoặc click "SYNC" trên UI

# Kiểm tra trạng thái
argocd app get nginx-demo
kubectl get all -n demo-app
```

### Bước 5: Kết nối Private Repository (Nâng cao)

```bash
# Kết nối repo private bằng HTTPS + token
argocd repo add https://github.com/<YOUR_USERNAME>/private-repo.git \
  --username <USERNAME> \
  --password <GITHUB_TOKEN>

# Hoặc bằng SSH key
argocd repo add git@github.com:<YOUR_USERNAME>/private-repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa
```

---

## ❓ FAQ

### Q: Làm sao để ArgoCD tự động nhận diện thay đổi code?
**A:** Có 2 cách:
- **Polling (mặc định):** ArgoCD kiểm tra Git mỗi 3 phút. Cấu hình thời gian trong `argocd-cm` ConfigMap.
- **Webhook:** GitHub gửi notification khi có push. Setup nhanh hơn polling.

### Q: Application bị "Unknown" status là sao?
**A:** Thường do ArgoCD chưa kết nối được Git repo hoặc path sai. Kiểm tra lại URL repo và path.

### Q: Có thể deploy nhiều Application từ cùng 1 repo không?
**A:** Có! Mỗi Application trỏ đến một `path` khác nhau trong cùng repo.

---

## ✏️ Bài tập

Xem file [exercises/exercise.md](exercises/exercise.md)

---

> **⏮️ Ngày trước:** [Day 01 — Nhập môn GitOps & Cài đặt ArgoCD](../day-01/)
> **⏭️ Ngày tiếp:** [Day 03 — Sync Strategies & Phục hồi sự cố](../day-03/)

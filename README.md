# 🚀 Khóa Học ArgoCD 10 Ngày — Làm Chủ GitOps Từ Số 0

## 📋 Giới thiệu

Đây là khóa học **ArgoCD thực hành** được thiết kế để bạn có thể **tiến hành ngay** mỗi ngày mà không cần tìm kiếm thêm tài liệu. Mỗi thư mục `day-XX/` chứa đầy đủ:

- 📖 **README.md** — Lý thuyết + FAQ + hướng dẫn từng bước
- 📁 **manifests/** — File YAML sẵn sàng `kubectl apply`
- 🔧 **scripts/** — Script tự động hóa setup/verify/cleanup
- ✏️ **exercises/** — Bài tập thực hành + đáp án

---

## 🛠️ Yêu cầu trước khi bắt đầu (Prerequisites)

### Phần mềm cần cài đặt

| Tool | Mục đích | Cài đặt |
|------|----------|---------|
| **Docker** | Container runtime | [docker.com/get-docker](https://docs.docker.com/get-docker/) |
| **Minikube** | Local K8s cluster | `brew install minikube` hoặc [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| **kubectl** | K8s CLI | `brew install kubectl` |
| **Helm** (Day 4) | Package manager | `brew install helm` |
| **Git** | Source control | `brew install git` |

### Khởi tạo Minikube

```bash
# Tạo cluster với đủ tài nguyên cho ArgoCD
minikube start --cpus=4 --memory=8192 --driver=docker

# Kiểm tra cluster đã sẵn sàng
kubectl cluster-info
kubectl get nodes
```

---

## 📅 Lộ Trình 10 Ngày

| Ngày | Chủ đề | Thư mục |
|------|--------|---------|
| **Day 01** | 🏁 Nhập môn GitOps & Cài đặt ArgoCD | [day-01/](day-01/) |
| **Day 02** | 🔗 Kết nối Repository & Ứng dụng đầu tiên | [day-02/](day-02/) |
| **Day 03** | 🔄 Sync Strategies & Phục hồi sự cố | [day-03/](day-03/) |
| **Day 04** | ⎈ Làm việc với Helm Charts | [day-04/](day-04/) |
| **Day 05** | 🎯 Kustomize — "Vũ khí" bí mật | [day-05/](day-05/) |
| **Day 06** | 🌐 Quản lý nhiều Cluster (Multi-cluster) | [day-06/](day-06/) |
| **Day 07** | 🏗️ App of Apps Pattern | [day-07/](day-07/) |
| **Day 08** | ⚡ ApplicationSet & Tự động hóa quy mô lớn | [day-08/](day-08/) |
| **Day 09** | 🔒 Bảo mật (RBAC & Projects) | [day-09/](day-09/) |
| **Day 10** | 🚀 Triển khai Canary & Blue/Green | [day-10/](day-10/) |

---

## 📌 Cách sử dụng

```bash
# 1. Clone repository
git clone <YOUR_REPO_URL>
cd argoCD

# 2. Bắt đầu từ Day 01
cd day-01
cat README.md

# 3. Chạy script setup (nếu có)
chmod +x scripts/*.sh
./scripts/install-argocd.sh

# 4. Làm bài tập
cat exercises/exercise.md
```

> **💡 Tip:** Mỗi ngày nên dành **2-3 giờ** để đọc lý thuyết, thực hành, và hoàn thành bài tập.

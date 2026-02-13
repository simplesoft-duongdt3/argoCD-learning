# 🚀 Khóa Học ArgoCD 10 Ngày — Làm Chủ GitOps Từ Số 0

## 📋 Giới thiệu

Đây là khóa học **ArgoCD thực hành** được thiết kế để bạn có thể **tiến hành ngay** mỗi ngày mà không cần tìm kiếm thêm tài liệu. Mỗi thư mục `day-XX/` chứa đầy đủ:

- 📖 **README.md** — Lý thuyết + FAQ + hướng dẫn từng bước
- 📁 **manifests/** — File YAML sẵn sàng `kubectl apply`
- 🔧 **scripts/** — Script tự động hóa setup/verify/cleanup
- ✏️ **exercises/** — Bài tập thực hành + checklist hoàn thành
- ❓ **questions.md** — 30 câu hỏi ôn tập kèm đáp án chi tiết

---

## 🛠️ Yêu cầu trước khi bắt đầu (Prerequisites)

### Phần mềm cần cài đặt

| Tool | Mục đích | Cài đặt |
|------|----------|---------|
| **Docker** | Container runtime | [docker.com/get-docker](https://docs.docker.com/get-docker/) |
| **Minikube** | Local K8s cluster | `brew install minikube` hoặc [minikube.sigs.k8s.io](https://minikube.sigs.k8s.io/docs/start/) |
| **kubectl** | K8s CLI | `brew install kubectl` |
| **Helm** (Day 4+) | Package manager | `brew install helm` |
| **Git** | Source control | `brew install git` |
| **ArgoCD CLI** | ArgoCD command line | `brew install argocd` |

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

| Ngày | Chủ đề | Nội dung chính | Thư mục |
|------|--------|----------------|---------|
| **01** | 🏁 Nhập môn GitOps & Cài đặt ArgoCD | GitOps fundamentals, ArgoCD architecture, installation | [day-01/](day-01/) |
| **02** | 🔗 Kết nối Repository & Ứng dụng đầu tiên | Application CRD, Git connection, first deploy | [day-02/](day-02/) |
| **03** | 🔄 Sync Strategies & Phục hồi sự cố | Manual/Auto sync, Self-heal, Prune | [day-03/](day-03/) |
| **04** | ⎈ Làm việc với Helm Charts | Helm repo, Git charts, override values | [day-04/](day-04/) |
| **05** | 🎯 Kustomize — Base & Overlays | Multi-env config, dev/prod overlays | [day-05/](day-05/) |
| **06** | 🌐 Quản lý nhiều Cluster | Hub-and-Spoke, cross-cluster deploy | [day-06/](day-06/) |
| **07** | 🏗️ App of Apps Pattern | Root app, child apps, Git structure | [day-07/](day-07/) |
| **08** | ⚡ ApplicationSet | List, Git, Cluster generators | [day-08/](day-08/) |
| **09** | 🔒 Bảo mật (RBAC & Projects) | AppProject, RBAC policies, SSO | [day-09/](day-09/) |
| **10** | 🚀 Canary & Blue/Green | Argo Rollouts, progressive delivery | [day-10/](day-10/) |

---

## 📂 Cấu trúc mỗi ngày

```
day-XX/
├── README.md              # Lý thuyết + hướng dẫn thực hành
├── questions.md            # 30 câu hỏi ôn tập (có đáp án)
├── exercises/
│   └── exercise.md         # Bài tập thực hành + checklist
├── manifests/ hoặc argocd/ # YAML files sẵn sàng dùng
└── scripts/                # Automation scripts
```

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

# 5. Ôn tập với câu hỏi
cat questions.md
```

---

## 📊 Thống kê khóa học

| Metric | Số lượng |
|--------|----------|
| 📖 Tổng ngày học | 10 |
| 📁 Tổng số files | 75+ |
| ❓ Tổng câu hỏi ôn tập | 300 |
| ✏️ Tổng bài tập | 30+ |
| 🔧 Scripts tự động | 8 |

---

> **💡 Tip:** Mỗi ngày nên dành **2-3 giờ** để đọc lý thuyết, thực hành, hoàn thành bài tập, và trả lời câu hỏi ôn tập.

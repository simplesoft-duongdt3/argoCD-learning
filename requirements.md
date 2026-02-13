Dưới đây là lộ trình 10 ngày được thiết kế tinh gọn, tập trung vào thực hành thực tế để bạn có thể làm chủ ArgoCD từ con số 0.

---

# 🚀 Lộ Trình 10 Ngày Làm Chủ ArgoCD (GitOps)

## 📅 Ngày 1: Nhập môn GitOps & Cài đặt ArgoCD

* **Lý thuyết:** GitOps là gì? Tại sao cần ArgoCD thay vì dùng `kubectl apply` truyền thống?
* **Thực hành:** Cài đặt ArgoCD lên Cluster (Minikube/K3s) bằng Manifest hoặc Helm.
* **FAQ:** ArgoCD có thay thế Jenkins/GitLab CI không? (Trả lời: Không, nó bổ trợ cho phần CD).
* **Bài tập:** Login vào UI và đổi mật khẩu admin qua CLI.

## 📅 Ngày 2: Kết nối Repository & Ứng dụng đầu tiên

* **Lý thuyết:** Khái niệm "Application" trong ArgoCD.
* **Thực hành:** Kết nối Github Repo (Public/Private) và deploy một ứng dụng Nginx đơn giản.
* **FAQ:** Làm sao để ArgoCD tự động nhận diện thay đổi code? (Webhook vs Polling).
* **Bài tập:** Tạo một Deployment và Service, đẩy lên Git và xem ArgoCD tự động "Sync".

## 📅 Ngày 3: Sync Strategies & Phục hồi sự cố

* **Lý thuyết:** Manual vs Automatic Sync, Prune Resources, Self-heal.
* **Thực hành:** Thử xóa tay một Pod/Service trên Cluster và xem ArgoCD tự động tạo lại.
* **FAQ:** `Prune` có nguy hiểm không? (Có, nếu không cấu hình kỹ).
* **Bài tập:** Cấu hình `Self-heal` và `Prune` cho ứng dụng ngày 2.

## 📅 Ngày 4: Làm việc với Helm Charts

* **Lý thuyết:** Cách ArgoCD render Helm template.
* **Thực hành:** Deploy một ứng dụng phức tạp (ví dụ: Redis hoặc Bitnami WordPress) bằng Helm qua ArgoCD.
* **FAQ:** Có cần cài Helm CLI trên máy để ArgoCD chạy không? (Trả lời: Không, ArgoCD tự xử lý).
* **Bài tập:** Override giá trị `values.yaml` trực tiếp từ giao diện ArgoCD.

## 📅 Ngày 5: Kustomize - "Vũ khí" bí mật

* **Lý thuyết:** Kustomize là gì? Tại sao nó phổ biến trong GitOps?
* **Thực hành:** Tạo cấu trúc thư mục `base/` và `overlays/` (dev, prod). Deploy 2 môi trường khác nhau từ cùng một code gốc.
* **FAQ:** Nên dùng Helm hay Kustomize?
* **Bài tập:** Thay đổi số lượng `replicas` khác nhau giữa môi trường Dev và Prod bằng Kustomize.

## 📅 Ngày 6: Quản lý nhiều Cluster (Multi-cluster)

* **Lý thuyết:** Kiến trúc Hub-and-Spoke của ArgoCD.
* **Thực hành:** Add một cluster bên ngoài vào ArgoCD chính để quản lý tập trung.
* **FAQ:** ArgoCD tốn bao nhiêu tài nguyên khi quản lý hàng trăm cluster?
* **Bài tập:** Deploy 1 ứng dụng từ Cluster A sang Cluster B thông qua giao diện ở Cluster A.

## 📅 Ngày 7: App of Apps Pattern

* **Lý thuyết:** Cách quản lý hàng trăm ứng dụng mà không bị "rối".
* **Thực hành:** Tạo một "Root Application" để quản lý các "Child Applications".
* **FAQ:** App of Apps hay ApplicationSet tốt hơn?
* **Bài tập:** Thiết kế cấu trúc thư mục Git chuẩn cho mô hình App of Apps.

## 📅 Ngày 8: ApplicationSet & Tự động hóa quy mô lớn

* **Lý thuyết:** Generator trong ApplicationSet (List, Git, Cluster).
* **Thực hành:** Tự động tạo hàng loạt Application dựa trên danh sách thư mục trong Git.
* **FAQ:** Làm sao để ngăn chặn việc ApplicationSet tạo ra quá nhiều rác trên Cluster?
* **Bài tập:** Dùng Git Generator để tự động deploy app khi có folder mới được tạo trên Git.

## 📅 Ngày 9: Bảo mật (RBAC & Projects)

* **Lý thuyết:** ArgoCD Projects (AppProject) và phân quyền người dùng.
* **Thực hành:** Tạo một Project giới hạn chỉ cho phép deploy vào một Namespace nhất định.
* **FAQ:** Làm sao tích hợp SSO (Google/Okta) vào ArgoCD?
* **Bài tập:** Tạo user "Developer" chỉ có quyền view, không có quyền Sync.

## 📅 Ngày 10: Triển khai nâng cao (Canary & Blue/Green)

* **Lý thuyết:** Giới thiệu Argo Rollouts.
* **Thực hành:** Cấu hình một chiến lược Deploy Canary (chuyển 10% traffic sang bản mới).
* **FAQ:** Sự khác biệt giữa ArgoCD và Argo Rollouts?
* **Bài tập:** Thực hiện một pha "Rollback" thần tốc khi bản Canary bị lỗi.
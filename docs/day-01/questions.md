# ❓ Câu Hỏi Ôn Tập — Ngày 1: Nhập Môn GitOps & Cài Đặt ArgoCD

## Phần 1: GitOps Fundamentals (Câu 1-10)

### Câu 1: GitOps là gì?
??? success "📖 Đáp án"

    **GitOps** là phương pháp quản lý hạ tầng và triển khai ứng dụng sử dụng **Git làm nguồn sự thật duy nhất** (single source of truth). Mọi thay đổi trên hệ thống đều phải thông qua Git commits.

    **4 nguyên tắc cốt lõi của GitOps:**
    1. **Declarative** — Hệ thống được mô tả dạng khai báo (YAML)
    2. **Versioned & Immutable** — Trạng thái mong muốn được lưu trong Git (có version history)
    3. **Pulled Automatically** — Agent tự động pull thay đổi từ Git
    4. **Continuously Reconciled** — Agent liên tục so sánh và sửa chữa drift


---

### Câu 2: Push-based CD và Pull-based CD khác nhau như thế nào?
??? success "📖 Đáp án"

    | | Push-based | Pull-based (GitOps) |
    |---|-----------|---------------------|
    | **Ai deploy?** | CI pipeline push lên cluster | Agent trong cluster tự pull từ Git |
    | **Credentials** | Pipeline cần kubeconfig/token | Agent đã có quyền trong cluster |
    | **Ví dụ** | Jenkins `kubectl apply`, GitLab CD | ArgoCD, Flux |
    | **Bảo mật** | Kém hơn (credentials ngoài cluster) | Tốt hơn (credentials trong cluster) |
    | **Drift detection** | Không có | Có — agent liên tục kiểm tra |

    **Pull-based** an toàn hơn vì không cần expose cluster credentials ra ngoài.


---

### Câu 3: Tại sao GitOps lại quan trọng trong Kubernetes?
??? success "📖 Đáp án"

    1. **Audit trail** — Mọi thay đổi đều có commit history, biết ai thay đổi gì, khi nào
    2. **Rollback dễ dàng** — `git revert` để rollback, không cần nhớ trạng thái trước
    3. **Consistency** — Git là single source of truth, cluster luôn khớp với Git
    4. **Drift detection** — Phát hiện khi ai đó `kubectl edit` trực tiếp
    5. **Self-healing** — Tự sửa chữa khi cluster bị thay đổi ngoài Git
    6. **Collaboration** — Dùng PR/MR review trước khi deploy, giống code review


---

### Câu 4: "Single Source of Truth" trong GitOps nghĩa là gì?
??? success "📖 Đáp án"

    **Single Source of Truth** nghĩa là Git repository là **nơi duy nhất** xác định trạng thái mong muốn của hệ thống. Bất kỳ ai muốn biết hệ thống đang chạy gì → xem Git, không phải chạy `kubectl get` trên cluster.

    **Hệ quả:**
    - Không ai được `kubectl apply` trực tiếp (trừ trường hợp khẩn cấp)
    - Mọi thay đổi phải qua Git commit
    - Cluster state phải khớp với Git state
    - Nếu không khớp → ArgoCD tự sửa (self-heal)


---

### Câu 5: Declarative configuration khác gì Imperative configuration?
??? success "📖 Đáp án"

    | | Declarative | Imperative |
    |---|-------------|-----------|
    | **Cách viết** | Mô tả **trạng thái mong muốn** | Mô tả **từng bước thực hiện** |
    | **Ví dụ** | `replicas: 3` (tôi muốn 3 pods) | `kubectl scale --replicas=3` (scale lên 3) |
    | **Idempotent** | Có (apply bao nhiêu lần cũng cùng kết quả) | Không đảm bảo |
    | **GitOps** | ✅ Phù hợp | ❌ Không phù hợp |

    GitOps yêu cầu **declarative** vì Git chỉ lưu trạng thái mong muốn, không lưu sequence of commands.


---

### Câu 6: ArgoCD là gì? Nó thuộc loại công cụ nào?
??? success "📖 Đáp án"

    ArgoCD là một **Continuous Delivery (CD) tool** cho Kubernetes, hoạt động theo mô hình **Pull-based GitOps**.

    **ArgoCD KHÔNG phải:**
    - CI tool (không build/test code)
    - Container registry
    - Infrastructure provisioning tool (không tạo cluster)

    **ArgoCD LÀ:**
    - GitOps operator — theo dõi Git và sync lên K8s
    - CD tool — chỉ lo phần triển khai
    - Kubernetes controller — chạy bên trong cluster


---

### Câu 7: Liệt kê các thành phần chính trong kiến trúc ArgoCD?
??? success "📖 Đáp án"

    1. **API Server** — Cung cấp REST/gRPC API và Web UI, xử lý authentication
    2. **Repository Server** — Clone Git repos, render manifests (Helm/Kustomize/plain YAML)
    3. **Application Controller** — So sánh trạng thái Git vs Cluster, thực hiện sync/reconcile
    4. **Redis** — Cache cho repo server, cải thiện performance
    5. **Dex** — Identity provider cho SSO (OIDC, SAML, LDAP)
    6. **Notification Controller** (optional) — Gửi notifications qua Slack, email, webhook

    **Application Controller** là thành phần quan trọng nhất — nó liên tục reconcile trạng thái.


---

### Câu 8: ArgoCD có thay thế Jenkins/GitLab CI không? Tại sao?
??? success "📖 Đáp án"

    **Không!** ArgoCD chỉ lo phần **CD** (Continuous Delivery), không thay thế **CI** (Continuous Integration).

    | Giai đoạn | Tool | Chức năng |
    |-----------|------|-----------|
    | **CI** | Jenkins, GitLab CI, GitHub Actions | Build, test, push image |
    | **CD** | ArgoCD, Flux | Sync Git manifests → K8s cluster |

    **Flow hoàn chỉnh:**
    ```
    Code commit → CI (build + test + push image) → Update YAML in Git → ArgoCD (sync to K8s)
    ```

    ArgoCD **bổ trợ** chứ không thay thế CI tools.


---

### Câu 9: So sánh ArgoCD và Flux?
??? success "📖 Đáp án"

    | Tiêu chí | ArgoCD | Flux |
    |----------|--------|------|
    | **Web UI** | ✅ UI mạnh mẽ, trực quan | ❌ Không có UI built-in |
    | **CLI** | ✅ Có | ✅ Có |
    | **Multi-tenancy** | ✅ Projects + RBAC | ⚠️ Hạn chế hơn |
    | **Helm support** | ✅ Native | ✅ Native |
    | **Kustomize** | ✅ Native | ✅ Native |
    | **Kubernetes native** | Dùng CRD riêng | Kubernetes-native hơn |
    | **Community** | Lớn hơn (CNCF Graduated) | Lớn (CNCF Graduated) |
    | **Learning curve** | Dễ (có UI) | Khó hơn (CLI-only) |

    **Khi nào chọn ArgoCD?** Team lớn, cần UI trực quan, multi-tenancy mạnh.
    **Khi nào chọn Flux?** Team nhỏ, muốn lightweight, Kubernetes-native approach.


---

### Câu 10: ArgoCD cần bao nhiêu tài nguyên tối thiểu?
??? success "📖 Đáp án"

    **Tối thiểu cho development/learning:**
    - **CPU:** 2 cores
    - **Memory:** 4 GB RAM
    - **Disk:** 10 GB

    **Khuyến nghị cho production (nhỏ, 1-10 apps):**
    - **CPU:** 4 cores
    - **Memory:** 8 GB RAM

    **Production lớn (100+ apps):**
    - Bật HA mode (3 API Server replicas)
    - Controller sharding
    - Redis cluster

    **Minikube config:**
    ```bash
    minikube start --cpus=4 --memory=8192
    ```


---

## Phần 2: Cài Đặt & Cấu Hình (Câu 11-20)

### Câu 11: Có mấy cách cài đặt ArgoCD? Ưu nhược điểm?
??? success "📖 Đáp án"

    | Cách | Ưu điểm | Nhược điểm |
    |------|---------|-----------|
    | **Plain Manifest** (`kubectl apply -f install.yaml`) | Đơn giản, không cần Helm | Khó customize |
    | **Helm Chart** | Dễ customize values | Cần biết Helm |
    | **Kustomize** | Flexible overlays | Phức tạp hơn |
    | **Operator** (ArgoCD Operator) | Quản lý lifecycle tốt | Thêm layer phức tạp |

    **Khuyến nghị:**
    - **Learning:** Plain Manifest
    - **Production:** Helm Chart hoặc Kustomize
    - **Enterprise:** ArgoCD Operator


---

### Câu 12: Namespace `argocd` có bắt buộc không?
??? success "📖 Đáp án"

    **Không bắt buộc**, nhưng **khuyến nghị** dùng `argocd` vì:
    - Tất cả manifests mặc định tham chiếu namespace `argocd`
    - Nếu dùng namespace khác, phải sửa nhiều file
    - Cộng đồng và tài liệu đều mặc định `argocd`

    Nếu muốn dùng namespace khác (ví dụ `gitops`), phải thêm flag `--namespace gitops` cho mọi lệnh ArgoCD CLI.


---

### Câu 13: Lệnh nào lấy mật khẩu admin mặc định của ArgoCD?
??? success "📖 Đáp án"

    ```bash
    kubectl -n argocd get secret argocd-initial-admin-secret \
      -o jsonpath="{.data.password}" | base64 -d && echo
    ```

    **Giải thích:**
    1. `get secret argocd-initial-admin-secret` — Lấy Secret chứa password
    2. `-o jsonpath="{.data.password}"` — Trích xuất field `password`
    3. `base64 -d` — Decode từ base64 (K8s Secret luôn encode base64)
    4. `&& echo` — Xuống dòng sau password

    **Lưu ý:** Nên xóa secret này sau khi đổi password: `kubectl delete secret argocd-initial-admin-secret -n argocd`


---

### Câu 14: Làm sao truy cập ArgoCD UI?
??? success "📖 Đáp án"

    Có 3 cách:

    **Cách 1: Port-forward (Development)**
    ```bash
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    # Mở https://localhost:8080
    ```

    **Cách 2: NodePort**
    ```bash
    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
    minikube service argocd-server -n argocd
    ```

    **Cách 3: Ingress (Production)**
    ```yaml
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: argocd-server
      namespace: argocd
      annotations:
        nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    spec:
      rules:
        - host: argocd.example.com
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: argocd-server
                    port:
                      number: 443
    ```


---

### Câu 15: ArgoCD CLI login command là gì?
??? success "📖 Đáp án"

    ```bash
    argocd login <SERVER> --username <USER> --password <PASS> --insecure
    ```

    **Tham số:**
    - `<SERVER>` — Địa chỉ ArgoCD server (vd: `localhost:8080`)
    - `--username` — Username (mặc định: `admin`)
    - `--password` — Password
    - `--insecure` — Bỏ qua SSL certificate verification (chỉ cho dev)

    **Production** nên dùng:
    ```bash
    argocd login argocd.example.com --sso
    ```


---

### Câu 16: Đổi password admin bằng CLI như thế nào?
??? success "📖 Đáp án"

    ```bash
    argocd account update-password \
      --current-password <OLD_PASSWORD> \
      --new-password <NEW_PASSWORD>
    ```

    **Lưu ý quan trọng:**
    - Phải login trước khi đổi password
    - Password mới nên có ít nhất 8 ký tự
    - Sau khi đổi, nên xóa initial admin secret:
      ```bash
      kubectl delete secret argocd-initial-admin-secret -n argocd
      ```


---

### Câu 17: ArgoCD chạy bao nhiêu Pods mặc định?
??? success "📖 Đáp án"

    Với cài đặt **non-HA** (mặc định), ArgoCD chạy **7 Pods**:

    | Pod | Chức năng |
    |-----|-----------|
    | `argocd-server` | API + UI server |
    | `argocd-repo-server` | Clone và render Git repos |
    | `argocd-application-controller` | Reconcile apps, sync/diff |
    | `argocd-applicationset-controller` | Quản lý ApplicationSets |
    | `argocd-redis` | Cache |
    | `argocd-notifications-controller` | Notifications |
    | `argocd-dex-server` | SSO authentication |

    Kiểm tra: `kubectl get pods -n argocd`


---

### Câu 18: `kubectl wait --for=condition=Ready` dùng để làm gì?
??? success "📖 Đáp án"

    ```bash
    kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
    ```

    **Giải thích:**
    - `--for=condition=Ready` — Chờ cho đến khi Pod ở trạng thái Ready
    - `pods --all` — Áp dụng cho tất cả pods
    - `-n argocd` — Trong namespace argocd
    - `--timeout=300s` — Timeout sau 5 phút

    **Tại sao cần?** ArgoCD cần 2-3 phút để tất cả pods khởi động. Lệnh này block cho đến khi hoàn tất, tránh việc chạy lệnh tiếp theo khi pods chưa sẵn sàng.


---

### Câu 19: Sự khác nhau giữa `install.yaml` và `ha/install.yaml`?
??? success "📖 Đáp án"

    | | `install.yaml` (Non-HA) | `ha/install.yaml` (HA) |
    |---|-------------------------|------------------------|
    | **API Server** | 1 replica | 3 replicas |
    | **Controller** | 1 replica | 1 replica (leader election) |
    | **Redis** | Standalone | Redis HA (Sentinel) |
    | **Repo Server** | 1 replica | 2 replicas |
    | **Use case** | Dev, testing | Production |

    **HA mode** đảm bảo ArgoCD vẫn hoạt động khi 1 pod bị crash.


---

### Câu 20: Làm sao kiểm tra version ArgoCD đang chạy?
??? success "📖 Đáp án"

    **CLI:**
    ```bash
    argocd version
    ```
    Output gồm cả client version và server version.

    **Chỉ client:**
    ```bash
    argocd version --client
    ```

    **Từ API:**
    ```bash
    curl -sk https://localhost:8080/api/version
    ```

    **Từ Pod image:**
    ```bash
    kubectl get pods -n argocd -o jsonpath='{.items[0].spec.containers[0].image}'
    ```


---

## Phần 3: Kiến trúc & Nâng Cao (Câu 21-30)

### Câu 21: Application Controller reconcile loop hoạt động như thế nào?
??? success "📖 Đáp án"

    Application Controller chạy **reconciliation loop** liên tục:

    1. **Fetch desired state** — Lấy manifests từ Git (qua Repository Server)
    2. **Fetch live state** — Lấy trạng thái thực tế từ K8s API
    3. **Diff** — So sánh desired vs live state
    4. **Report** — Cập nhật Sync Status (Synced/OutOfSync)
    5. **Sync** (nếu Auto-sync) — Apply thay đổi lên cluster

    **Mặc định:** Reconciliation chạy mỗi **3 phút** (configurable qua `timeout.reconciliation` trong `argocd-cm`).


---

### Câu 22: Repository Server có vai trò gì?
??? success "📖 Đáp án"

    Repository Server là thành phần **stateless** chịu trách nhiệm:

    1. **Clone Git repositories** — Lấy source code/manifests
    2. **Render manifests** — Chuyển đổi Helm/Kustomize/Jsonnet thành plain YAML
    3. **Cache** — Lưu cache rendered manifests trong Redis để tăng tốc

    **Quan trọng:** Repo Server **không** lưu trạng thái. Nó chỉ là "factory" tạo ra YAML từ source.

    **Performance tip:** Mỗi lần Application Controller cần diff, nó gọi Repo Server. Nếu có nhiều apps → tăng replicas của Repo Server.


---

### Câu 23: Redis trong ArgoCD dùng để làm gì?
??? success "📖 Đáp án"

    Redis được dùng làm **cache layer**:

    1. **Cache Git repo metadata** — Tránh clone repo lại mỗi lần
    2. **Cache rendered manifests** — Tránh render Helm/Kustomize lại
    3. **Cache App state** — Lưu trạng thái app tạm thời
    4. **Pub/Sub** — Giao tiếp giữa API Server và Controller

    **Nếu Redis chết?** ArgoCD vẫn hoạt động nhưng **chậm hơn** vì mọi thứ phải fetch/render lại từ đầu.


---

### Câu 24: Dex trong ArgoCD là gì?
??? success "📖 Đáp án"

    **Dex** là một **identity service** (OIDC provider) tích hợp sẵn trong ArgoCD, cho phép:

    - Đăng nhập qua **GitHub, Google, LDAP, SAML, Okta** mà không cần tích hợp trực tiếp
    - Dex hoạt động như **proxy** giữa ArgoCD và identity provider bên ngoài

    **Flow:**
    ```
    User → ArgoCD UI → Dex → Google/GitHub/LDAP → Token → ArgoCD
    ```

    **Khi nào không cần Dex?** Khi dùng trực tiếp OIDC provider (vd: Okta, Auth0) mà ArgoCD hỗ trợ native.


---

### Câu 25: ConfigMap `argocd-cm` dùng để cấu hình gì?
??? success "📖 Đáp án"

    `argocd-cm` là **ConfigMap chính** của ArgoCD, cấu hình:

    | Key | Mô tả |
    |-----|--------|
    | `url` | URL của ArgoCD server |
    | `oidc.config` | OIDC/SSO configuration |
    | `dex.config` | Dex identity provider config |
    | `repositories` | Git repo credentials |
    | `accounts.<name>` | Local user accounts |
    | `resource.customizations` | Custom health checks |
    | `timeout.reconciliation` | Reconciliation interval |
    | `kustomize.buildOptions` | Kustomize build flags |

    **Ví dụ thêm local user:**
    ```yaml
    data:
      accounts.developer: "apiKey, login"
    ```


---

### Câu 26: Namespace nào ArgoCD tạo khi cài đặt?
??? success "📖 Đáp án"

    ArgoCD chỉ tạo **1 namespace**: `argocd` (nếu bạn dùng `--create-namespace` với Helm).

    Với plain manifest, bạn phải tự tạo: `kubectl create namespace argocd`.

    **Lưu ý:** ArgoCD **không** tạo namespace cho ứng dụng. Bạn cần:
    - Tạo namespace trước: `kubectl create namespace my-app`
    - Hoặc dùng syncOption: `CreateNamespace=true`


---

### Câu 27: CRD (Custom Resource Definition) nào ArgoCD tạo?
??? success "📖 Đáp án"

    ArgoCD tạo **4 CRDs chính:**

    | CRD | Mô tả |
    |-----|--------|
    | `applications.argoproj.io` | Định nghĩa Application |
    | `applicationsets.argoproj.io` | Định nghĩa ApplicationSet |
    | `appprojects.argoproj.io` | Định nghĩa Project |
    | `applicationsetpolicies.argoproj.io` | Policies cho ApplicationSet |

    **Kiểm tra:**
    ```bash
    kubectl get crd | grep argoproj
    ```


---

### Câu 28: ArgoCD hỗ trợ những loại manifest nào?
??? success "📖 Đáp án"

    ArgoCD hỗ trợ **7 loại** manifest source:

    1. **Plain YAML/JSON** — Kubernetes manifests thuần
    2. **Helm Charts** — Từ Helm repo hoặc Git
    3. **Kustomize** — Kustomization.yaml
    4. **Jsonnet** — Jsonnet files
    5. **Plugin** — Custom config management plugin
    6. **Directory** — Thư mục chứa nhiều YAML files
    7. **OCI Helm** — Helm charts từ OCI registry

    ArgoCD **tự detect** loại manifest dựa trên nội dung thư mục (có `Chart.yaml` → Helm, có `kustomization.yaml` → Kustomize, v.v.)


---

### Câu 29: Health check trong ArgoCD hoạt động như thế nào?
??? success "📖 Đáp án"

    ArgoCD tự động kiểm tra **health** của mỗi resource:

    | Resource | Healthy khi |
    |----------|------------|
    | **Deployment** | Tất cả replicas available |
    | **StatefulSet** | Tất cả replicas ready |
    | **DaemonSet** | Desired = Current = Ready |
    | **Service** | Luôn Healthy |
    | **Ingress** | Có address assigned |
    | **PVC** | Status = Bound |
    | **Pod** | Phase = Running + containers ready |

    **Health Statuses:**
    - 🟢 **Healthy** — Resource hoạt động bình thường
    - 🟡 **Progressing** — Đang cập nhật
    - 🔴 **Degraded** — Có lỗi
    - ⚪ **Suspended** — Tạm dừng
    - ❓ **Missing** — Resource chưa tồn tại
    - ❓ **Unknown** — Không xác định được


---

### Câu 30: Làm sao xóa hoàn toàn ArgoCD khỏi cluster?
??? success "📖 Đáp án"

    ```bash
    # Bước 1: Xóa tất cả ArgoCD Applications trước
    argocd app list -o name | xargs -I {} argocd app delete {} --cascade

    # Bước 2: Xóa ArgoCD components
    kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    # Bước 3: Xóa CRDs
    kubectl delete crd applications.argoproj.io
    kubectl delete crd applicationsets.argoproj.io
    kubectl delete crd appprojects.argoproj.io

    # Bước 4: Xóa namespace
    kubectl delete namespace argocd
    ```

    **⚠️ Cẩn thận:** Nếu Application có `finalizer`, xóa ArgoCD trước khi xóa Applications sẽ gây **stuck resources**. Luôn xóa Applications trước!


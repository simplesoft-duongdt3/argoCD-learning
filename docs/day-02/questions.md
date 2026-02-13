# ❓ Câu Hỏi Ôn Tập — Ngày 2: Kết Nối Repository & Ứng Dụng Đầu Tiên

## Phần 1: Application Concepts (Câu 1-10)

### Câu 1: Application trong ArgoCD gồm những thành phần cấu hình chính nào?
??? success "📖 Đáp án"

    Một Application trong ArgoCD gồm 3 thành phần chính:

    1. **Source** — Nơi lấy manifests
       - `repoURL` — URL Git repo hoặc Helm repo
       - `targetRevision` — Branch/tag/commit
       - `path` — Thư mục chứa manifests

    2. **Destination** — Nơi deploy
       - `server` — URL của K8s cluster
       - `namespace` — Namespace đích

    3. **Sync Policy** — Chính sách đồng bộ
       - Manual hoặc Automated
       - selfHeal, prune options

    ```yaml
    spec:
      source:
        repoURL: https://github.com/user/repo.git
        path: manifests
        targetRevision: HEAD
      destination:
        server: https://kubernetes.default.svc
        namespace: my-app
    ```


---

### Câu 2: `targetRevision: HEAD` nghĩa là gì?
??? success "📖 Đáp án"

    `HEAD` trỏ đến **commit mới nhất** trên branch mặc định (thường là `main` hoặc `master`).

    **Các giá trị khả dụng cho targetRevision:**
    | Giá trị | Mô tả |
    |---------|--------|
    | `HEAD` | Commit mới nhất trên default branch |
    | `main` | Branch `main` |
    | `v1.0.0` | Tag cụ thể |
    | `abc123` | Commit hash cụ thể |
    | `refs/heads/feature-x` | Branch cụ thể |

    **Best practice production:** Dùng **tag** hoặc **commit hash** thay vì `HEAD` để tránh deploy code chưa tested.


---

### Câu 3: Mô tả 3 cách tạo Application trên ArgoCD?
??? success "📖 Đáp án"

    **Cách 1: CLI**
    ```bash
    argocd app create my-app \
      --repo https://github.com/user/repo.git \
      --path manifests \
      --dest-server https://kubernetes.default.svc \
      --dest-namespace default
    ```

    **Cách 2: YAML manifest**
    ```bash
    kubectl apply -f application.yaml
    ```

    **Cách 3: Web UI**
    1. Click "+ NEW APP"
    2. Điền form
    3. Click "CREATE"

    **Best practice:** Dùng **YAML manifest** vì có thể version control trong Git (GitOps cho chính ArgoCD!).


---

### Câu 4: `https://kubernetes.default.svc` là gì?
??? success "📖 Đáp án"

    Đây là **internal DNS** của Kubernetes API server, được resolve bởi CoreDNS trong cluster.

    **Ý nghĩa:**
    - `kubernetes` — Service name
    - `default` — Namespace
    - `svc` — Service DNS suffix
    - → Trỏ đến cluster **mà ArgoCD đang chạy** (in-cluster)

    **Khi nào dùng URL khác?**
    - Deploy lên cluster **khác** (external cluster)
    - URL lấy từ `argocd cluster list`


---

### Câu 5: Sync Status có những trạng thái nào?
??? success "📖 Đáp án"

    | Status | Ý nghĩa | Icon |
    |--------|----------|------|
    | **Synced** | Git state = Cluster state | 🟢 |
    | **OutOfSync** | Git state ≠ Cluster state | 🟡 |
    | **Unknown** | Không xác định được (thường do lỗi kết nối Git) | ❓ |

    **OutOfSync xảy ra khi:**
    1. Có commit mới trên Git nhưng chưa sync
    2. Ai đó `kubectl edit` trực tiếp trên cluster
    3. Application vừa được tạo nhưng chưa sync lần đầu


---

### Câu 6: Health Status có những trạng thái nào?
??? success "📖 Đáp án"

    | Status | Ý nghĩa |
    |--------|----------|
    | **Healthy** | Tất cả resources đang hoạt động bình thường |
    | **Progressing** | Có resources đang cập nhật (pods starting) |
    | **Degraded** | Có resources bị lỗi (CrashLoopBackOff, etc.) |
    | **Suspended** | Resources đang bị tạm dừng (scaled to 0) |
    | **Missing** | Resources chưa tồn tại trên cluster |
    | **Unknown** | Không xác định được health |

    **Healthy = tất cả Deployment available, Pods running, Services active.**


---

### Câu 7: `argocd app sync` và `argocd app refresh` khác nhau thế nào?
??? success "📖 Đáp án"

    | Lệnh | Chức năng |
    |-------|-----------|
    | `argocd app refresh <app>` | Kiểm tra Git xem có thay đổi gì mới không (chỉ **detect**, không apply) |
    | `argocd app sync <app>` | Apply thay đổi từ Git lên cluster (thực sự **deploy**) |

    **Flow:**
    ```
    refresh → detect OutOfSync → sync → apply changes → Synced
    ```

    `refresh` giống "kiểm tra email", `sync` giống "reply email".


---

### Câu 8: Sync Option `CreateNamespace=true` dùng để làm gì?
??? success "📖 Đáp án"

    Khi Application deploy vào namespace chưa tồn tại, ArgoCD **mặc định sẽ báo lỗi**. Option `CreateNamespace=true` bảo ArgoCD **tự tạo namespace** nếu chưa có.

    ```yaml
    syncPolicy:
      syncOptions:
        - CreateNamespace=true
    ```

    **Khi nào nên bật?**
    - ✅ Dev/staging environments
    - ⚠️ Production — cân nhắc, có thể muốn tạo namespace manually với labels/annotations cụ thể


---

### Câu 9: Làm sao xem chi tiết trạng thái của một Application?
??? success "📖 Đáp án"

    **CLI:**
    ```bash
    # Tổng quan
    argocd app get <app-name>

    # Chi tiết resources
    argocd app get <app-name> --show-operation

    # Xem diff (Git vs Cluster)
    argocd app diff <app-name>

    # Xem logs
    argocd app logs <app-name>

    # Xem resource tree
    argocd app resources <app-name>
    ```

    **UI:** Click vào app → thấy resource tree, health status, sync history, logs.


---

### Câu 10: Lệnh nào xóa một Application?
??? success "📖 Đáp án"

    ```bash
    # Xóa app + Resources trên cluster (cascade delete)
    argocd app delete <app-name>

    # Xóa app nhưng GIỮ resources trên cluster
    argocd app delete <app-name> --cascade=false
    ```

    **`--cascade` (mặc định: true):**
    - `true` — Xóa Application + tất cả K8s resources nó tạo ra
    - `false` — Chỉ xóa Application object, resources vẫn chạy (orphaned)

    **Khi nào dùng `--cascade=false`?** Khi muốn chuyển app sang quản lý bởi tool khác/manual mà không muốn downtime.


---

## Phần 2: Repository & Kết Nối (Câu 11-20)

### Câu 11: ArgoCD hỗ trợ những loại repository nào?
??? success "📖 Đáp án"

    1. **Git Repository** (HTTPS hoặc SSH)
       - Public repo: không cần credentials
       - Private repo: username/password, SSH key, hoặc GitHub App

    2. **Helm Repository**
       - Public: `https://charts.bitnami.com/bitnami`
       - Private: cần username/password

    3. **OCI Registry** (Helm OCI)
       - `oci://registry.example.com/charts`

    ```bash
    # Thêm Git repo
    argocd repo add https://github.com/user/repo.git

    # Thêm Helm repo
    argocd repo add https://charts.bitnami.com/bitnami --type helm --name bitnami
    ```


---

### Câu 12: Kết nối private Git repo bằng HTTPS cần gì?
??? success "📖 Đáp án"

    Cần **username + personal access token** (không dùng password thật):

    ```bash
    argocd repo add https://github.com/user/private-repo.git \
      --username <USERNAME> \
      --password <GITHUB_TOKEN>
    ```

    **Tạo GitHub Token:**
    1. GitHub → Settings → Developer Settings
    2. Personal Access Tokens → Fine-grained tokens
    3. Permissions: Repository → Contents → Read-only

    **ArgoCD lưu credentials ở đâu?** Trong Kubernetes Secret `repo-<hash>` trong namespace `argocd`.


---

### Câu 13: Kết nối private Git repo bằng SSH key cần gì?
??? success "📖 Đáp án"

    ```bash
    argocd repo add git@github.com:user/private-repo.git \
      --ssh-private-key-path ~/.ssh/id_rsa
    ```

    **Các bước:**
    1. Generate SSH key: `ssh-keygen -t ed25519 -f ~/.ssh/argocd`
    2. Thêm public key vào GitHub: Settings → SSH Keys
    3. Thêm private key vào ArgoCD bằng lệnh trên

    **Lưu ý:** ArgoCD lưu SSH key trong K8s Secret → nên dùng **deploy key** (read-only, per-repo) thay vì personal SSH key.


---

### Câu 14: Webhook và Polling khác nhau thế nào?
??? success "📖 Đáp án"

    | | Webhook | Polling |
    |---|---------|---------|
    | **Cách hoạt động** | GitHub gửi HTTP POST khi có push | ArgoCD tự kiểm tra Git định kỳ |
    | **Tốc độ** | Gần như tức thì (~1-2 giây) | Delay tối đa 3 phút |
    | **Cấu hình** | Cần expose ArgoCD + setup webhook trên GitHub | Không cần cấu hình (mặc định) |
    | **Firewall** | ArgoCD phải accessible từ internet | ArgoCD chỉ cần kết nối ra ngoài |
    | **Reliability** | Webhook có thể miss (HTTP timeout) | Luôn hoạt động |

    **Best practice:** Dùng **cả hai** — Webhook cho tốc độ, Polling làm safety net.


---

### Câu 15: Polling interval mặc định là bao lâu? Thay đổi thế nào?
??? success "📖 Đáp án"

    **Mặc định: 3 phút (180 giây)**

    **Thay đổi qua ConfigMap:**
    ```yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: argocd-cm
      namespace: argocd
    data:
      timeout.reconciliation: "60s"   # Giảm xuống 1 phút
    ```

    **Hoặc tắt polling hoàn toàn:**
    ```yaml
    data:
      timeout.reconciliation: "0"   # Chỉ dùng webhook
    ```

    **⚠️ Giảm interval = tăng load trên Git server.** Nếu có nhiều apps, nên dùng webhook thay vì giảm interval.


---

### Câu 16: Cấu hình webhook cho GitHub như thế nào?
??? success "📖 Đáp án"

    1. **Trên GitHub:**
       - Repo → Settings → Webhooks → Add webhook
       - Payload URL: `https://<ARGOCD_URL>/api/webhook`
       - Content type: `application/json`
       - Secret: (tùy chọn, để verify)
       - Events: "Just the push event"

    2. **Trên ArgoCD:**
       - Nếu dùng secret, thêm vào `argocd-secret`:
         ```yaml
         stringData:
           webhook.github.secret: <YOUR_SECRET>
         ```

    **ArgoCD tự nhận diện** repo nào bị thay đổi và chỉ refresh app tương ứng.


---

### Câu 17: `argocd repo list` hiển thị gì?
??? success "📖 Đáp án"

    Hiển thị danh sách **repositories đã được đăng ký** trong ArgoCD:

    ```
    TYPE  NAME  REPO                                          INSECURE  OCI    LFS    CREDS  STATUS
    git         https://github.com/user/repo.git              false     false  false  false  Successful
    helm  bitnami  https://charts.bitnami.com/bitnami         false     false  false  false  Successful
    ```

    **Các cột:**
    - `TYPE` — git hoặc helm
    - `REPO` — URL repository
    - `INSECURE` — Có bỏ qua TLS không
    - `CREDS` — Có credentials không
    - `STATUS` — Kết nối thành công hay thất bại

    **Lưu ý:** Public repos không cần đăng ký trước. ArgoCD tự kết nối khi tạo Application.


---

### Câu 18: Một Application có thể trỏ đến nhiều path trong cùng repo không?
??? success "📖 Đáp án"

    **Không!** Mỗi Application chỉ có **1 source** (1 repo + 1 path).

    **Nhưng từ ArgoCD 2.6+**, hỗ trợ **Multiple Sources**:
    ```yaml
    spec:
      sources:
        - repoURL: https://github.com/user/repo.git
          path: manifests/base
          targetRevision: HEAD
        - repoURL: https://github.com/user/repo.git
          path: manifests/config
          targetRevision: HEAD
    ```

    **Giải pháp thay thế:**
    - Dùng Kustomize để reference nhiều thư mục
    - Tạo nhiều Applications (mỗi cái 1 path)
    - Dùng App of Apps pattern


---

### Câu 19: Có thể deploy nhiều Application từ cùng 1 repo không?
??? success "📖 Đáp án"

    **Có!** Rất phổ biến. Mỗi Application trỏ đến **path khác nhau** trong cùng repo:

    ```
    repo/
    ├── apps/
    │   ├── frontend/   ← App 1
    │   ├── backend/    ← App 2
    │   └── database/   ← App 3
    ```

    ```bash
    argocd app create frontend --repo <REPO> --path apps/frontend ...
    argocd app create backend --repo <REPO> --path apps/backend ...
    argocd app create database --repo <REPO> --path apps/database ...
    ```

    **Đây chính là nền tảng** cho App of Apps và ApplicationSet (Day 7-8).


---

### Câu 20: Application bị trạng thái "ComparisonError" là do đâu?
??? success "📖 Đáp án"

    **Nguyên nhân phổ biến:**

    1. **Git repo URL sai** — Kiểm tra lại URL
    2. **Path không tồn tại** — Thư mục trong repo không đúng
    3. **Credentials sai** — Token hết hạn hoặc sai
    4. **Invalid YAML** — File YAML bị lỗi syntax
    5. **Helm chart lỗi** — Template có lỗi
    6. **Network** — ArgoCD không kết nối được Git server

    **Debug:**
    ```bash
    argocd app get <app-name>  # Xem chi tiết lỗi
    kubectl logs -n argocd deployment/argocd-repo-server  # Xem log repo server
    ```


---

## Phần 3: Thực Hành & Troubleshooting (Câu 21-30)

### Câu 21: Tạo Deployment YAML cho Nginx với resource limits — viết mẫu?
??? success "📖 Đáp án"

    ```yaml
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: nginx-demo
      labels:
        app: nginx-demo
    spec:
      replicas: 2
      selector:
        matchLabels:
          app: nginx-demo
      template:
        metadata:
          labels:
            app: nginx-demo
        spec:
          containers:
            - name: nginx
              image: nginx:1.25-alpine
              ports:
                - containerPort: 80
              resources:
                requests:
                  cpu: 50m
                  memory: 64Mi
                limits:
                  cpu: 100m
                  memory: 128Mi
              livenessProbe:
                httpGet:
                  path: /
                  port: 80
                initialDelaySeconds: 5
              readinessProbe:
                httpGet:
                  path: /
                  port: 80
                initialDelaySeconds: 3
    ```

    **Giải thích resource:**
    - `requests` — Tối thiểu cần để schedule pod
    - `limits` — Tối đa được phép sử dụng


---

### Câu 22: Tại sao nên dùng `nginx:1.25-alpine` thay vì `nginx:latest`?
??? success "📖 Đáp án"

    | Tag | Vấn đề |
    |-----|--------|
    | `nginx:latest` | ❌ Mỗi build có thể khác nhau, không reproducible |
    | `nginx:1.25` | ⚠️ Tốt hơn, nhưng patch version có thể thay đổi |
    | `nginx:1.25-alpine` | ✅ Pinned version + lightweight image |
    | `nginx:1.25.3-alpine` | ✅✅ Best — hoàn toàn pinned |

    **Lý do GitOps:**
    - Git lưu declarative state → image tag phải **immutable**
    - `latest` tag bị overwrite mỗi khi có build mới → **drift** giữa Git và thực tế
    - Alpine image nhỏ hơn (~40MB vs ~180MB) → pull nhanh hơn, attack surface nhỏ hơn


---

### Câu 23: Service type NodePort và ClusterIP khác nhau thế nào?
??? success "📖 Đáp án"

    | Type | Truy cập từ | Port range | Use case |
    |------|-------------|------------|----------|
    | **ClusterIP** | Chỉ trong cluster | Bất kỳ | Service nội bộ (backend ↔ database) |
    | **NodePort** | Bên ngoài cluster | 30000-32767 | Dev/testing, expose qua Node IP |
    | **LoadBalancer** | Internet | Bất kỳ | Production (tạo LB trên cloud) |

    ```yaml
    # ClusterIP (mặc định)
    spec:
      type: ClusterIP

    # NodePort
    spec:
      type: NodePort
      ports:
        - port: 80
          nodePort: 30080  # Optional, K8s tự assign nếu không chỉ định
    ```

    **Minikube:** Dùng `minikube service <name>` để truy cập NodePort service.


---

### Câu 24: Làm sao kiểm tra Application đã sync thành công?
??? success "📖 Đáp án"

    ```bash
    # Cách 1: ArgoCD CLI
    argocd app get <app-name>
    # Sync Status: Synced ✅
    # Health Status: Healthy ✅

    # Cách 2: kubectl
    kubectl get application <app-name> -n argocd -o jsonpath='{.status.sync.status}'
    # → Synced

    kubectl get application <app-name> -n argocd -o jsonpath='{.status.health.status}'
    # → Healthy

    # Cách 3: Chờ sync hoàn tất
    argocd app wait <app-name> --sync --health --timeout 120
    ```

    **Cả 2 điều kiện phải thỏa:**
    - Sync Status = **Synced** (Git = Cluster)
    - Health Status = **Healthy** (Pods running, Services active)


---

### Câu 25: `argocd app diff` hiển thị gì?
??? success "📖 Đáp án"

    Hiển thị **sự khác biệt** giữa trạng thái mong muốn (Git) và trạng thái thực tế (Cluster):

    ```bash
    argocd app diff nginx-demo
    ```

    Output tương tự `diff` — lines có `+` là trong Git nhưng chưa có trên cluster, `-` là trên cluster nhưng không có trong Git.

    **Khi nào dùng?**
    - Debug OutOfSync — xem chính xác cái gì khác
    - Review trước khi sync — đảm bảo thay đổi đúng ý
    - Phát hiện drift — ai đó `kubectl edit` trực tiếp


---

### Câu 26: Lỗi "the server could not find the requested resource" khi sync là do đâu?
??? success "📖 Đáp án"

    **Nguyên nhân:** YAML reference một **API version** hoặc **resource kind** không tồn tại trên cluster.

    **Ví dụ phổ biến:**
    ```yaml
    # Lỗi: extensions/v1beta1 đã bị deprecated
    apiVersion: extensions/v1beta1  # ❌
    kind: Ingress

    # Sửa thành:
    apiVersion: networking.k8s.io/v1  # ✅
    kind: Ingress
    ```

    **Debug:**
    ```bash
    # Kiểm tra API versions có sẵn
    kubectl api-versions | grep networking

    # Kiểm tra resource có tồn tại
    kubectl api-resources | grep ingress
    ```


---

### Câu 27: `argocd app history` dùng để làm gì?
??? success "📖 Đáp án"

    Hiển thị **lịch sử sync** của Application:

    ```bash
    argocd app history <app-name>
    ```

    Output:
    ```
    ID  DATE                  REVISION
    1   2024-01-15 10:30:00   abc1234
    2   2024-01-15 14:20:00   def5678
    3   2024-01-16 09:00:00   ghi9012
    ```

    **Use case:**
    - Xem đã deploy lần nào, commit nào
    - Rollback về revision cũ: `argocd app rollback <app> <ID>`
    - Audit trail — ai deploy gì, khi nào


---

### Câu 28: Rollback bằng ArgoCD CLI như thế nào?
??? success "📖 Đáp án"

    ```bash
    # Xem history
    argocd app history <app-name>

    # Rollback về revision cũ
    argocd app rollback <app-name> <REVISION_ID>
    ```

    **⚠️ Lưu ý quan trọng:**
    - Rollback chỉ là **re-apply** manifest cũ, không phải git revert
    - Nếu Auto-sync bật → ArgoCD sẽ **sync lại về HEAD** ngay lập tức, override rollback
    - **Best practice GitOps:** Rollback bằng `git revert` thay vì `argocd rollback`

    ```bash
    # GitOps-correct rollback
    git revert <commit-hash>
    git push
    # → ArgoCD tự sync commit revert
    ```


---

### Câu 29: Nhiều người cùng commit vào repo thì ArgoCD xử lý thế nào?
??? success "📖 Đáp án"

    ArgoCD **không quan tâm** ai commit. Nó chỉ so sánh **trạng thái cuối cùng** (latest commit) của branch với cluster.

    **Flow:**
    1. Dev A commit → HEAD = commit A
    2. Dev B commit → HEAD = commit B (ahead of A)
    3. ArgoCD detect HEAD = commit B → sync to B
    4. Cả thay đổi của A và B đều được apply

    **Conflict xảy ra khi:**
    - 2 người sửa cùng file → Git conflict → phải resolve trước khi merge
    - Đây là Git conflict, không phải ArgoCD conflict

    **Best practice:** Dùng **Pull Request + review** trước khi merge vào main branch.


---

### Câu 30: Tại sao nên tách Git repo cho config (manifests) và source code (app code)?
??? success "📖 Đáp án"

    **Best practice:** Dùng **2 repo riêng biệt:**

    | Repo | Nội dung | Trigger |
    |------|----------|---------|
    | **App repo** | Source code, Dockerfile | CI pipeline (build + test) |
    | **Config repo** | K8s manifests, Helm values | ArgoCD (deploy) |

    **Lý do:**
    1. **Tách biệt concerns** — Code change ≠ Config change
    2. **Tránh trigger CI/CD lẫn nhau** — Update YAML không nên trigger rebuild
    3. **Fine-grained permissions** — Dev sửa code, Ops sửa config
    4. **Audit trail rõ ràng** — Dễ track config changes riêng

    **Flow kết hợp:**
    ```
    App repo commit → CI build image → Update image tag in Config repo → ArgoCD sync
    ```


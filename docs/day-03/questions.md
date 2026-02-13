# ❓ Câu Hỏi Ôn Tập — Ngày 3: Sync Strategies & Phục Hồi Sự Cố

## Phần 1: Sync Strategies (Câu 1-10)

### Câu 1: Manual Sync và Automatic Sync khác nhau thế nào?

    | | Manual Sync | Automatic Sync |
    |---|-------------|----------------|
    | **Trigger** | User click "SYNC" hoặc chạy CLI | ArgoCD tự sync khi Git thay đổi |
    | **Control** | Kiểm soát hoàn toàn | Tự động, ít kiểm soát |
    | **Use case** | Production | Dev/Staging |
    | **Risk** | Thấp (review trước) | Cao hơn (deploy ngay) |

    **Cấu hình Auto Sync:**
    ```yaml
    syncPolicy:
      automated: {}  # Bật auto sync
    ```

---

### Câu 2: Self-heal trong ArgoCD là gì?

    **Self-heal** là khả năng ArgoCD **tự sửa chữa** khi phát hiện trạng thái cluster khác với Git (drift). Ví dụ: ai đó `kubectl delete pod` → ArgoCD tự tạo lại.

    ```yaml
    syncPolicy:
      automated:
        selfHeal: true
    ```

    Self-heal kiểm tra drift mỗi **5 giây** (mặc định) và tự reconcile nếu phát hiện khác biệt. Nó chỉ hoạt động khi **automated sync** được bật.

---

### Câu 3: Prune trong ArgoCD nghĩa là gì?

    **Prune** = ArgoCD tự **xóa** resources trên cluster khi resource tương ứng bị xóa khỏi Git. Ví dụ: xóa `configmap.yaml` khỏi Git → ArgoCD xóa ConfigMap trên cluster.

    ```yaml
    syncPolicy:
      automated:
        prune: true
    ```

    **⚠️ Nguy hiểm:** Nếu vô tình xóa file YAML → resource bị xóa trên production! Best practice: dùng PR review + annotation `Prune=false` cho resources quan trọng.

---

### Câu 4: Cách bảo vệ resource không bị Prune?

    Thêm **annotation** vào resource:

    ```yaml
    metadata:
      annotations:
        argocd.argoproj.io/sync-options: Prune=false
    ```

    Resource có annotation này sẽ **không bị xóa** dù file YAML bị xóa khỏi Git. ArgoCD sẽ hiển thị nó là "orphaned" nhưng không xóa.

    **Nên dùng cho:** PersistentVolumeClaim, Secrets chứa credentials, Namespaces.

---

### Câu 5: `PrunePropagationPolicy` có các giá trị nào?

    | Policy | Hành vi |
    |--------|---------|
    | **foreground** | Chờ child resources xóa xong → xóa parent |
    | **background** | Xóa parent ngay, child tự xóa sau |
    | **orphan** | Xóa parent, giữ lại children |

    ```yaml
    syncOptions:
      - PrunePropagationPolicy=foreground
    ```

    **Mặc định:** `foreground` — an toàn nhất vì đảm bảo thứ tự xóa đúng.

---

### Câu 6: `PruneLast=true` có ý nghĩa gì?

    Khi sync, ArgoCD sẽ **prune resources cuối cùng**, sau khi tất cả resources khác đã được apply thành công.

    ```yaml
    syncOptions:
      - PruneLast=true
    ```

    **Tại sao cần?** Tránh tình huống xóa resource cũ trước khi resource mới sẵn sàng → downtime. Ví dụ: xóa Service cũ trước khi Deployment mới running.

---

### Câu 7: Có thể tắt Auto Sync tạm thời được không?

    **Có**, dùng CLI:
    ```bash
    argocd app set <app-name> --sync-policy none
    ```

    Hoặc patch Application:
    ```bash
    kubectl patch application <app-name> -n argocd --type merge -p '
    spec:
      syncPolicy: null
    '
    ```

    **Use case:** Maintenance window, debug trên cluster mà không muốn ArgoCD override.

---

### Câu 8: Retry policy trong sync dùng để làm gì?

    Khi sync thất bại (ví dụ: image pull error tạm thời), ArgoCD sẽ **tự retry** thay vì đánh dấu failed.

    ```yaml
    syncPolicy:
      automated:
        selfHeal: true
      retry:
        limit: 5           # Retry tối đa 5 lần
        backoff:
          duration: 5s      # Chờ 5s trước retry đầu
          factor: 2          # Nhân đôi thời gian mỗi lần
          maxDuration: 3m    # Tối đa 3 phút giữa retries
    ```

    **Exponential backoff:** 5s → 10s → 20s → 40s → 80s

---

### Câu 9: Sync Window là gì?

    **Sync Window** giới hạn **thời gian** ArgoCD được phép sync. Dùng trong production để chỉ deploy trong maintenance window.

    ```yaml
    # Trong AppProject
    spec:
      syncWindows:
        - kind: allow
          schedule: "0 9-17 * * 1-5"  # Chỉ Monday-Friday, 9AM-5PM
          duration: 8h
          applications: ["*"]
        - kind: deny
          schedule: "0 0 25 12 *"    # Block deploy ngày Giáng Sinh
          duration: 24h
    ```

    **kind: allow** — Chỉ cho sync trong window
    **kind: deny** — Cấm sync trong window

---

### Câu 10: Sync Phase và Sync Wave là gì?

    **Phase** — Thứ tự sync (PreSync → Sync → PostSync → SyncFail):
    ```yaml
    metadata:
      annotations:
        argocd.argoproj.io/hook: PreSync  # Chạy trước khi sync
    ```

    **Wave** — Thứ tự trong cùng phase (số nhỏ chạy trước):
    ```yaml
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "1"  # Wave 1 chạy trước wave 2
    ```

    **Use case:** Database migration (PreSync, wave 0) → Deploy app (Sync, wave 1) → Run tests (PostSync, wave 2).

---

## Phần 2: Drift Detection & Recovery (Câu 11-20)

### Câu 11: Drift là gì trong ngữ cảnh GitOps?

    **Drift** là khi trạng thái thực tế trên cluster **khác** với trạng thái mong muốn trong Git. Nguyên nhân: ai đó `kubectl edit/scale/delete` trực tiếp mà không đi qua Git.

    ArgoCD phát hiện drift qua **reconciliation loop** và đánh dấu app là **OutOfSync**. Với Self-heal bật, ArgoCD sẽ tự sửa.

---

### Câu 12: Ai đó `kubectl scale deployment --replicas=10` thì ArgoCD phản ứng thế nào?

    **Có Self-heal:** ArgoCD detect drift trong ~5 giây → tự rollback về giá trị trong Git (ví dụ: replicas=2). Pods thừa bị terminated.

    **Không có Self-heal:** ArgoCD đánh dấu **OutOfSync** trên UI nhưng **không tự sửa**. Cần manual sync để rollback.

    **Đây là lý do Self-heal quan trọng** — ngăn chặn unauthorized changes trên cluster.

---

### Câu 13: `kubectl delete pods --all` thì ArgoCD làm gì?

    **Phân biệt 2 trường hợp:**

    1. **Pods thuộc Deployment:** Kubernetes Deployment controller tự tạo lại pods (không cần ArgoCD). ArgoCD phát hiện app đang **Progressing** → chờ → **Healthy** khi pods up.

    2. **Standalone Pods (không có Deployment):** ArgoCD với Self-heal sẽ re-apply YAML và tạo lại pods.

    **Lưu ý:** Trong trường hợp 1, Deployment controller xử lý, không phải ArgoCD. ArgoCD chỉ giám sát health status.

---

### Câu 14: Resource Hooks trong ArgoCD là gì?

    Resource Hooks cho phép chạy **Jobs/Scripts** tại các thời điểm cụ thể trong sync process:

    | Hook | Thời điểm |
    |------|-----------|
    | `PreSync` | Trước khi sync (database migration) |
    | `Sync` | Cùng lúc sync |
    | `PostSync` | Sau khi sync (smoke test) |
    | `SyncFail` | Khi sync thất bại (notification) |
    | `Skip` | Bỏ qua, không apply |

    ```yaml
    apiVersion: batch/v1
    kind: Job
    metadata:
      annotations:
        argocd.argoproj.io/hook: PreSync
        argocd.argoproj.io/hook-delete-policy: HookSucceeded
    ```

---

### Câu 15: `argocd.argoproj.io/hook-delete-policy` có những giá trị nào?

    | Policy | Xóa khi |
    |--------|---------|
    | `HookSucceeded` | Hook chạy thành công |
    | `HookFailed` | Hook thất bại |
    | `BeforeHookCreation` | Trước khi tạo hook mới (lần sync sau) |

    **Best practice:** Dùng `HookSucceeded` cho Jobs — tránh tồn đọng Completed Jobs trên cluster.

---

### Câu 16: Làm sao ignore diff cho một field cụ thể?

    Dùng **ignoreDifferences** trong Application spec:

    ```yaml
    spec:
      ignoreDifferences:
        - group: apps
          kind: Deployment
          jsonPointers:
            - /spec/replicas  # Bỏ qua diff trên replicas
        - group: ""
          kind: ConfigMap
          jqPathExpressions:
            - .data.someKey  # Bỏ qua 1 key cụ thể
    ```

    **Use case:** HPA tự scale replicas → ArgoCD detect drift → ignore replicas diff để tránh conflict.

---

### Câu 17: ArgoCD có hỗ trợ HPA (Horizontal Pod Autoscaler) không?

    **Có**, nhưng cần cấu hình đúng để tránh conflict:

    1. **Xóa `replicas` khỏi Deployment YAML** — Để HPA quản lý
    2. **Hoặc dùng `ignoreDifferences`** — Bỏ qua replicas field
    3. **Hoặc tắt Self-heal cho Deployment** — Chỉ Self-heal cho resources khác

    ```yaml
    spec:
      ignoreDifferences:
        - group: apps
          kind: Deployment
          jsonPointers:
            - /spec/replicas
    ```

    Không làm như vậy → ArgoCD liên tục rollback replicas về giá trị trong Git, conflict với HPA.

---

### Câu 18: Managed Resources và Live Resources khác nhau thế nào?

    | | Managed Resources | Live Resources |
    |---|-------------------|----------------|
    | **Nguồn** | Defined trong Git | Chạy trên cluster |
    | **Ai quản lý** | ArgoCD theo dõi | Kubernetes runtime |
    | **Sync Status** | Git state | Cluster state |

    **OutOfSync** = Managed ≠ Live. ArgoCD hiển thị diff giữa 2 trạng thái này.

    **Orphaned Resources** = Resources trên cluster mà ArgoCD **không quản lý** (không có trong Git).

---

### Câu 19: `argocd app terminate-op` dùng khi nào?

    Dùng để **hủy sync operation** đang chạy:

    ```bash
    argocd app terminate-op <app-name>
    ```

    **Khi nào cần?**
    - Sync bị treo (stuck) do resource lỗi
    - Phát hiện sync sai → cần dừng ngay
    - Hook (Job) chạy quá lâu

    **Lưu ý:** Terminate chỉ dừng operation, không rollback những gì đã apply.

---

### Câu 20: Sync Status "Unknown" xảy ra khi nào?

    **Nguyên nhân:**
    1. ArgoCD **không kết nối được Git** — Network issue, credentials hết hạn
    2. ArgoCD **không kết nối được cluster** — Cluster down, kubeconfig invalid
    3. **Repository Server quá tải** — Quá nhiều apps cùng lúc
    4. **Application mới tạo** — Chưa có lần reconcile đầu tiên

    **Debug:**
    ```bash
    argocd app get <app-name>  # Xem chi tiết lỗi
    kubectl logs -n argocd deployment/argocd-application-controller
    ```

---

## Phần 3: Advanced Sync & Troubleshooting (Câu 21-30)

### Câu 21: `Replace` vs `Apply` sync strategy khác nhau thế nào?

    | | Apply (mặc định) | Replace |
    |---|------------------|---------|
    | **Command** | `kubectl apply` | `kubectl replace` |
    | **Behavior** | Merge changes | Replace toàn bộ resource |
    | **Safe** | An toàn hơn | Nguy hiểm hơn (mất field không có trong YAML) |

    ```yaml
    syncOptions:
      - Replace=true  # Dùng replace thay vì apply
    ```

    **Khi nào dùng Replace?** Khi `apply` gặp conflict do annotation quá lớn (`last-applied-configuration` vượt quá limit).

---

### Câu 22: `ServerSideApply=true` là gì?

    **Server-Side Apply (SSA)** là tính năng K8s cho phép API server quản lý field ownership, thay vì client.

    ```yaml
    syncOptions:
      - ServerSideApply=true
    ```

    **Ưu điểm:**
    - Giải quyết conflict khi nhiều controller cùng sửa 1 resource
    - Không giới hạn annotation size (khác `kubectl apply`)
    - Tương thích tốt hơn với HPA, VPA, và các controllers khác

    **Khi nào dùng?** Khi gặp "metadata.annotations too long" error hoặc conflict với controllers.

---

### Câu 23: Selective Sync là gì?

    Cho phép sync **chỉ một số resources** thay vì toàn bộ Application:

    ```bash
    # Sync chỉ Deployment
    argocd app sync <app> --resource apps:Deployment:my-deployment

    # Sync chỉ Service
    argocd app sync <app> --resource :Service:my-service
    ```

    **Use case:** App có nhiều resources, chỉ muốn update 1 Deployment mà không ảnh hưởng resources khác.

---

### Câu 24: Force sync khác gì normal sync?

    ```bash
    # Normal sync
    argocd app sync <app>

    # Force sync
    argocd app sync <app> --force
    ```

    **Force sync** sẽ **delete rồi recreate** resources thay vì update. Tương đương `kubectl delete` + `kubectl apply`.

    **⚠️ Gây downtime!** Pods bị xóa rồi tạo lại. Chỉ dùng khi normal sync không hoạt động (ví dụ: immutable fields).

---

### Câu 25: Dry-run sync dùng để làm gì?

    ```bash
    argocd app sync <app> --dry-run
    ```

    Cho phép **preview** những gì sẽ thay đổi mà **không thực sự apply**. Output hiển thị diff giữa Git và Cluster.

    **Use case:** Review thay đổi trước khi deploy lên production. Tương tự `kubectl apply --dry-run=server`.

---

### Câu 26: Annotation `argocd.argoproj.io/compare-options: IgnoreExtraneous` nghĩa là gì?

    Nói ArgoCD **bỏ qua** resource khi tính toán Sync Status. Resource vẫn tồn tại trên cluster nhưng ArgoCD coi như không liên quan.

    ```yaml
    metadata:
      annotations:
        argocd.argoproj.io/compare-options: IgnoreExtraneous
    ```

    **Use case:** Resources được tạo bởi operators hoặc controllers khác mà ArgoCD không nên quản lý.

---

### Câu 27: Tại sao app liên tục OutOfSync dù đã sync?

    **Nguyên nhân phổ biến:**
    1. **Mutating webhook** — Admission controller thêm/sửa fields → diff
    2. **Default values** — K8s API server thêm default fields không có trong YAML
    3. **Controller modifications** — HPA, VPA sửa replicas/resources
    4. **Immutable fields** — Không thể update field đã set (Job spec)

    **Giải quyết:** Dùng `ignoreDifferences` cho fields bị mutate:
    ```yaml
    spec:
      ignoreDifferences:
        - group: ""
          kind: Service
          jsonPointers:
            - /spec/clusterIP
    ```

---

### Câu 28: Cách xem logs của ArgoCD controllers?

    ```bash
    # Application Controller logs (sync/reconcile)
    kubectl logs -n argocd deployment/argocd-application-controller -f

    # API Server logs (UI/API requests)
    kubectl logs -n argocd deployment/argocd-server -f

    # Repo Server logs (git clone/render)
    kubectl logs -n argocd deployment/argocd-repo-server -f

    # Tăng log verbosity
    kubectl edit deployment argocd-application-controller -n argocd
    # Thêm arg: --loglevel=debug
    ```

---

### Câu 29: `argocd app actions` dùng để làm gì?

    Chạy **resource actions** trực tiếp từ CLI:

    ```bash
    # Liệt kê actions có sẵn cho resource
    argocd app actions list <app> --kind Deployment

    # Restart deployment (rollout restart)
    argocd app actions run <app> restart --kind Deployment --resource-name my-deployment
    ```

    **Actions có sẵn:**
    - **Deployment:** restart
    - **StatefulSet:** restart
    - **DaemonSet:** restart
    - **Rollout (Argo):** promote, abort, retry

    **Tương đương:** `kubectl rollout restart deployment my-deployment` nhưng qua ArgoCD.

---

### Câu 30: Làm sao so sánh 2 revision của cùng Application?

    ```bash
    # Xem history
    argocd app history <app>

    # So sánh revision hiện tại vs cụ thể
    argocd app diff <app> --revision <commit-hash>

    # Xem manifest của revision cụ thể
    argocd app manifests <app> --revision <commit-hash>
    ```

    **Use case:** Debug — so sánh config trước và sau khi có lỗi để xem gì đã thay đổi. Kết hợp với `git diff <hash1> <hash2>` trên Git repo.

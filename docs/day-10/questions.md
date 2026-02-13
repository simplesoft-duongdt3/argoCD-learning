# ❓ Câu Hỏi Ôn Tập — Ngày 10: Canary & Blue/Green Deployment

## Phần 1: Argo Rollouts Concepts (Câu 1-10)

### Câu 1: Argo Rollouts là gì?

    Argo Rollouts là **Kubernetes controller** cung cấp progressive delivery: Canary, Blue/Green, analysis. Nó thay thế Kubernetes Deployment bằng resource type `Rollout` để kiểm soát traffic shifting.

---

### Câu 2: ArgoCD và Argo Rollouts khác nhau thế nào?

    | | ArgoCD | Argo Rollouts |
    |---|--------|---------------|
    | Chức năng | GitOps CD (sync Git → K8s) | Progressive Delivery (traffic shifting) |
    | Resource | Application | Rollout |
    | Scope | Toàn bộ app lifecycle | Deployment strategy only |
    | Quan hệ | Bổ trợ nhau | Bổ trợ nhau |

---

### Câu 3: Rollout resource khác Deployment thế nào?

    `Rollout` tương tự `Deployment` nhưng thêm field `strategy` để cấu hình Canary/Blue-Green. Spec `template` và `selector` giống Deployment. Rollout **thay thế** Deployment (không dùng cả 2 cho cùng app).

---

### Câu 4: Canary deployment là gì?

    Triển khai dần dần: chuyển **một phần traffic** sang version mới, tăng dần nếu không có lỗi. Ví dụ: 10% → 30% → 60% → 100%. Nếu phát hiện lỗi ở bất kỳ bước nào → abort, rollback về version cũ.

---

### Câu 5: Blue/Green deployment là gì?

    Chạy **2 environments song song**: Blue (current/active) và Green (new/preview). Green được test kỹ qua preview service. Khi sẵn sàng → switch traffic 100% từ Blue sang Green ngay lập tức. Rollback nhanh: chỉ cần switch về Blue.

---

### Câu 6: Canary vs Blue/Green — khi nào dùng cái nào?

    **Canary:** Traffic-sensitive apps (API, web), muốn kiểm tra với % users thực. **Blue/Green:** Apps cần "all-or-nothing" switch, cần preview environment riêng, downtime tolerance thấp. Canary phức tạp hơn nhưng risk thấp hơn.

---

### Câu 7: `setWeight` trong Canary steps nghĩa là gì?

    Xác định **% traffic** route đến version mới:
    ```yaml
    steps:
      - setWeight: 10    # 10% traffic → new version
      - pause: {duration: 60s}
      - setWeight: 50    # 50% traffic → new version
    ```
    Implementation phụ thuộc traffic manager (Nginx, Istio, hoặc replica-based).

---

### Câu 8: `pause` trong Canary steps có mấy loại?

    **Timed pause:** `pause: {duration: 60s}` — tự resume sau 60s
    **Manual pause:** `pause: {}` — chờ human promote
    **Analysis pause:** Chờ AnalysisRun hoàn tất (pass/fail)

---

### Câu 9: AnalysisTemplate trong Argo Rollouts là gì?

    Automated testing tại mỗi canary step. Query metrics (Prometheus, Datadog) → pass/fail tự động:
    ```yaml
    metrics:
      - name: error-rate
        provider:
          prometheus:
            query: "rate(http_errors_total[5m])"
        successCondition: "result[0] < 0.05"  # Error rate < 5%
    ```

---

### Câu 10: Promote, Abort, Retry khác nhau thế nào?

    | Command | Hành vi |
    |---------|---------|
    | `promote` | Tiến tới step tiếp theo (hoặc skip tất cả → 100%) |
    | `abort` | Dừng rollout, rollback về version cũ |
    | `retry` | Retry rollout sau khi abort (quay lại Healthy) |
    | `promote --full` | Skip tất cả remaining steps → 100% ngay |

---

## Phần 2: Configuration (Câu 11-20)

### Câu 11: Cài đặt Argo Rollouts thế nào?

    ```bash
    kubectl create namespace argo-rollouts
    kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
    ```
    Thêm kubectl plugin: download `kubectl-argo-rollouts` binary → `/usr/local/bin/`.

---

### Câu 12: Blue/Green cần mấy Services?

    **2 Services:**
    - `activeService` — Production traffic (Blue khi chưa promote, Green sau promote)
    - `previewService` — Preview/testing traffic (luôn trỏ version mới)

    ArgoCD tự quản lý selector switching giữa 2 services.

---

### Câu 13: `autoPromotionEnabled: false` trong Blue/Green nghĩa gì?

    Bắt buộc **manual promote** trước khi switch traffic. Nếu `true` → tự promote sau khi preview pods Ready. Production nên `false` để human review trước khi switch.

---

### Câu 14: `scaleDownDelaySeconds` dùng để làm gì?

    Sau khi promote, giữ ReplicaSet cũ thêm N giây trước khi scale down. Cho phép **rollback nhanh** nếu phát hiện lỗi ngay sau promote. Mặc định: 30s.

---

### Câu 15: Replica-based vs Traffic-based Canary khác nhau thế nào?

    **Replica-based** (mặc định, không cần service mesh): Scale replicas — 1/10 pods new = ~10% traffic. Không chính xác. **Traffic-based** (cần Istio/Nginx): VirtualService/Ingress route chính xác 10% HTTP requests. Chính xác nhưng phức tạp hơn.

---

### Câu 16: Argo Rollouts + Istio cấu hình thế nào?

    ```yaml
    strategy:
      canary:
        trafficRouting:
          istio:
            virtualService:
              name: my-app-vsvc
            destinationRule:
              name: my-app-destrule
    ```
    Rollouts tự update VirtualService weights theo canary steps.

---

### Câu 17: Argo Rollouts Dashboard UI truy cập thế nào?

    ```bash
    kubectl argo rollouts dashboard
    # → http://localhost:3100
    ```
    UI hiển thị rollout visualization, steps, ReplicaSets, traffic distribution.

---

### Câu 18: `kubectl argo rollouts get rollout <name> --watch` hiển thị gì?

    Live visualization của rollout progress: current step, weight, ReplicaSets (stable vs canary), pod status. Real-time update khi steps tiến triển. Press Ctrl+C để thoát.

---

### Câu 19: Trigger update cho Rollout thế nào?

    ```bash
    # Cách 1: Set image (CLI)
    kubectl argo rollouts set image <name> <container>=<new-image>

    # Cách 2: Edit YAML
    kubectl edit rollout <name>

    # Cách 3: GitOps (recommended)
    # Update image tag in Git → ArgoCD sync → Rollout triggers
    ```

---

### Câu 20: ArgoCD có native support Argo Rollouts không?

    **Có!** ArgoCD nhận diện Rollout CRD, hiển thị trong UI với health/sync status. ArgoCD UI có nút Promote/Abort cho Rollouts. Flow: Git commit → ArgoCD sync → Rollout execute canary/blue-green.

---

## Phần 3: Advanced & Troubleshooting (Câu 21-30)

### Câu 21: Abort rollout thì chuyện gì xảy ra?

    1. Traffic route 100% về stable (old) version
    2. Canary ReplicaSet scale down to 0
    3. Rollout status = **Degraded**
    4. Cần `retry` để quay lại **Healthy** status

---

### Câu 22: Rollback trong Argo Rollouts khác Kubernetes Deployment?

    **K8s Deployment:** `kubectl rollout undo` — revert YAML, recreate pods. **Argo Rollouts:** `abort` — ngay lập tức route traffic về old version, không cần recreate pods (vì old ReplicaSet vẫn running). Nhanh hơn nhiều.

---

### Câu 23: AnalysisRun tự động abort rollout khi nào?

    Khi metric query trả về kết quả **không thỏa** `successCondition`. Ví dụ: error rate > 5%, latency p99 > 500ms. AnalysisRun fail → Rollout auto-abort → traffic rollback.

---

### Câu 24: Experiments trong Argo Rollouts là gì?

    Chạy **temporary ReplicaSets** song song trong canary step để A/B testing. Không route real traffic — chỉ tạo pods để run AnalysisRun against. Tự cleanup sau experiment.

---

### Câu 25: Anti-Affinity trong Canary deployment có ý nghĩa gì?

    Đảm bảo canary pods và stable pods chạy trên **nodes khác nhau**. Tránh trường hợp node failure ảnh hưởng cả 2 versions đồng thời.

---

### Câu 26: `maxSurge` và `maxUnavailable` trong Rollout?

    Giống Deployment rolling update:
    - `maxSurge` — Số pods thêm tối đa (vd: 25% = tạo thêm 25% pods)
    - `maxUnavailable` — Số pods unavailable tối đa (vd: 0 = zero downtime)
    Áp dụng cho **non-canary** updates (khi không có canary steps).

---

### Câu 27: Rollout status "Paused" vs "Degraded"?

    **Paused:** Đang chờ ở canary step (planned pause). Normal state — chờ promote hoặc timer. **Degraded:** Rollout bị abort hoặc AnalysisRun failed. Cần human intervention (retry/fix).

---

### Câu 28: Monitoring Argo Rollouts với Prometheus?

    Key metrics:
    - `rollout_info` — Rollout metadata (phase, strategy)
    - `rollout_phase` — Current phase (Healthy, Paused, Degraded)
    - `analysis_run_info` — AnalysisRun results
    Expose qua `/metrics` endpoint trên Rollouts controller pod.

---

### Câu 29: Migrate từ Deployment sang Rollout thế nào?

    1. Change `kind: Deployment` → `kind: Rollout`
    2. Change `apiVersion` → `argoproj.io/v1alpha1`
    3. Add `strategy.canary` hoặc `strategy.blueGreen`
    4. Deploy — Rollout adopt existing ReplicaSet (zero downtime migration)

    **Lưu ý:** Xóa Deployment trước khi tạo Rollout (cùng selector → conflict).

---

### Câu 30: Full production GitOps flow với ArgoCD + Argo Rollouts?

    ```
    1. Developer push code → App repo
    2. CI pipeline build + test + push image
    3. CI update image tag in Config repo (Git commit)
    4. ArgoCD detect → sync Rollout manifest (new image)
    5. Argo Rollouts execute canary:
       a. 10% traffic → new version
       b. AnalysisRun query Prometheus
       c. Pass → 50% → 100% (auto promote)
       d. Fail → auto abort → rollback
    6. ArgoCD report Healthy/Degraded
    ```
    **End-to-end automated progressive delivery!**

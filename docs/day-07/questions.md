# ❓ Câu Hỏi Ôn Tập — Ngày 7: App of Apps Pattern

## Phần 1: Concepts (Câu 1-10)

### Câu 1: App of Apps pattern là gì?

    Một **Root Application** quản lý nhiều **Child Applications**. Root app trỏ đến thư mục Git chứa YAML định nghĩa các child apps. Sync Root = tạo/cập nhật tất cả children. Quản lý hàng chục apps bằng 1 single commit.

---

### Câu 2: Root Application khác Child Application thế nào?

    **Root App:** Source trỏ đến thư mục chứa Application YAMLs. Destination = in-cluster (argocd namespace). **Child App:** Source trỏ đến manifests thực tế (Deployment, Service). Destination = target namespace. Root quản lý lifecycle của children.

---

### Câu 3: Tại sao Root App destination là namespace `argocd`?

    Vì child Application **CRDs** sống trong namespace `argocd`. Root app tạo Application objects → chúng phải ở namespace ArgoCD chạy. Manifests mà child apps deploy thì đến namespace khác.

---

### Câu 4: Thêm app mới vào hệ thống bằng App of Apps thế nào?

    1. Tạo file Application YAML cho app mới trong thư mục children
    2. Tạo manifests cho app mới
    3. Git commit + push
    4. ArgoCD sync Root → phát hiện file mới → tạo child Application → sync child

---

### Câu 5: Xóa app khỏi hệ thống thế nào?

    Xóa file Application YAML từ thư mục children → Git push → Root sync → child Application bị prune (nếu prune=true) → K8s resources bị xóa. **Hoàn toàn qua Git!**

---

### Câu 6: App of Apps có hỗ trợ nested (app of app of apps)?

    **Có**, nhưng không khuyến khích quá 2 levels. Quá sâu → khó debug, slow sync. Best practice: 2 levels (Root → Children). Nếu cần phức tạp hơn → dùng ApplicationSet.

---

### Câu 7: Root App nên bật Auto Sync không?

    **Tùy môi trường:**
    - **Dev/Staging:** Bật Auto Sync + Prune → apps tự tạo/xóa theo Git
    - **Production:** Manual sync cho Root → review trước khi thêm/xóa apps
    - Child apps có thể có sync policy riêng (auto hoặc manual)

---

### Câu 8: Child App có bị ảnh hưởng khi Root App bị xóa?

    **Phụ thuộc cascade:**
    - `--cascade=true` (default): Xóa Root → xóa tất cả children → xóa tất cả K8s resources
    - `--cascade=false`: Xóa Root → children vẫn tồn tại (orphaned Applications)

---

### Câu 9: Git directory structure cho App of Apps nên thế nào?

    ```
    repo/
    ├── apps/                    ← Root App trỏ đến đây
    │   ├── root-app.yaml        ← Root Application
    │   └── children/            ← Child Application YAMLs
    │       ├── frontend.yaml
    │       ├── backend.yaml
    │       └── database.yaml
    ├── manifests/               ← Actual K8s manifests
    │   ├── frontend/
    │   ├── backend/
    │   └── database/
    ```
    Tách rõ: Application definitions vs K8s manifests.

---

### Câu 10: So sánh App of Apps vs ApplicationSet?

    | | App of Apps | ApplicationSet |
    |---|------------|----------------|
    | Cách tạo | Mỗi child là 1 YAML file | Template + Generator |
    | Flexibility | Mỗi child config riêng | Cùng template, khác values |
    | Scale | 10-50 apps | 50-1000 apps |
    | Maintain | Nhiều files | 1 file |
    | Use case | Apps khác nhau | Apps similar pattern |

---

## Phần 2: Implementation (Câu 11-20)

### Câu 11: Root Application YAML mẫu?

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: root-app
      namespace: argocd
    spec:
      project: default
      source:
        repoURL: https://github.com/user/repo.git
        path: apps/children  # Thư mục chứa child app YAMLs
        targetRevision: HEAD
      destination:
        server: https://kubernetes.default.svc
        namespace: argocd
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
    ```

---

### Câu 12: Child Application có cần set `namespace: argocd` trong metadata không?

    **Có!** Application CRD sống trong namespace argocd. Nếu thiếu, ArgoCD có thể tạo Application ở default namespace → không hoạt động đúng.

---

### Câu 13: Child apps có thể ở project khác nhau không?

    **Có.** Mỗi child app chỉ định `spec.project` riêng. Root app ở project X, child ở project Y — hoàn toàn OK. Hữu ích cho multi-team: mỗi team có project riêng.

---

### Câu 14: Sync order giữa children có đảm bảo không?

    **Không!** ArgoCD sync children **song song** (parallel). Nếu cần order → dùng **Sync Waves** trên child Application YAMLs:
    ```yaml
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "1"  # Database trước
    ```

---

### Câu 15: Finalizer `resources-finalizer.argocd.argoproj.io` dùng để làm gì?

    Đảm bảo khi delete Application → ArgoCD xóa K8s resources trước → rồi mới xóa Application object. Ngăn orphaned resources. Nếu không có finalizer → xóa app nhưng K8s resources vẫn chạy.

---

### Câu 16: Child app bị OutOfSync nhưng Root app Synced — tại sao?

    Root app chỉ track **Application YAML files** (children definitions). Child OutOfSync = manifests trên cluster khác Git. Root Synced = application definitions khớp. Hai layers sync status riêng biệt.

---

### Câu 17: Làm sao rollback 1 child app mà không ảnh hưởng các app khác?

    Git revert chỉ thay đổi của child app đó → ArgoCD sync chỉ child đó. Hoặc rollback qua CLI: `argocd app rollback <child-app-name> <revision>`.

---

### Câu 18: Health status của Root App phản ánh gì?

    Root App health = aggregate health của tất cả children. Nếu 1 child Degraded → Root cũng Degraded. Tất cả Healthy → Root Healthy. Nó giống "dashboard" tổng quan.

---

### Câu 19: Có thể mix Helm + Kustomize + Plain YAML children không?

    **Có!** Mỗi child Application tự định nghĩa source type riêng. Frontend dùng Kustomize, Backend dùng Helm, Database dùng plain YAML — hoàn toàn OK.

---

### Câu 20: Preview changes trước khi sync Root App?

    ```bash
    argocd app diff root-app          # Xem child apps sẽ thay đổi gì
    argocd app diff <child-app-name>   # Xem manifest changes của 1 child
    argocd app sync root-app --dry-run # Dry-run sync
    ```

---

## Phần 3: Advanced & Troubleshooting (Câu 21-30)

### Câu 21: Lỗi "application already exists" khi sync Root?

    Child Application YAML trùng tên với app đã tồn tại. Fix: đổi `metadata.name` hoặc xóa app trùng trước: `argocd app delete <name>`.

---

### Câu 22: App of Apps + Helm có được không?

    **Có!** Root app dùng Helm chart mà template output là Application CRDs. Use case: parameterize children bằng Helm values. Nhưng phức tạp hơn, thường dùng ApplicationSet thay thế.

---

### Câu 23: Có nên dùng App of Apps cho 100+ microservices?

    **Không.** 100+ Application YAML files khó maintain. Nên dùng **ApplicationSet** — 1 template + generator tự tạo 100+ apps. App of Apps phù hợp cho 5-30 apps có cấu hình khác nhau.

---

### Câu 24: Orphaned resources detection hoạt động thế nào?

    ArgoCD detect resources trên cluster **thuộc namespace** mà Application quản lý nhưng **không có trong Git**. Cấu hình trong AppProject:
    ```yaml
    orphanedResources:
      warn: true  # Chỉ cảnh báo
      # ignore: để bỏ qua resources cụ thể
    ```

---

### Câu 25: Tại sao child app bị "stuck" ở Progressing?

    Child app đang chờ resource Ready (vd: Deployment chờ pods). Nguyên nhân: image pull error, insufficient resources, failing health checks. Debug: `argocd app get <child> --show-operation` hoặc `kubectl describe pod`.

---

### Câu 26: Multi-repo App of Apps có được không?

    **Có!** Mỗi child Application trỏ đến repo khác nhau. Root trỏ đến repo chứa Application YAMLs. Rất phổ biến: 1 "organization" repo chứa app definitions, mỗi team có repo manifests riêng.

---

### Câu 27: Làm sao giám sát health của toàn bộ App of Apps hierarchy?

    1. ArgoCD UI — click Root app → thấy tree visualization
    2. CLI: `argocd app list` — thấy all apps + health
    3. Prometheus metrics: `argocd_app_health_status`
    4. Notifications: configure alert khi child Degraded

---

### Câu 28: Backup app definitions thế nào?

    App definitions đã ở trong Git → Git = backup! Nếu muốn backup ArgoCD state (bao gồm sync history):
    ```bash
    argocd admin export > argocd-backup.yaml
    # Restore:
    argocd admin import < argocd-backup.yaml
    ```

---

### Câu 29: App of Apps + GitOps cho ArgoCD itself?

    **Self-managing ArgoCD:** ArgoCD quản lý chính nó qua App of Apps. Root app tạo child apps, 1 child app = ArgoCD installation. Bootstrap: cài ArgoCD manual lần đầu → tạo Root app → ArgoCD tự quản lý từ đó.

---

### Câu 30: Migration từ standalone apps sang App of Apps?

    1. Tạo Application YAML cho mỗi existing app trong children folder
    2. Tạo Root Application trỏ đến children folder
    3. Sync Root → ArgoCD adopt existing apps (nếu tên khớp) hoặc tạo duplicate
    4. **Best practice:** Test trên staging trước, vì có thể tạo duplicate apps nếu tên không khớp

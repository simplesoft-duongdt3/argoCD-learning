# ❓ Câu Hỏi Ôn Tập — Ngày 8: ApplicationSet

## Phần 1: ApplicationSet Concepts (Câu 1-10)

### Câu 1: ApplicationSet là gì?

    ApplicationSet là CRD cho phép **tự động tạo nhiều Applications** từ 1 template + generator. Thay vì viết 10 Application YAMLs, viết 1 ApplicationSet → ArgoCD tự tạo 10 apps.

---

### Câu 2: ApplicationSet khác Application thế nào?

    **Application:** 1 YAML = 1 app. **ApplicationSet:** 1 YAML = N apps (template + generator). ApplicationSet là "factory" tạo Applications dựa trên data từ generators.

---

### Câu 3: Liệt kê các Generator types?

    1. **List** — Danh sách static values
    2. **Cluster** — Tự detect clusters đã đăng ký
    3. **Git Directory** — Tự detect folders trong Git
    4. **Git File** — Đọc config từ JSON/YAML files trong Git
    5. **Matrix** — Kết hợp 2 generators (cross product)
    6. **Merge** — Merge nhiều generators
    7. **SCM Provider** — Scan repos từ GitHub/GitLab org
    8. **Pull Request** — Tạo app cho mỗi PR

---

### Câu 4: List Generator hoạt động thế nào?

    Khai báo danh sách values → template tạo 1 app per entry:
    ```yaml
    generators:
      - list:
          elements:
            - cluster: dev
              url: https://dev-cluster:6443
            - cluster: prod
              url: https://prod-cluster:6443
    ```
    Template dùng `{{cluster}}`, `{{url}}` để tạo 2 apps.

---

### Câu 5: Git Directory Generator hoạt động thế nào?

    Scan thư mục Git, mỗi subfolder = 1 Application:
    ```yaml
    generators:
      - git:
          repoURL: https://github.com/user/repo.git
          directories:
            - path: apps/*    # Mỗi folder trong apps/ = 1 app
    ```
    Thêm folder mới vào Git → ApplicationSet tự tạo app mới.

---

### Câu 6: Cluster Generator hoạt động thế nào?

    Tạo 1 app per cluster đã đăng ký trong ArgoCD:
    ```yaml
    generators:
      - clusters:
          selector:
            matchLabels:
              env: prod    # Chỉ clusters có label env=prod
    ```
    Thêm cluster mới (có label đúng) → auto-create app.

---

### Câu 7: Git File Generator khác Git Directory Generator thế nào?

    **Directory:** Dựa trên folder structure. **File:** Đọc nội dung JSON/YAML file để lấy values. File Generator linh hoạt hơn — mỗi file có thể chứa nhiều config fields tùy ý.

---

### Câu 8: Matrix Generator dùng khi nào?

    Kết hợp 2 generators tạo **cross product**. Ví dụ: 3 apps × 2 clusters = 6 Applications. Use case: deploy tất cả apps lên tất cả clusters.
    ```yaml
    generators:
      - matrix:
          generators:
            - git: {directories: [{path: apps/*}]}  # 3 apps
            - clusters: {selector: {matchLabels: {env: prod}}}  # 2 clusters
    ```

---

### Câu 9: Template trong ApplicationSet dùng gì để reference values?

    Dùng **double curly braces**: `{{name}}`, `{{path}}`, `{{cluster}}`. Giống Go template nhưng đơn giản hơn — chỉ string substitution, không có logic (if/for).

---

### Câu 10: Khi nào nên dùng ApplicationSet thay vì App of Apps?

    **ApplicationSet:** Apps cùng pattern (cùng config structure, chỉ khác values). Scale lớn (50+). **App of Apps:** Apps khác nhau hoàn toàn (mỗi app config riêng). Scale nhỏ (5-30).

---

## Phần 2: Configuration (Câu 11-20)

### Câu 11: ApplicationSet YAML mẫu (List Generator)?

    ```yaml
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: my-appset
      namespace: argocd
    spec:
      generators:
        - list:
            elements:
              - env: dev
                namespace: dev
              - env: prod
                namespace: prod
      template:
        metadata:
          name: 'myapp-{{env}}'
        spec:
          project: default
          source:
            repoURL: https://github.com/user/repo.git
            path: 'overlays/{{env}}'
          destination:
            server: https://kubernetes.default.svc
            namespace: '{{namespace}}'
    ```

---

### Câu 12: `syncPolicy` trong ApplicationSet khác trong Application?

    ApplicationSet có **2 cấp** syncPolicy:
    1. **ApplicationSet level:** Control khi nào tạo/xóa Applications (`preserveResourcesOnDeletion`)
    2. **Template level:** Control sync behavior của generated Applications (automated, selfHeal, prune)

---

### Câu 13: `preserveResourcesOnDeletion` dùng để làm gì?

    Khi xóa ApplicationSet → giữ lại generated Applications (không cascade delete):
    ```yaml
    syncPolicy:
      preserveResourcesOnDeletion: true
    ```
    **Mặc định false** — xóa ApplicationSet = xóa tất cả apps nó tạo ra.

---

### Câu 14: Exclude specific directories trong Git Generator thế nào?

    ```yaml
    generators:
      - git:
          directories:
            - path: apps/*
            - path: apps/deprecated    # Exclude
              exclude: true
    ```

---

### Câu 15: Cluster Generator có include in-cluster không?

    **Có**, mặc định include tất cả clusters kể cả in-cluster (`https://kubernetes.default.svc`). Để exclude: dùng label selector mà in-cluster không có.

---

### Câu 16: Template override là gì?

    Cho phép override template values cho entries cụ thể trong List Generator:
    ```yaml
    elements:
      - cluster: staging
        values:
          syncPolicy: automated
      - cluster: prod
        values:
          syncPolicy: manual
    ```

---

### Câu 17: `goTemplate` trong ApplicationSet dùng để làm gì?

    Bật Go template engine thay vì simple string substitution:
    ```yaml
    spec:
      goTemplate: true
      goTemplateOptions: ["missingkey=error"]
      template:
        metadata:
          name: '{{.name | lower}}'  # Go template functions
    ```
    Cho phép dùng functions, conditionals, loops.

---

### Câu 18: SCM Provider Generator hoạt động thế nào?

    Scan tất cả repos trong GitHub/GitLab organization, tạo 1 app per repo (filter bằng conditions):
    ```yaml
    generators:
      - scmProvider:
          github:
            organization: my-org
          filters:
            - repositoryMatch: "^service-.*"  # Chỉ repos prefix "service-"
    ```

---

### Câu 19: Pull Request Generator dùng cho gì?

    Tạo **preview environment** cho mỗi PR. PR được tạo → app deploy → PR merge/close → app xóa. Perfect cho testing/review environments.
    ```yaml
    generators:
      - pullRequest:
          github:
            owner: my-org
            repo: my-app
    ```

---

### Câu 20: Merge Generator khác Matrix thế nào?

    **Matrix:** Cross product (A × B). **Merge:** Combine multiple generators, merging matching entries. Use case: base config từ generator A + override từ generator B, merge bằng key field.

---

## Phần 3: Advanced & Troubleshooting (Câu 21-30)

### Câu 21: ApplicationSet có support multi-source không?

    **Có** (ArgoCD 2.6+). Template có thể dùng `sources` (plural) thay vì `source`. Hữu ích khi chart ở 1 repo, values ở repo khác.

---

### Câu 22: Rate limiting trong ApplicationSet?

    ApplicationSet controller tạo apps dần dần để tránh overwhelm API server:
    ```yaml
    spec:
      strategy:
        type: RollingSync
        rollingSync:
          steps:
            - matchExpressions:
                - key: env
                  operator: In
                  values: [staging]
            - matchExpressions:
                - key: env
                  operator: In
                  values: [prod]
    ```

---

### Câu 23: RollingSync strategy là gì?

    Sync generated apps theo thứ tự (staging trước, prod sau). Cho phép canary approach ở ApplicationSet level. Chờ staging healthy → sync prod.

---

### Câu 24: Lỗi "unable to generate applications" — debug thế nào?

    1. Check ApplicationSet controller logs: `kubectl logs -n argocd deployment/argocd-applicationset-controller`
    2. Check ApplicationSet status: `kubectl get applicationset <name> -n argocd -o yaml`
    3. Common: Git path sai, cluster selector không match, template syntax error

---

### Câu 25: ApplicationSet từ tạo mấy app nếu không có generator elements?

    **0 apps.** Không có elements/matches → không generate gì. Existing apps (nếu có) sẽ bị **xóa** (trừ khi `preserveResourcesOnDeletion: true`).

---

### Câu 26: Có thể dùng ApplicationSet với Private repos không?

    **Có.** Credentials cấu hình trong ArgoCD (repo credentials) hoặc trong SCM Provider config (access token). ApplicationSet controller dùng ArgoCD's repo credentials.

---

### Câu 27: Cập nhật template → ảnh hưởng existing apps không?

    **Có!** ApplicationSet controller reconcile liên tục. Template thay đổi → tất cả generated apps update theo. **Cẩn thận:** template change ảnh hưởng N apps đồng thời.

---

### Câu 28: ApplicationSet controller là separate pod?

    **Có**, từ ArgoCD 2.5+. Chạy riêng: `argocd-applicationset-controller`. Trước đó nó build-in Application Controller. Xem: `kubectl get pods -n argocd`.

---

### Câu 29: Giới hạn số apps 1 ApplicationSet có thể tạo?

    Không có giới hạn cứng. Nhưng nhiều apps (1000+) → tăng load controller, slow reconcile. Matrix generators đặc biệt có thể tạo rất nhiều (N × M). Set `maxGeneratedApps` để giới hạn an toàn.

---

### Câu 30: Best practices cho ApplicationSet production?

    1. **Pin targetRevision** — không dùng HEAD cho prod
    2. **Test trên staging** trước khi change template
    3. **Set `preserveResourcesOnDeletion`** cho critical apps
    4. **Dùng RollingSync** — staging before prod
    5. **Monitor** — alert khi generated apps Degraded
    6. **Limit generators** — dùng filters/selectors cẩn thận
    7. **PR review** cho template changes (ảnh hưởng nhiều apps)

# ❓ Câu Hỏi Ôn Tập — Ngày 5: Kustomize

## Phần 1: Kustomize Basics (Câu 1-10)

### Câu 1: Kustomize là gì?

    Kustomize là tool tích hợp sẵn trong `kubectl` cho phép **customize** Kubernetes YAML mà không cần template engine. Nó dùng khái niệm **Base + Overlays** để tạo variant cho các môi trường khác nhau mà không duplicate YAML.

---

### Câu 2: Kustomize khác Helm thế nào?

    | | Kustomize | Helm |
    |---|-----------|------|
    | Approach | Patch/overlay lên base YAML | Template với variables |
    | Complexity | Đơn giản, không cần học syntax mới | Phức tạp hơn (Go templates) |
    | Packaging | Không package | Chart package |
    | Sharing | Khó share | Dễ share qua Helm repo |
    | Use case | Internal, multi-env config | Reusable packages, community charts |

---

### Câu 3: `kustomization.yaml` chứa gì?

    File khai báo resources, patches, transformers:
    ```yaml
    apiVersion: kustomize.config.k8s.io/v1beta1
    kind: Kustomization
    resources:        # Danh sách YAML files
      - deployment.yaml
      - service.yaml
    namePrefix: dev-  # Prefix cho tên resources
    namespace: dev    # Override namespace
    labels:           # Thêm labels
      - pairs:
          env: dev
    ```

---

### Câu 4: Base và Overlay là gì?

    **Base** = YAML gốc, dùng chung cho mọi môi trường. **Overlay** = patches/customizations riêng cho từng môi trường (dev, staging, prod). Overlay reference Base và thêm/sửa fields.
    ```
    base/          ← YAML gốc
    overlays/
      dev/         ← Overlay cho dev (ít replicas, ít resources)
      prod/        ← Overlay cho prod (nhiều replicas, nhiều resources)
    ```

---

### Câu 5: ArgoCD auto-detect Kustomize thế nào?

    ArgoCD tự nhận diện khi thấy `kustomization.yaml`, `kustomization.yml`, hoặc `Kustomization` trong thư mục. Không cần cấu hình gì thêm.

---

### Câu 6: `namePrefix` và `nameSuffix` dùng để làm gì?

    Thêm prefix/suffix vào tên **tất cả** resources:
    ```yaml
    namePrefix: dev-    # deployment → dev-deployment
    nameSuffix: -v2     # service → service-v2
    ```
    Tự động update cả references (selector, serviceAccountName, etc.).

---

### Câu 7: `commonLabels` hoạt động thế nào?

    Thêm labels vào **tất cả** resources VÀ tự động update selectors:
    ```yaml
    commonLabels:
      app: my-app
      env: dev
    ```
    ⚠️ Cẩn thận: thay đổi `commonLabels` trên app đã deploy sẽ gây lỗi vì selector là immutable.

---

### Câu 8: Cách dùng `patchesStrategicMerge`?

    Merge patch vào base resource, chỉ cần ghi fields muốn thay đổi:
    ```yaml
    # In overlay kustomization.yaml:
    patchesStrategicMerge:
      - increase-replicas.yaml

    # increase-replicas.yaml:
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: my-app  # Phải khớp tên
    spec:
      replicas: 5   # Chỉ field này bị override
    ```

---

### Câu 9: `patchesJson6902` khác gì Strategic Merge?

    **JSON Patch** dùng operations cụ thể (add/remove/replace), chính xác hơn:
    ```yaml
    patches:
      - target:
          kind: Deployment
          name: my-app
        patch: |-
          - op: replace
            path: /spec/replicas
            value: 5
          - op: add
            path: /metadata/labels/version
            value: "v2"
    ```
    Use case: khi strategic merge không đủ granular.

---

### Câu 10: `configMapGenerator` sinh ConfigMap thế nào?

    Tự tạo ConfigMap + hash suffix (auto rollout khi config thay đổi):
    ```yaml
    configMapGenerator:
      - name: app-config
        literals:
          - DB_HOST=localhost
        files:
          - config.json
    ```
    Output: `app-config-abc123` (hash suffix buộc Deployment recreate pods khi config đổi).

---

## Phần 2: Kustomize + ArgoCD (Câu 11-20)

### Câu 11: Cấu hình Application trỏ đến Kustomize overlay thế nào?

    ```yaml
    source:
      repoURL: https://github.com/user/repo.git
      path: kustomize/overlays/dev    # Trỏ đến overlay folder
      targetRevision: HEAD
    ```
    ArgoCD tự chạy `kustomize build` trên thư mục này.

---

### Câu 12: Làm sao deploy dev/prod cùng repo bằng Kustomize?

    Tạo 2 ArgoCD Applications, mỗi cái trỏ đến overlay khác nhau:
    - App Dev: `path: kustomize/overlays/dev`
    - App Prod: `path: kustomize/overlays/prod`

---

### Câu 13: `kustomize.buildOptions` trong ArgoCD dùng để làm gì?

    Truyền flags cho `kustomize build`:
    ```yaml
    # Trong Application spec:
    kustomize:
      buildOptions: --enable-alpha-plugins --enable-helm

    # Hoặc global trong argocd-cm:
    kustomize.buildOptions: --load-restrictor LoadRestrictionsNone
    ```

---

### Câu 14: Kustomize có thể wrap Helm chart không?

    **Có!** Dùng `helmCharts` trong kustomization.yaml (cần `--enable-helm` flag):
    ```yaml
    helmCharts:
      - name: redis
        repo: https://charts.bitnami.com/bitnami
        version: 19.6.4
        valuesFile: values.yaml
    ```
    Cho phép post-process Helm output bằng Kustomize patches.

---

### Câu 15: `secretGenerator` hoạt động thế nào?

    Giống `configMapGenerator` nhưng tạo Secret:
    ```yaml
    secretGenerator:
      - name: db-secret
        literals:
          - password=my-secret-pass
        type: Opaque
    ```
    ⚠️ Cẩn thận: values trong Git → không an toàn. Nên dùng Sealed Secrets hoặc External Secrets.

---

### Câu 16: `components` trong Kustomize là gì?

    Components là **reusable bundles** có thể include vào nhiều overlays:
    ```yaml
    # overlays/dev/kustomization.yaml
    components:
      - ../../components/monitoring
      - ../../components/logging
    ```
    Use case: thêm monitoring/logging vào dev nhưng không prod. DRY hơn copy patches.

---

### Câu 17: `images` transformer dùng thế nào?

    Override image name/tag mà không cần patch file:
    ```yaml
    images:
      - name: nginx
        newName: my-registry/nginx
        newTag: "2.0"
    ```
    Tự tìm tất cả containers dùng image `nginx` và thay thế. Rất tiện cho CI/CD update image tag.

---

### Câu 18: `replicas` transformer (Kustomize 4.x+) hoạt động thế nào?

    Override replicas mà không cần patch file:
    ```yaml
    replicas:
      - name: my-deployment
        count: 5
    ```
    Tự tìm Deployment/StatefulSet tên `my-deployment` và set replicas = 5.

---

### Câu 19: Thứ tự áp dụng transformers trong Kustomize?

    1. `resources` — Load base YAMLs
    2. `generators` — Tạo ConfigMap/Secret
    3. `patches` — Apply patches
    4. `transformers` — namePrefix, labels, images, replicas
    5. `validators` — Validate output

    Kustomize đảm bảo thứ tự nhất quán, không phụ thuộc vào thứ tự khai báo trong file.

---

### Câu 20: Lỗi `no matches for kind` khi build — nguyên nhân?

    Kustomize validation yêu cầu CRDs phải có schema. Fix:
    ```yaml
    # Trong kustomization.yaml
    configurations:
      - kustomizeconfig.yaml
    # Hoặc dùng --load-restrictor LoadRestrictionsNone
    ```
    Hoặc tắt validation trong ArgoCD: `kustomize.buildOptions: --load-restrictor LoadRestrictionsNone`

---

## Phần 3: Advanced Kustomize (Câu 21-30)

### Câu 21: Remote base trong Kustomize là gì?

    Reference base từ remote Git URL:
    ```yaml
    resources:
      - https://github.com/user/repo//base?ref=v1.0.0
    ```
    Cho phép share base giữa nhiều teams/repos. Nên pin `ref` tag.

---

### Câu 22: `vars` deprecated, thay thế bằng gì?

    Dùng **replacements** (Kustomize 5.x+):
    ```yaml
    replacements:
      - source:
          kind: ConfigMap
          name: app-config
          fieldPath: data.DB_HOST
        targets:
          - select:
              kind: Deployment
            fieldPaths:
              - spec.template.spec.containers.[name=app].env.[name=DB_HOST].value
    ```

---

### Câu 23: Dùng Kustomize cho multi-cluster config thế nào?

    Mỗi cluster = 1 overlay: `overlays/cluster-a/`, `overlays/cluster-b/`. Mỗi overlay set namespace, replicas, image tag riêng. Kết hợp với ApplicationSet (Day 8) để auto-deploy.

---

### Câu 24: `namespace` trong kustomization.yaml override tất cả resources?

    **Có**, set namespace cho tất cả resources. Trừ cluster-scoped resources (ClusterRole, Namespace, etc.). Rất tiện cho multi-env: base không set namespace, overlay set namespace riêng.

---

### Câu 25: `commonAnnotations` khác gì patch?

    `commonAnnotations` thêm annotation vào **tất cả** resources, giống `commonLabels` nhưng cho annotations. Patch chỉ áp dụng cho resource cụ thể. commonAnnotations tiện cho global metadata.

---

### Câu 26: Inline patch vs file patch?

    **Inline** — viết trực tiếp trong kustomization.yaml (tiện cho changes nhỏ):
    ```yaml
    patches:
      - patch: |-
          - op: replace
            path: /spec/replicas
            value: 3
        target:
          kind: Deployment
    ```
    **File** — viết trong file riêng (cho changes phức tạp). Cả hai đều hoạt động giống nhau.

---

### Câu 27: `generatorOptions` dùng để làm gì?

    Control behavior của ConfigMap/Secret generators:
    ```yaml
    generatorOptions:
      disableNameSuffixHash: true   # Tắt hash suffix
      labels:
        type: generated
    ```
    `disableNameSuffixHash` hữu ích khi không muốn Deployment recreate pods mỗi khi config đổi.

---

### Câu 28: Kustomize version conflict giữa local và ArgoCD?

    ArgoCD bundle Kustomize version cụ thể. Kiểm tra: `argocd version` → xem kustomize version. Nếu local version khác → build output có thể khác. Đảm bảo local version khớp hoặc dùng `kustomize.buildOptions` trong ArgoCD.

---

### Câu 29: Khi nào nên dùng Kustomize thay vì Helm?

    **Kustomize:** Internal apps, simple multi-env config, không cần package/share. **Helm:** Community charts, complex templating, cần share/distribute. Có thể dùng cả hai — Kustomize overlay Helm chart output.

---

### Câu 30: `sortOptions` trong Kustomize dùng để làm gì?

    Control thứ tự output resources:
    ```yaml
    sortOptions:
      order: fifo    # First-in-first-out (theo thứ tự khai báo)
      # hoặc: legacy (theo kind ordering mặc định)
    ```
    Quan trọng khi resources có dependency order (Namespace trước Deployment).

# ❓ Câu Hỏi Ôn Tập — Ngày 5: Kustomize

## Phần 1: Kustomize Basics (Câu 1-10)

### Câu 1: Kustomize là gì?
<details><summary>📖 Đáp án</summary>

Kustomize là tool tích hợp sẵn trong `kubectl` cho phép **customize** Kubernetes YAML mà không cần template engine. Nó dùng khái niệm **Base + Overlays** để tạo variant cho các môi trường khác nhau mà không duplicate YAML.
</details>

---

### Câu 2: Kustomize khác Helm thế nào?
<details><summary>📖 Đáp án</summary>

| | Kustomize | Helm |
|---|-----------|------|
| Approach | Patch/overlay lên base YAML | Template với variables |
| Complexity | Đơn giản, không cần học syntax mới | Phức tạp hơn (Go templates) |
| Packaging | Không package | Chart package |
| Sharing | Khó share | Dễ share qua Helm repo |
| Use case | Internal, multi-env config | Reusable packages, community charts |
</details>

---

### Câu 3: `kustomization.yaml` chứa gì?
<details><summary>📖 Đáp án</summary>

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
</details>

---

### Câu 4: Base và Overlay là gì?
<details><summary>📖 Đáp án</summary>

**Base** = YAML gốc, dùng chung cho mọi môi trường. **Overlay** = patches/customizations riêng cho từng môi trường (dev, staging, prod). Overlay reference Base và thêm/sửa fields.
```
base/          ← YAML gốc
overlays/
  dev/         ← Overlay cho dev (ít replicas, ít resources)
  prod/        ← Overlay cho prod (nhiều replicas, nhiều resources)
```
</details>

---

### Câu 5: ArgoCD auto-detect Kustomize thế nào?
<details><summary>📖 Đáp án</summary>

ArgoCD tự nhận diện khi thấy `kustomization.yaml`, `kustomization.yml`, hoặc `Kustomization` trong thư mục. Không cần cấu hình gì thêm.
</details>

---

### Câu 6: `namePrefix` và `nameSuffix` dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Thêm prefix/suffix vào tên **tất cả** resources:
```yaml
namePrefix: dev-    # deployment → dev-deployment
nameSuffix: -v2     # service → service-v2
```
Tự động update cả references (selector, serviceAccountName, etc.).
</details>

---

### Câu 7: `commonLabels` hoạt động thế nào?
<details><summary>📖 Đáp án</summary>

Thêm labels vào **tất cả** resources VÀ tự động update selectors:
```yaml
commonLabels:
  app: my-app
  env: dev
```
⚠️ Cẩn thận: thay đổi `commonLabels` trên app đã deploy sẽ gây lỗi vì selector là immutable.
</details>

---

### Câu 8: Cách dùng `patchesStrategicMerge`?
<details><summary>📖 Đáp án</summary>

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
</details>

---

### Câu 9: `patchesJson6902` khác gì Strategic Merge?
<details><summary>📖 Đáp án</summary>

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
</details>

---

### Câu 10: `configMapGenerator` sinh ConfigMap thế nào?
<details><summary>📖 Đáp án</summary>

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
</details>

---

## Phần 2: Kustomize + ArgoCD (Câu 11-20)

### Câu 11: Cấu hình Application trỏ đến Kustomize overlay thế nào?
<details><summary>📖 Đáp án</summary>

```yaml
source:
  repoURL: https://github.com/user/repo.git
  path: kustomize/overlays/dev    # Trỏ đến overlay folder
  targetRevision: HEAD
```
ArgoCD tự chạy `kustomize build` trên thư mục này.
</details>

---

### Câu 12: Làm sao deploy dev/prod cùng repo bằng Kustomize?
<details><summary>📖 Đáp án</summary>

Tạo 2 ArgoCD Applications, mỗi cái trỏ đến overlay khác nhau:
- App Dev: `path: kustomize/overlays/dev`
- App Prod: `path: kustomize/overlays/prod`
</details>

---

### Câu 13: `kustomize.buildOptions` trong ArgoCD dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Truyền flags cho `kustomize build`:
```yaml
# Trong Application spec:
kustomize:
  buildOptions: --enable-alpha-plugins --enable-helm

# Hoặc global trong argocd-cm:
kustomize.buildOptions: --load-restrictor LoadRestrictionsNone
```
</details>

---

### Câu 14: Kustomize có thể wrap Helm chart không?
<details><summary>📖 Đáp án</summary>

**Có!** Dùng `helmCharts` trong kustomization.yaml (cần `--enable-helm` flag):
```yaml
helmCharts:
  - name: redis
    repo: https://charts.bitnami.com/bitnami
    version: 19.6.4
    valuesFile: values.yaml
```
Cho phép post-process Helm output bằng Kustomize patches.
</details>

---

### Câu 15: `secretGenerator` hoạt động thế nào?
<details><summary>📖 Đáp án</summary>

Giống `configMapGenerator` nhưng tạo Secret:
```yaml
secretGenerator:
  - name: db-secret
    literals:
      - password=my-secret-pass
    type: Opaque
```
⚠️ Cẩn thận: values trong Git → không an toàn. Nên dùng Sealed Secrets hoặc External Secrets.
</details>

---

### Câu 16: `components` trong Kustomize là gì?
<details><summary>📖 Đáp án</summary>

Components là **reusable bundles** có thể include vào nhiều overlays:
```yaml
# overlays/dev/kustomization.yaml
components:
  - ../../components/monitoring
  - ../../components/logging
```
Use case: thêm monitoring/logging vào dev nhưng không prod. DRY hơn copy patches.
</details>

---

### Câu 17: `images` transformer dùng thế nào?
<details><summary>📖 Đáp án</summary>

Override image name/tag mà không cần patch file:
```yaml
images:
  - name: nginx
    newName: my-registry/nginx
    newTag: "2.0"
```
Tự tìm tất cả containers dùng image `nginx` và thay thế. Rất tiện cho CI/CD update image tag.
</details>

---

### Câu 18: `replicas` transformer (Kustomize 4.x+) hoạt động thế nào?
<details><summary>📖 Đáp án</summary>

Override replicas mà không cần patch file:
```yaml
replicas:
  - name: my-deployment
    count: 5
```
Tự tìm Deployment/StatefulSet tên `my-deployment` và set replicas = 5.
</details>

---

### Câu 19: Thứ tự áp dụng transformers trong Kustomize?
<details><summary>📖 Đáp án</summary>

1. `resources` — Load base YAMLs
2. `generators` — Tạo ConfigMap/Secret
3. `patches` — Apply patches
4. `transformers` — namePrefix, labels, images, replicas
5. `validators` — Validate output

Kustomize đảm bảo thứ tự nhất quán, không phụ thuộc vào thứ tự khai báo trong file.
</details>

---

### Câu 20: Lỗi `no matches for kind` khi build — nguyên nhân?
<details><summary>📖 Đáp án</summary>

Kustomize validation yêu cầu CRDs phải có schema. Fix:
```yaml
# Trong kustomization.yaml
configurations:
  - kustomizeconfig.yaml
# Hoặc dùng --load-restrictor LoadRestrictionsNone
```
Hoặc tắt validation trong ArgoCD: `kustomize.buildOptions: --load-restrictor LoadRestrictionsNone`
</details>

---

## Phần 3: Advanced Kustomize (Câu 21-30)

### Câu 21: Remote base trong Kustomize là gì?
<details><summary>📖 Đáp án</summary>

Reference base từ remote Git URL:
```yaml
resources:
  - https://github.com/user/repo//base?ref=v1.0.0
```
Cho phép share base giữa nhiều teams/repos. Nên pin `ref` tag.
</details>

---

### Câu 22: `vars` deprecated, thay thế bằng gì?
<details><summary>📖 Đáp án</summary>

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
</details>

---

### Câu 23: Dùng Kustomize cho multi-cluster config thế nào?
<details><summary>📖 Đáp án</summary>

Mỗi cluster = 1 overlay: `overlays/cluster-a/`, `overlays/cluster-b/`. Mỗi overlay set namespace, replicas, image tag riêng. Kết hợp với ApplicationSet (Day 8) để auto-deploy.
</details>

---

### Câu 24: `namespace` trong kustomization.yaml override tất cả resources?
<details><summary>📖 Đáp án</summary>

**Có**, set namespace cho tất cả resources. Trừ cluster-scoped resources (ClusterRole, Namespace, etc.). Rất tiện cho multi-env: base không set namespace, overlay set namespace riêng.
</details>

---

### Câu 25: `commonAnnotations` khác gì patch?
<details><summary>📖 Đáp án</summary>

`commonAnnotations` thêm annotation vào **tất cả** resources, giống `commonLabels` nhưng cho annotations. Patch chỉ áp dụng cho resource cụ thể. commonAnnotations tiện cho global metadata.
</details>

---

### Câu 26: Inline patch vs file patch?
<details><summary>📖 Đáp án</summary>

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
</details>

---

### Câu 27: `generatorOptions` dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Control behavior của ConfigMap/Secret generators:
```yaml
generatorOptions:
  disableNameSuffixHash: true   # Tắt hash suffix
  labels:
    type: generated
```
`disableNameSuffixHash` hữu ích khi không muốn Deployment recreate pods mỗi khi config đổi.
</details>

---

### Câu 28: Kustomize version conflict giữa local và ArgoCD?
<details><summary>📖 Đáp án</summary>

ArgoCD bundle Kustomize version cụ thể. Kiểm tra: `argocd version` → xem kustomize version. Nếu local version khác → build output có thể khác. Đảm bảo local version khớp hoặc dùng `kustomize.buildOptions` trong ArgoCD.
</details>

---

### Câu 29: Khi nào nên dùng Kustomize thay vì Helm?
<details><summary>📖 Đáp án</summary>

**Kustomize:** Internal apps, simple multi-env config, không cần package/share. **Helm:** Community charts, complex templating, cần share/distribute. Có thể dùng cả hai — Kustomize overlay Helm chart output.
</details>

---

### Câu 30: `sortOptions` trong Kustomize dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Control thứ tự output resources:
```yaml
sortOptions:
  order: fifo    # First-in-first-out (theo thứ tự khai báo)
  # hoặc: legacy (theo kind ordering mặc định)
```
Quan trọng khi resources có dependency order (Namespace trước Deployment).
</details>

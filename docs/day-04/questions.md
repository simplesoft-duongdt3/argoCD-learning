# ❓ Câu Hỏi Ôn Tập — Ngày 4: Làm Việc Với Helm Charts

## Phần 1: Helm Basics (Câu 1-10)

### Câu 1: Helm Chart là gì?

    Helm Chart là **package** chứa tất cả Kubernetes resources cần thiết để deploy 1 ứng dụng. Gồm: templates (YAML có biến), values.yaml (giá trị mặc định), Chart.yaml (metadata).

---

### Câu 2: ArgoCD render Helm template bằng cách nào?

    ArgoCD chạy `helm template` (không phải `helm install`) nội bộ → tạo ra plain YAML → `kubectl apply`. ArgoCD **không** tạo Helm release nên `helm list` sẽ không thấy.

---

### Câu 3: Có cần cài Helm CLI trên máy để ArgoCD deploy Helm chart không?

    **Không!** ArgoCD tích hợp Helm engine trong Repository Server. Helm CLI local chỉ cần khi debug template.

---

### Câu 4: 3 cách override Helm values trong ArgoCD?

    1. **Inline values:** `helm.values: |` — YAML string trực tiếp
    2. **Value files:** `helm.valueFiles: [values-prod.yaml]` — File trong repo
    3. **Parameters:** `helm.parameters: [{name: x, value: "y"}]` — Từng key

    Thứ tự ưu tiên: parameters > values (inline) > valueFiles > chart defaults.

---

### Câu 5: `repoURL` trỏ Helm repo vs Git repo khác nhau thế nào?

    **Helm repo:** Cần `chart` field + `targetRevision` = chart version.
    **Git repo:** Dùng `path` trỏ đến thư mục chứa Chart.yaml + `targetRevision` = branch/tag.

---

### Câu 6: `releaseName` dùng để làm gì?

    Xác định `.Release.Name` trong Helm template. Mặc định = tên Application. Quan trọng vì nhiều chart dùng nó đặt tên resources.

---

### Câu 7: Helm hooks có hoạt động trong ArgoCD không?

    **Có, nhưng được chuyển đổi:** `pre-install/upgrade` → `PreSync`, `post-install/upgrade` → `PostSync`. Hành vi có thể hơi khác `helm install` thuần.

---

### Câu 8: Làm sao xem rendered manifests của Helm Application?

    ```bash
    argocd app manifests <app-name>
    # Hoặc local: helm template <release> <chart> --values values.yaml
    ```

---

### Câu 9: OCI Helm registry là gì?

    Lưu Helm charts trong **container registry** (Docker Hub, ECR) thay vì Helm repo. Dùng `oci://` prefix. Ưu điểm: chung infra với images, authentication nhất quán.

---

### Câu 10: Debug "helm template failed" thế nào?

    1. `argocd app get <app>` — đọc error
    2. `kubectl logs deployment/argocd-repo-server -n argocd`
    3. Test local: `helm template <chart> --values values.yaml`
    4. Common: values sai type, chart version incompatible, required values missing

---

## Phần 2: Integration (Câu 11-20)

### Câu 11: `helm list` có thấy apps từ ArgoCD không?

    **Không!** ArgoCD dùng `helm template` → `kubectl apply`, không tạo Helm release object.

---

### Câu 12: Dùng nhiều values files cho 1 chart được không?

    **Có!** Files sau override files trước: `valueFiles: [values.yaml, values-prod.yaml]`.

---

### Câu 13: `helm.passCredentials` dùng khi nào?

    Khi chart có sub-charts từ **private repo** → ArgoCD cần pass credentials để download dependencies.

---

### Câu 14: Pin version chart thế nào?

    Dùng exact version: `targetRevision: 19.6.4`. Tránh `*` hay semver range cho production.

---

### Câu 15: Inline values vs valueFiles — khi nào dùng cái nào?

    **valueFiles** cho per-environment config (nhiều values). **Inline values** cho quick overrides (ít values). Inline có ưu tiên cao hơn.

---

### Câu 16: Helm dependency/sub-charts hoạt động thế nào?

    ArgoCD tự chạy `helm dependency build` trước render. Nếu sub-charts từ private repo → cần `helm.passCredentials: true`.

---

### Câu 17: Deploy Helm chart từ Git repo cấu hình khác gì?

    Dùng `path` thay vì `chart`. ArgoCD tự nhận diện Helm chart khi thấy `Chart.yaml` trong thư mục.

---

### Câu 18: `helm.skipCrds` dùng để làm gì?

    Bỏ qua CRDs khi render. Dùng khi CRDs đã được cài bởi operator khác hoặc quản lý riêng.

---

### Câu 19: Multiple Sources cho Helm hoạt động thế nào?

    Tách **chart** và **values** ở 2 repo khác nhau (ArgoCD 2.6+). Chart từ Helm repo, values từ Git config repo. Dùng `$ref` syntax để reference.

---

### Câu 20: ArgoCD có tự update khi Helm chart có version mới không?

    Phụ thuộc `targetRevision`: pinned (`19.6.4`) → không; semver (`19.*`) → có; latest (`*`) → có. Best practice: pin + update thủ công qua Git.

---

## Phần 3: Advanced (Câu 21-30)

### Câu 21: Bitnami charts là gì?

    Bitnami cung cấp Helm charts cho apps phổ biến (Redis, PostgreSQL, WordPress). Maintained bởi VMware, repo: `https://charts.bitnami.com/bitnami`.

---

### Câu 22: Chart version vs App version?

    Chart version (Chart.yaml `version`) = cấu hình chart thay đổi. App version (`appVersion`) = phiên bản ứng dụng (vd: Redis 7.2.4). ArgoCD `targetRevision` dùng chart version.

---

### Câu 23: Deploy cùng chart cho dev/prod thế nào?

    Tạo **2 Applications** cùng chart, khác values. Dev: `standalone, 0 replicas`, Prod: `replication, 3 replicas`. Hoặc dùng `valueFiles` khác nhau.

---

### Câu 24: `helm.fileParameters` dùng để làm gì?

    Set Helm values từ **nội dung file** (certificates, config files). Tương đương `helm install --set-file`.

---

### Câu 25: ArgoCD cache Helm chart không?

    **Có!** Cache trong Redis, tránh re-download mỗi reconcile cycle.

---

### Câu 26: Tại sao ArgoCD dùng `helm template` thay vì `helm install`?

    1. GitOps — ArgoCD quản lý state, không cần Helm release tracking
    2. Consistency — Mọi tool đều output plain YAML
    3. Simplicity — Không cần release secrets
    4. ArgoCD cần plain YAML để diff

---

### Câu 27: Fix "values file not found"?

    Path trong `valueFiles` tương đối so với **chart root**, không phải repo root. Kiểm tra lại path. Nếu values ở folder khác → dùng Multiple Sources.

---

### Câu 28: "Synced" nhưng app lỗi — tại sao?

    Synced ≠ Healthy. "Synced" = manifests đã apply. App có thể Degraded nếu pods crash. Luôn check cả Sync Status **và** Health Status.

---

### Câu 29: Dùng Helm post-renderer với ArgoCD?

    **Không trực tiếp.** Thay thế: Kustomize wrapping Helm, Config Management Plugin, hoặc CI pipeline render trước.

---

### Câu 30: So sánh `helm install` vs ArgoCD+Helm?

    | | `helm install` | ArgoCD+Helm |
    |---|---|---|
    | Audit trail | Không | Git history |
    | Drift detection | Không | Có |
    | Self-heal | Không | Có |
    | Rollback | `helm rollback` | Git revert |
    | Collaboration | Khó | PR review |

    ArgoCD+Helm = best of both worlds.

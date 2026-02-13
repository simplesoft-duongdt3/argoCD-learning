# ❓ Câu Hỏi Ôn Tập — Ngày 9: Bảo Mật — RBAC & Projects

## Phần 1: AppProject (Câu 1-10)

### Câu 1: AppProject trong ArgoCD dùng để làm gì?
<details><summary>📖 Đáp án</summary>

AppProject cung cấp **isolation** và **access control**. Nó giới hạn: source repos được phép, destination clusters/namespaces, resource types được tạo, và roles/permissions cho users.
</details>

---

### Câu 2: Project `default` có gì đặc biệt?
<details><summary>📖 Đáp án</summary>

Project `default` cho phép **TẤT CẢ**: mọi source repo, mọi destination, mọi resource type. Tiện cho learning nhưng **không an toàn cho production**. Production nên tạo project riêng với giới hạn cụ thể.
</details>

---

### Câu 3: `sourceRepos` trong AppProject giới hạn gì?
<details><summary>📖 Đáp án</summary>

Danh sách Git/Helm repos mà Applications trong project **được phép** reference. Dùng `*` cho phép tất cả. Best practice: chỉ list repos của team:
```yaml
sourceRepos:
  - 'https://github.com/team-a/*.git'
```
</details>

---

### Câu 4: `destinations` trong AppProject hoạt động thế nào?
<details><summary>📖 Đáp án</summary>

Giới hạn clusters + namespaces mà Applications được deploy vào:
```yaml
destinations:
  - server: https://kubernetes.default.svc
    namespace: team-a-*    # Wildcard namespace
```
App trỏ đến namespace không nằm trong whitelist → bị từ chối.
</details>

---

### Câu 5: `clusterResourceWhitelist` vs `namespaceResourceWhitelist` khác nhau thế nào?
<details><summary>📖 Đáp án</summary>

**clusterResourceWhitelist:** Cho phép tạo cluster-scoped resources (ClusterRole, Namespace, CRD). **namespaceResourceWhitelist:** Cho phép tạo namespaced resources (Deployment, Service, ConfigMap). Empty list = không cho phép. `[{group: '*', kind: '*'}]` = cho phép tất cả.
</details>

---

### Câu 6: `clusterResourceBlacklist` dùng khi nào?
<details><summary>📖 Đáp án</summary>

Cấm tạo resource types cụ thể (dùng khi whitelist quá rộng):
```yaml
clusterResourceBlacklist:
  - group: ''
    kind: Namespace    # Cấm tạo Namespace
```
Blacklist override whitelist — nếu resource nằm trong cả 2, nó bị cấm.
</details>

---

### Câu 7: Roles trong AppProject khác RBAC global thế nào?
<details><summary>📖 Đáp án</summary>

**Project Roles:** Chỉ áp dụng cho Applications **trong project đó**. **Global RBAC (argocd-rbac-cm):** Áp dụng cho toàn bộ ArgoCD. Project roles = fine-grained, RBAC global = coarse-grained.
</details>

---

### Câu 8: Sync Windows trong AppProject dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Giới hạn thời gian sync (maintenance window). Dùng cron schedule:
```yaml
syncWindows:
  - kind: allow
    schedule: "0 9-17 * * 1-5"  # Chỉ sync Mon-Fri 9AM-5PM
```
Ngoài window → sync bị từ chối. Hữu ích cho production — tránh deploy ngoài giờ làm việc.
</details>

---

### Câu 9: Tạo AppProject bằng CLI thế nào?
<details><summary>📖 Đáp án</summary>

```bash
argocd proj create team-a \
  --description "Project for Team A" \
  --src https://github.com/team-a/repo.git \
  --dest https://kubernetes.default.svc,team-a-dev \
  --dest https://kubernetes.default.svc,team-a-prod
```
Hoặc dùng YAML manifest: `kubectl apply -f appproject.yaml`.
</details>

---

### Câu 10: Orphaned Resources Monitoring là gì?
<details><summary>📖 Đáp án</summary>

ArgoCD detect resources trên cluster mà **không thuộc Application nào**. Cấu hình trong AppProject:
```yaml
orphanedResources:
  warn: true
```
Cảnh báo khi có resources "lạ" trong managed namespaces → phát hiện manual kubectl apply.
</details>

---

## Phần 2: RBAC (Câu 11-20)

### Câu 11: ArgoCD RBAC dùng format gì?
<details><summary>📖 Đáp án</summary>

**Casbin** policy format:
```
p, <subject>, <resource>, <action>, <project/object>, <allow/deny>
g, <user>, <role>
```
`p` = policy rule. `g` = group/role assignment.
</details>

---

### Câu 12: Có những resource types nào trong RBAC?
<details><summary>📖 Đáp án</summary>

| Resource | Actions |
|----------|---------|
| `applications` | get, create, update, delete, sync, override, action |
| `clusters` | get, create, update, delete |
| `repositories` | get, create, update, delete |
| `projects` | get, create, update, delete |
| `logs` | get |
| `exec` | create |
</details>

---

### Câu 13: `policy.default` trong argocd-rbac-cm là gì?
<details><summary>📖 Đáp án</summary>

Default role cho users **không match** bất kỳ policy rule nào. Thường set: `role:readonly` (xem nhưng không sửa) hoặc `""` (không quyền gì). **Đừng set `role:admin`** — mọi user sẽ có full access.
</details>

---

### Câu 14: Cách tạo local user trong ArgoCD?
<details><summary>📖 Đáp án</summary>

Sửa ConfigMap `argocd-cm`:
```yaml
data:
  accounts.developer: "apiKey, login"
  accounts.developer.enabled: "true"
```
Capabilities: `login` (UI/CLI login), `apiKey` (generate API key).
</details>

---

### Câu 15: Đặt password cho local user thế nào?
<details><summary>📖 Đáp án</summary>

```bash
argocd account update-password \
  --account developer \
  --new-password Dev@12345 \
  --current-password <ADMIN_PASSWORD>
```
Phải login bằng admin trước. Hoặc user tự đổi qua UI.
</details>

---

### Câu 16: Wildcard `*` trong RBAC policy nghĩa gì?
<details><summary>📖 Đáp án</summary>

Match **tất cả**:
- `p, role:admin, *, *, */*, allow` — mọi resource, mọi action, mọi project
- `p, role:dev, applications, get, team-a/*, allow` — get mọi app trong project team-a
- `p, role:dev, applications, *, team-a/myapp, allow` — mọi action trên app cụ thể
</details>

---

### Câu 17: Làm sao test RBAC policy trước khi apply?
<details><summary>📖 Đáp án</summary>

```bash
argocd admin settings rbac can <role> <action> <resource> '<project/object>' \
  --policy-file policy.csv
```
Ví dụ: `argocd admin settings rbac can role:developer sync applications 'team-a/*'`
</details>

---

### Câu 18: SSO (Single Sign-On) trong ArgoCD hoạt động thế nào?
<details><summary>📖 Đáp án</summary>

ArgoCD hỗ trợ SSO qua **Dex** (built-in) hoặc **OIDC trực tiếp**. Flow: User → ArgoCD → Dex/OIDC → Identity Provider (Google, Okta) → Token → ArgoCD map groups → RBAC roles.
</details>

---

### Câu 19: `scopes` trong OIDC config dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Xác định thông tin nào ArgoCD request từ Identity Provider:
- `openid` — User identity
- `profile` — Tên, avatar
- `email` — Email
- `groups` — Group membership (quan trọng nhất — để map vào RBAC roles)
</details>

---

### Câu 20: Map OIDC groups → ArgoCD roles thế nào?
<details><summary>📖 Đáp án</summary>

Trong `argocd-rbac-cm`:
```
g, my-github-org:team-a, role:developer
g, my-github-org:devops, role:admin
```
Users trong GitHub team `team-a` → có role `developer`. Users trong team `devops` → `admin`.
</details>

---

## Phần 3: Advanced Security (Câu 21-30)

### Câu 21: Dex vs OIDC trực tiếp — khi nào dùng cái nào?
<details><summary>📖 Đáp án</summary>

**Dex:** Khi Identity Provider không hỗ trợ OIDC trực tiếp (LDAP, SAML), hoặc muốn abstract nhiều providers. **OIDC trực tiếp:** Khi provider hỗ trợ OIDC (Okta, Auth0, Google) — đơn giản hơn, ít components.
</details>

---

### Câu 22: Có nên disable admin account trên production?
<details><summary>📖 Đáp án</summary>

**Có!** Sau khi SSO hoạt động:
```yaml
# argocd-cm
data:
  admin.enabled: "false"
```
Giảm attack surface. Giữ backup admin user (local account riêng) cho emergency.
</details>

---

### Câu 23: API Key (token) dùng khi nào?
<details><summary>📖 Đáp án</summary>

Cho **CI/CD automation** — scripts cần gọi ArgoCD API mà không cần interactive login:
```bash
argocd account generate-token --account ci-user
```
Token không hết hạn (trừ khi set). Best practice: rotate định kỳ.
</details>

---

### Câu 24: `exec` resource trong RBAC dùng cho gì?
<details><summary>📖 Đáp án</summary>

Cho phép `argocd app exec <app> -- <command>` — chạy command trong pod. **Rất nguy hiểm!** Chỉ cấp cho admin:
```
p, role:admin, exec, create, */*, allow
```
</details>

---

### Câu 25: Audit logs trong ArgoCD ở đâu?
<details><summary>📖 Đáp án</summary>

ArgoCD API Server logs ghi lại mọi API calls (ai làm gì, khi nào). Xem: `kubectl logs deployment/argocd-server -n argocd`. Integrate với ELK/Loki để lưu trữ lâu dài.
</details>

---

### Câu 26: Network Policy nên set cho ArgoCD namespace thế nào?
<details><summary>📖 Đáp án</summary>

1. Cho phép ArgoCD → K8s API server (egress)
2. Cho phép ArgoCD → Git repos (egress)
3. Cho phép Users → ArgoCD UI/API (ingress, port 443)
4. Block tất cả traffic khác
</details>

---

### Câu 27: Secrets management — ArgoCD handle thế nào?
<details><summary>📖 Đáp án</summary>

ArgoCD **không** có built-in secrets management. Best practices:
1. **Sealed Secrets** — Encrypt secrets, commit encrypted version
2. **External Secrets Operator** — Sync từ AWS KMS, Vault, etc.
3. **ArgoCD Vault Plugin** — Inject secrets at render time
4. **SOPS** — Encrypt YAML files in Git
</details>

---

### Câu 28: TLS/SSL cho ArgoCD server nên cấu hình thế nào?
<details><summary>📖 Đáp án</summary>

1. **Self-signed** (mặc định): OK cho dev
2. **cert-manager**: Auto-generate Let's Encrypt cert
3. **Manual**: Tạo Secret `argocd-server-tls` chứa cert/key
4. **Ingress termination**: Để Ingress controller handle TLS

Production nên dùng cert-manager hoặc real certificates.
</details>

---

### Câu 29: Least privilege principle áp dụng cho ArgoCD thế nào?
<details><summary>📖 Đáp án</summary>

1. **Project:** Giới hạn repos, namespaces, resource types
2. **RBAC:** Chỉ cấp quyền cần thiết (developer chỉ get, không sync)
3. **Cluster SA:** Namespace-scoped thay vì cluster-admin
4. **Network:** Giới hạn egress/ingress
5. **UI access:** SSO + MFA bắt buộc
</details>

---

### Câu 30: Checklist bảo mật ArgoCD production?
<details><summary>📖 Đáp án</summary>

1. ✅ Tạo AppProject riêng (không dùng `default`)
2. ✅ Configure RBAC strict (policy.default = readonly hoặc "")
3. ✅ Enable SSO + disable admin account
4. ✅ TLS certificates cho ArgoCD server
5. ✅ Network Policies cho argocd namespace
6. ✅ Sealed Secrets hoặc External Secrets
7. ✅ Audit logging enable
8. ✅ Regular credential rotation
9. ✅ Namespace-scoped installation (nếu multi-tenant)
10. ✅ Sync Windows cho production projects
</details>

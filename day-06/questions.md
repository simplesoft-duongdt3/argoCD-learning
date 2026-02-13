# ❓ Câu Hỏi Ôn Tập — Ngày 6: Quản Lý Nhiều Cluster

## Phần 1: Multi-Cluster Concepts (Câu 1-10)

### Câu 1: Hub-and-Spoke model trong ArgoCD là gì?
<details><summary>📖 Đáp án</summary>

**Hub** = cluster trung tâm chạy ArgoCD. **Spoke** = clusters được quản lý bởi Hub. ArgoCD trên Hub deploy apps lên tất cả Spoke clusters. Một ArgoCD quản lý nhiều clusters.
</details>

---

### Câu 2: Làm sao thêm cluster vào ArgoCD?
<details><summary>📖 Đáp án</summary>

```bash
argocd cluster add <CONTEXT_NAME>
```
ArgoCD tạo ServiceAccount trên cluster đích + ClusterRoleBinding. Cluster info lưu trong K8s Secret namespace `argocd`.
</details>

---

### Câu 3: ArgoCD lưu cluster credentials ở đâu?
<details><summary>📖 Đáp án</summary>

Trong **Kubernetes Secret** namespace `argocd`, label `argocd.argoproj.io/secret-type: cluster`. Mỗi cluster = 1 Secret chứa server URL, config (bearer token hoặc kubeconfig).
</details>

---

### Câu 4: `argocd cluster list` hiển thị gì?
<details><summary>📖 Đáp án</summary>

Danh sách clusters đã đăng ký: Server URL, Name, Version, Status (Successful/Failed). In-cluster (`https://kubernetes.default.svc`) luôn có sẵn.
</details>

---

### Câu 5: Deploy app lên external cluster cần thay đổi gì trong Application?
<details><summary>📖 Đáp án</summary>

Thay `destination.server` bằng URL cluster đích (hoặc dùng `destination.name`):
```yaml
destination:
  server: https://external-cluster-api:6443   # URL cluster đích
  # hoặc: name: spoke-cluster
  namespace: my-app
```
</details>

---

### Câu 6: `destination.server` vs `destination.name` khác nhau thế nào?
<details><summary>📖 Đáp án</summary>

`server` = URL API server. `name` = tên cluster trong ArgoCD (friendly name). Dùng `name` dễ đọc hơn, nhưng `server` chính xác hơn. Không dùng cả hai cùng lúc.
</details>

---

### Câu 7: Tại sao ArgoCD cần ServiceAccount trên cluster đích?
<details><summary>📖 Đáp án</summary>

ArgoCD cần quyền để **query state** (get pods, services) và **apply resources** (create/update/delete) trên cluster đích. ServiceAccount + ClusterRoleBinding cung cấp quyền này.
</details>

---

### Câu 8: Có giới hạn số clusters ArgoCD quản lý không?
<details><summary>📖 Đáp án</summary>

Không có giới hạn cứng. Tuy nhiên, nhiều clusters → tăng load trên Application Controller. Production lớn (50+ clusters) nên dùng **controller sharding** để phân tải.
</details>

---

### Câu 9: Controller sharding là gì?
<details><summary>📖 Đáp án</summary>

Phân chia clusters cho nhiều controller instances. Mỗi instance chỉ quản lý subset clusters. Giảm load, tăng scalability. Cấu hình qua `--application-controller-args` hoặc env vars.
</details>

---

### Câu 10: Network requirements cho multi-cluster?
<details><summary>📖 Đáp án</summary>

Hub ArgoCD phải kết nối được đến **API server** của mọi Spoke cluster (port 6443 thường). Ngược lại không cần. VPN/peering/direct connect cần được setup trước.
</details>

---

## Phần 2: Setup & Operations (Câu 11-20)

### Câu 11: Tạo multi-cluster với Minikube thế nào?
<details><summary>📖 Đáp án</summary>

```bash
minikube start --profile hub -p hub --cpus=4 --memory=8192
minikube start --profile spoke -p spoke --cpus=2 --memory=4096
```
Mỗi profile tạo cluster riêng. Switch context: `kubectl config use-context hub`.
</details>

---

### Câu 12: `argocd cluster add` thực sự làm gì?
<details><summary>📖 Đáp án</summary>

1. Tạo ServiceAccount `argocd-manager` trên cluster đích
2. Tạo ClusterRoleBinding cho SA → `cluster-admin`
3. Lấy token của SA
4. Lưu cluster info + token vào Secret trên Hub
</details>

---

### Câu 13: Xóa cluster khỏi ArgoCD thế nào?
<details><summary>📖 Đáp án</summary>

```bash
argocd cluster rm <SERVER_URL>
```
Xóa Secret connection. **Không** xóa ServiceAccount trên cluster đích. Nên cleanup SA thủ công.
</details>

---

### Câu 14: Cluster health check trong ArgoCD?
<details><summary>📖 Đáp án</summary>

ArgoCD định kỳ check connection đến cluster API server. Status: **Successful** (kết nối OK) hoặc **Failed** (timeout, auth error). Xem: `argocd cluster get <URL>`.
</details>

---

### Câu 15: Token hết hạn thì ArgoCD xử lý thế nào?
<details><summary>📖 Đáp án</summary>

Cluster bị **Failed** status, apps không sync được. Fix: `argocd cluster add <context>` lại để refresh credentials. Hoặc rotate token trong Secret thủ công.
</details>

---

### Câu 16: Có thể restrict ArgoCD chỉ deploy vào namespace cụ thể trên cluster đích?
<details><summary>📖 Đáp án</summary>

**Có**, qua AppProject `destinations`:
```yaml
destinations:
  - server: https://spoke-cluster:6443
    namespace: allowed-ns-1
  - server: https://spoke-cluster:6443
    namespace: allowed-ns-2
```
Hoặc dùng namespace-scoped ArgoCD installation (giới hạn quyền của SA).
</details>

---

### Câu 17: Namespace-scoped vs Cluster-scoped ArgoCD installation?
<details><summary>📖 Đáp án</summary>

**Cluster-scoped** (mặc định): ArgoCD quản lý mọi namespace. **Namespace-scoped**: ArgoCD chỉ quản lý namespaces được chỉ định. Dùng cho multi-tenant clusters khi mỗi team có ArgoCD riêng.
</details>

---

### Câu 18: Làm sao test connectivity đến external cluster?
<details><summary>📖 Đáp án</summary>

```bash
# Check cluster status
argocd cluster get <SERVER_URL>
# Check kubectl
kubectl --context <context> get nodes
# Check network
curl -sk <SERVER_URL>/healthz
```
</details>

---

### Câu 19: Multi-ArgoCD vs Single ArgoCD cho multi-cluster?
<details><summary>📖 Đáp án</summary>

**Single ArgoCD (Hub-Spoke):** Đơn giản, centralized management. **Multi-ArgoCD:** Mỗi cluster có ArgoCD riêng, independent. Chọn Single cho nhỏ/trung bình, Multi cho enterprise (compliance, isolation).
</details>

---

### Câu 20: Label cluster trong ArgoCD dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Labels cho phép ApplicationSet **filter clusters** bằng Cluster Generator:
```yaml
# Khi add cluster
argocd cluster add <ctx> --label env=prod --label region=us-east
```
ApplicationSet filter: `matchLabels: {env: prod}` → chỉ deploy vào prod clusters.
</details>

---

## Phần 3: Advanced Multi-Cluster (Câu 21-30)

### Câu 21: Service mesh cần thiết cho multi-cluster ArgoCD không?
<details><summary>📖 Đáp án</summary>

**Không.** ArgoCD chỉ cần kết nối đến API server. Service mesh (Istio, Linkerd) dùng cho cross-cluster **service communication**, không liên quan đến ArgoCD deployment.
</details>

---

### Câu 22: ArgoCD có thể deploy CRDs lên external cluster không?
<details><summary>📖 Đáp án</summary>

**Có**, nếu ServiceAccount có quyền `cluster-admin`. Nhưng best practice: quản lý CRDs riêng (operator hoặc Helm) vì CRDs là cluster-scoped, ảnh hưởng toàn cluster.
</details>

---

### Câu 23: Failover khi Hub cluster down?
<details><summary>📖 Đáp án</summary>

Spoke clusters vẫn chạy bình thường (apps đã deploy không bị ảnh hưởng). Nhưng không thể sync/update apps. Solution: ArgoCD HA mode, backup/restore, hoặc secondary Hub.
</details>

---

### Câu 24: EKS/GKE/AKS clusters thêm vào ArgoCD khác gì?
<details><summary>📖 Đáp án</summary>

Quy trình giống nhau: kubeconfig context → `argocd cluster add`. Nhưng mỗi cloud có auth khác: EKS (IAM + aws-iam-authenticator), GKE (gcloud), AKS (Azure AD). Cần configure kubeconfig đúng.
</details>

---

### Câu 25: Có thể quản lý clusters ở regions khác nhau không?
<details><summary>📖 Đáp án</summary>

**Có.** ArgoCD chỉ cần network connectivity đến API server. Cross-region, cross-cloud đều được. Latency cao hơn nhưng ArgoCD xử lý async nên ít ảnh hưởng.
</details>

---

### Câu 26: `--system-namespace` khi add cluster dùng để làm gì?
<details><summary>📖 Đáp án</summary>

Chỉ định namespace cho ServiceAccount ArgoCD trên cluster đích. Mặc định: `kube-system`. Có thể đổi để tránh ảnh hưởng system namespace.
</details>

---

### Câu 27: Rotate cluster credentials thế nào?
<details><summary>📖 Đáp án</summary>

1. `argocd cluster rm <URL>` — xóa cluster cũ
2. `argocd cluster add <context>` — thêm lại với token mới
Hoặc update Secret trực tiếp: `kubectl edit secret <cluster-secret> -n argocd`.
</details>

---

### Câu 28: Monitoring multi-cluster ArgoCD?
<details><summary>📖 Đáp án</summary>

ArgoCD expose Prometheus metrics. Key metrics: `argocd_cluster_api_resource_objects` (resources per cluster), `argocd_cluster_info` (cluster connection), `argocd_app_info` (app health per cluster).
</details>

---

### Câu 29: GitOps Bridge pattern là gì?
<details><summary>📖 Đáp án</summary>

Pattern khi Terraform/Pulumi tạo cluster → tự thêm vào ArgoCD và bootstrap ArgoCD config. Infrastructure provisioning (Terraform) + GitOps (ArgoCD) kết hợp seamlessly.
</details>

---

### Câu 30: Best practices cho multi-cluster ArgoCD production?
<details><summary>📖 Đáp án</summary>

1. **HA mode** cho Hub ArgoCD
2. **AppProject per team** — phân quyền
3. **Label clusters** — dễ filter cho ApplicationSet
4. **Least privilege SA** — không dùng cluster-admin nếu không cần
5. **Monitor cluster connectivity** — alert khi connection failed
6. **Rotate credentials** định kỳ
7. **Backup ArgoCD config** — Secret, ConfigMap, Applications
</details>

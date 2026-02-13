#!/bin/bash
set -e

echo "========================================="
echo "🚀 Cài đặt ArgoCD lên Kubernetes Cluster"
echo "========================================="

# Kiểm tra kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl chưa được cài đặt. Vui lòng cài đặt kubectl trước."
    exit 1
fi

# Kiểm tra cluster
echo "📋 Kiểm tra kết nối cluster..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Không thể kết nối tới Kubernetes cluster. Hãy chạy: minikube start"
    exit 1
fi

echo "✅ Cluster đã sẵn sàng!"
echo ""

# Tạo namespace
echo "📦 Tạo namespace 'argocd'..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Cài đặt ArgoCD
echo "⬇️  Cài đặt ArgoCD (stable)..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Chờ pods sẵn sàng
echo "⏳ Chờ các Pod khởi động (timeout: 5 phút)..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo ""
echo "========================================="
echo "✅ ArgoCD đã cài đặt thành công!"
echo "========================================="
echo ""
echo "📋 Danh sách Pod:"
kubectl get pods -n argocd
echo ""
echo "👉 Chạy './scripts/get-admin-password.sh' để lấy mật khẩu admin"
echo "👉 Chạy 'kubectl port-forward svc/argocd-server -n argocd 8080:443 &' để truy cập UI"
echo "👉 Mở trình duyệt: https://localhost:8080"

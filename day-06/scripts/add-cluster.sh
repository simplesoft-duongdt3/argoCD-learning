#!/bin/bash
set -e

echo "========================================="
echo "➕ Add Spoke Cluster vào ArgoCD"
echo "========================================="

# Đảm bảo đang ở Hub cluster
kubectl config use-context hub-cluster

# Login ArgoCD CLI
echo "🔑 Login ArgoCD..."
ADMIN_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Port-forward nếu chưa có
if ! curl -sk https://localhost:8080 > /dev/null 2>&1; then
    echo "📡 Bắt đầu port-forward..."
    kubectl port-forward svc/argocd-server -n argocd 8080:443 &
    sleep 3
fi

argocd login localhost:8080 --username admin --password "$ADMIN_PASS" --insecure

# Add spoke cluster
echo ""
echo "➕ Thêm spoke-cluster..."
argocd cluster add spoke-cluster --name spoke-cluster --yes

echo ""
echo "✅ Spoke cluster đã được thêm!"
echo ""
echo "📋 Danh sách clusters:"
argocd cluster list

#!/bin/bash
set -e

echo "========================================="
echo "🚀 Cài đặt Argo Rollouts"
echo "========================================="

# Tạo namespace
kubectl create namespace argo-rollouts --dry-run=client -o yaml | kubectl apply -f -

# Cài đặt Argo Rollouts
echo "⬇️  Cài đặt Argo Rollouts..."
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml

# Chờ pods sẵn sàng
echo "⏳ Chờ pods khởi động..."
kubectl wait --for=condition=Ready pods --all -n argo-rollouts --timeout=120s

# Cài kubectl plugin
echo ""
echo "📦 Cài đặt kubectl argo rollouts plugin..."
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-darwin-amd64
    chmod +x kubectl-argo-rollouts-darwin-amd64
    sudo mv kubectl-argo-rollouts-darwin-amd64 /usr/local/bin/kubectl-argo-rollouts
else
    # Linux
    curl -LO https://github.com/argoproj/argo-rollouts/releases/latest/download/kubectl-argo-rollouts-linux-amd64
    chmod +x kubectl-argo-rollouts-linux-amd64
    sudo mv kubectl-argo-rollouts-linux-amd64 /usr/local/bin/kubectl-argo-rollouts
fi

echo ""
echo "========================================="
echo "✅ Argo Rollouts đã cài đặt thành công!"
echo "========================================="
kubectl get pods -n argo-rollouts
echo ""
echo "📋 Version: $(kubectl argo rollouts version 2>/dev/null || echo 'plugin cần restart shell')"

#!/bin/bash
set -e

echo "========================================="
echo "🌐 Setup Multi-cluster Environment"
echo "========================================="

# Kiểm tra minikube
if ! command -v minikube &> /dev/null; then
    echo "❌ minikube chưa được cài đặt."
    exit 1
fi

# Tạo Hub cluster
echo ""
echo "1️⃣  Tạo Hub cluster (ArgoCD Server)..."
minikube start --profile hub-cluster --cpus=4 --memory=8192 --driver=docker
echo "✅ Hub cluster đã sẵn sàng"

# Tạo Spoke cluster
echo ""
echo "2️⃣  Tạo Spoke cluster..."
minikube start --profile spoke-cluster --cpus=2 --memory=4096 --driver=docker
echo "✅ Spoke cluster đã sẵn sàng"

# Chuyển về Hub cluster
kubectl config use-context hub-cluster

# Cài ArgoCD trên Hub
echo ""
echo "3️⃣  Cài đặt ArgoCD trên Hub cluster..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Chờ ArgoCD pods khởi động..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s

echo ""
echo "========================================="
echo "✅ Multi-cluster setup hoàn tất!"
echo "========================================="
echo ""
echo "📋 Clusters:"
kubectl config get-contexts
echo ""
echo "👉 Chạy './scripts/add-cluster.sh' để add spoke cluster vào ArgoCD"

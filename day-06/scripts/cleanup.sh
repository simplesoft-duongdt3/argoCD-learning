#!/bin/bash
set -e

echo "========================================="
echo "🧹 Cleanup Multi-cluster Environment"
echo "========================================="

echo "⚠️  Lệnh này sẽ XÓA cả 2 Minikube clusters (hub-cluster và spoke-cluster)"
read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ Đã hủy."
    exit 0
fi

echo ""
echo "🗑️  Xóa spoke-cluster..."
minikube delete --profile spoke-cluster 2>/dev/null || true

echo "🗑️  Xóa hub-cluster..."
minikube delete --profile hub-cluster 2>/dev/null || true

echo ""
echo "✅ Đã xóa tất cả clusters!"
echo "👉 Chạy 'minikube start' để tạo lại cluster mặc định cho các ngày tiếp theo"

#!/bin/bash
set -e

echo "🔍 Kiểm tra ArgoCD Installation..."
echo ""

PASS=0
FAIL=0

# Check 1: Namespace
echo "1️⃣  Kiểm tra namespace 'argocd'..."
if kubectl get namespace argocd &> /dev/null; then
    echo "   ✅ Namespace 'argocd' tồn tại"
    ((PASS++))
else
    echo "   ❌ Namespace 'argocd' không tồn tại"
    ((FAIL++))
fi

# Check 2: Pods
echo "2️⃣  Kiểm tra các Pod..."
TOTAL_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | wc -l | tr -d ' ')
READY_PODS=$(kubectl get pods -n argocd --no-headers 2>/dev/null | grep "Running" | wc -l | tr -d ' ')
if [ "$TOTAL_PODS" -gt 0 ] && [ "$TOTAL_PODS" -eq "$READY_PODS" ]; then
    echo "   ✅ Tất cả $TOTAL_PODS Pod đang Running"
    ((PASS++))
else
    echo "   ❌ $READY_PODS/$TOTAL_PODS Pod đang Running"
    ((FAIL++))
fi

# Check 3: Services
echo "3️⃣  Kiểm tra Services..."
if kubectl get svc argocd-server -n argocd &> /dev/null; then
    echo "   ✅ Service 'argocd-server' tồn tại"
    ((PASS++))
else
    echo "   ❌ Service 'argocd-server' không tồn tại"
    ((FAIL++))
fi

# Check 4: Admin secret
echo "4️⃣  Kiểm tra Admin Secret..."
if kubectl get secret argocd-initial-admin-secret -n argocd &> /dev/null; then
    echo "   ✅ Admin secret tồn tại"
    ((PASS++))
else
    echo "   ❌ Admin secret không tồn tại (có thể đã bị xóa)"
    ((FAIL++))
fi

# Check 5: ArgoCD CLI
echo "5️⃣  Kiểm tra ArgoCD CLI..."
if command -v argocd &> /dev/null; then
    VERSION=$(argocd version --client --short 2>/dev/null || echo "unknown")
    echo "   ✅ ArgoCD CLI: $VERSION"
    ((PASS++))
else
    echo "   ⚠️  ArgoCD CLI chưa cài (không bắt buộc nhưng khuyến nghị)"
fi

echo ""
echo "========================================="
echo "📊 Kết quả: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then
    echo "🎉 ArgoCD đã sẵn sàng sử dụng!"
else
    echo "⚠️  Có lỗi cần kiểm tra lại."
fi
echo "========================================="

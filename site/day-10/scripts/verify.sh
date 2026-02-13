#!/bin/bash
set -e

echo "🔍 Kiểm tra Argo Rollouts Installation..."
echo ""

PASS=0
FAIL=0

# Check 1: Namespace
echo "1️⃣  Kiểm tra namespace 'argo-rollouts'..."
if kubectl get namespace argo-rollouts &> /dev/null; then
    echo "   ✅ Namespace tồn tại"
    ((PASS++))
else
    echo "   ❌ Namespace không tồn tại"
    ((FAIL++))
fi

# Check 2: Controller Pod
echo "2️⃣  Kiểm tra controller pod..."
READY=$(kubectl get pods -n argo-rollouts --no-headers 2>/dev/null | grep "Running" | wc -l | tr -d ' ')
if [ "$READY" -gt 0 ]; then
    echo "   ✅ Controller đang Running"
    ((PASS++))
else
    echo "   ❌ Controller không Running"
    ((FAIL++))
fi

# Check 3: CRD
echo "3️⃣  Kiểm tra Rollout CRD..."
if kubectl get crd rollouts.argoproj.io &> /dev/null; then
    echo "   ✅ Rollout CRD đã cài"
    ((PASS++))
else
    echo "   ❌ Rollout CRD chưa cài"
    ((FAIL++))
fi

# Check 4: kubectl plugin
echo "4️⃣  Kiểm tra kubectl plugin..."
if kubectl argo rollouts version &> /dev/null; then
    echo "   ✅ kubectl-argo-rollouts plugin OK"
    ((PASS++))
else
    echo "   ⚠️  kubectl-argo-rollouts plugin chưa cài"
fi

echo ""
echo "========================================="
echo "📊 Kết quả: $PASS passed, $FAIL failed"
if [ "$FAIL" -eq 0 ]; then
    echo "🎉 Argo Rollouts đã sẵn sàng!"
else
    echo "⚠️  Có lỗi cần kiểm tra lại."
fi
echo "========================================="

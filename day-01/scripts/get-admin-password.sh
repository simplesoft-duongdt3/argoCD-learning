#!/bin/bash
set -e

echo "🔑 Lấy mật khẩu Admin ArgoCD..."
echo ""

PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "========================================="
echo "👤 Username: admin"
echo "🔑 Password: $PASSWORD"
echo "========================================="
echo ""
echo "🌐 Truy cập UI: https://localhost:8080"
echo "💻 Login CLI:   argocd login localhost:8080 --username admin --password '$PASSWORD' --insecure"

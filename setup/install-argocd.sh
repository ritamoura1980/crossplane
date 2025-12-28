#!/bin/bash

# Instalar ArgoCD
echo "Instalando ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Aguardando ArgoCD ficar pronto..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "ArgoCD instalado com sucesso!"
echo ""
echo "Para acessar o ArgoCD:"
echo "1. Obter a senha inicial:"
echo "   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
echo ""
echo "2. Port-forward para acessar a UI:"
echo "   kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo ""
echo "3. Acessar: https://localhost:8080"
echo "   Usuário: admin"

#!/bin/bash

# Instalar Crossplane via Helm
echo "Instalando Crossplane..."
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
  --namespace crossplane-system \
  --create-namespace \
  crossplane-stable/crossplane

echo "Aguardando Crossplane ficar pronto..."
kubectl wait --for=condition=ready pod -l app=crossplane -n crossplane-system --timeout=300s

echo "Crossplane instalado com sucesso!"

# Crossplane + Kustomize Project

Projeto de gerenciamento de infraestrutura Kubernetes usando Crossplane e Kustomize.

## 📁 Estrutura

```
crossplane/
├── argocd/                     # Configurações ArgoCD
├── crossplane-configs/         # Configurações Crossplane
├── examples/                   # Exemplos de recursos
├── kustomize/                  # Gerenciamento com Kustomize
│   ├── base/                  # Recursos base compartilhados
│   └── overlays/              # Customizações por ambiente
│       ├── dev/
│       ├── staging/
│       └── production/
└── setup/                      # Scripts de instalação
```

## 🚀 Quick Start com Kustomize

### 1. Criar cluster local (Kind)

```bash
kind create cluster --name crossplane-test
```

### 2. Configurar secrets

```bash
# Para cada ambiente, copie o arquivo de exemplo
cp kustomize/overlays/dev/secrets.yaml.example kustomize/overlays/dev/secrets.yaml
cp kustomize/overlays/staging/secrets.yaml.example kustomize/overlays/staging/secrets.yaml
cp kustomize/overlays/production/secrets.yaml.example kustomize/overlays/production/secrets.yaml

# Edite os arquivos secrets.yaml com suas credenciais reais
```

### 3. Deploy dos ambientes

```bash
# Dev
kubectl apply -k kustomize/overlays/dev

# Staging
kubectl apply -k kustomize/overlays/staging

# Production
kubectl apply -k kustomize/overlays/production
```

### 4. Verificar recursos

```bash
kubectl get all -n dev
kubectl get all -n staging
kubectl get all -n production
```

## 🔍 Visualizar configurações

```bash
# Ver YAMLs gerados sem aplicar
kubectl kustomize kustomize/overlays/staging
```

## 🔐 Segurança

⚠️ **IMPORTANTE**: Nunca commite secrets reais no Git!

- Arquivos `secrets.yaml` estão no `.gitignore`
- Use `secrets.yaml.example` como template
- Para produção, considere ferramentas como:
  - [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
  - [External Secrets Operator](https://external-secrets.io/)
  - [HashiCorp Vault](https://www.vaultproject.io/)

## 📊 Diferenças entre ambientes

| Ambiente   | Namespace  | Réplicas | Log Level | Resources |
|------------|------------|----------|-----------|-----------|
| Dev        | dev        | 1        | trace     | ❌        |
| Staging    | staging    | 2        | debug     | ❌        |
| Production | production | 3        | info      | ✅        |

## 🔧 Comandos úteis

```bash
# Port-forward para testar
kubectl port-forward -n staging svc/nginx-demo 8080:80

# Ver logs
kubectl logs -n staging deployment/nginx-demo

# Deletar recursos
kubectl delete -k kustomize/overlays/staging

# Deletar cluster
kind delete cluster --name crossplane-test
```

## 📚 Documentação adicional

- [Kustomize README](kustomize/README.md) - Detalhes sobre estrutura Kustomize
- [ArgoCD](argocd/) - Configurações GitOps
- [Crossplane](crossplane-configs/) - Infraestrutura como código

## 🤝 Contribuindo

1. Nunca commite secrets reais
2. Use conventional commits
3. Teste localmente antes de abrir PR
4. Documente mudanças significativas

## 📝 License

MIT

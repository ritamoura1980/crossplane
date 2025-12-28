# Crossplane + ArgoCD - Projeto Simples

Este projeto demonstra uma integração básica entre Crossplane e ArgoCD para gerenciar infraestrutura como código de forma declarativa.

## 📋 Visão Geral

O projeto cria:
- **Provider Kubernetes**: Para gerenciar recursos do Kubernetes via Crossplane
- **Composition**: Define como criar namespaces de forma padronizada
- **Claims**: Exemplos de uso da composition
- **ArgoCD Applications**: Gerencia automaticamente os recursos do Crossplane

## 🏗️ Estrutura do Projeto

```
crossplane/
├── crossplane/              # Configurações do Crossplane
│   ├── provider.yaml        # Provider Kubernetes
│   ├── provider-config.yaml # Configuração do provider
│   ├── xrd-namespace.yaml   # Definição de recurso composto
│   └── composition-namespace.yaml  # Composition para namespaces
├── examples/                # Exemplos de uso
│   └── dev-namespace.yaml   # Claim de namespace de desenvolvimento
├── argocd/                  # Configurações do ArgoCD
│   ├── application-crossplane-config.yaml
│   └── application-examples.yaml
├── setup/                   # Scripts de instalação
│   ├── install-crossplane.sh
│   └── install-argocd.sh
└── README.md
```

## 🚀 Começando

### Pré-requisitos

- Kubernetes cluster (minikube, kind, k3s, etc.)
- kubectl configurado
- Helm 3
- Git

### Passo 1: Instalar Crossplane

```bash
bash setup/install-crossplane.sh
```

### Passo 2: Instalar ArgoCD

```bash
bash setup/install-argocd.sh
```

### Passo 3: Configurar Provider do Crossplane

Aplique as configurações do Crossplane:

```bash
kubectl apply -f crossplane/provider.yaml

# Aguarde o provider estar pronto
kubectl wait --for=condition=healthy provider/provider-kubernetes --timeout=300s

# Configure o provider
kubectl apply -f crossplane/provider-config.yaml
```

### Passo 4: Criar Composition e XRD

```bash
kubectl apply -f crossplane/xrd-namespace.yaml
kubectl apply -f crossplane/composition-namespace.yaml
```

### Passo 5: Configurar ArgoCD (Opcional)

Se você quiser que o ArgoCD gerencie os recursos automaticamente:

1. **Fork este repositório** e atualize os `repoURL` nos arquivos em `argocd/`

2. Aplicar as Applications do ArgoCD:

```bash
kubectl apply -f argocd/application-crossplane-config.yaml
kubectl apply -f argocd/application-examples.yaml
```

## 🎯 Testando

### Criar um Namespace via Claim

```bash
kubectl apply -f examples/dev-namespace.yaml
```

Isso criará automaticamente:
- Uma XNamespace (recurso composto)
- Um namespace chamado "dev" no cluster com as labels especificadas

Verificar:

```bash
kubectl get namespaceclaims
kubectl get xnamespaces
kubectl get namespace dev
```

### Criar seu Próprio Namespace

Crie um novo arquivo YAML:

```yaml
apiVersion: example.crossplane.io/v1alpha1
kind: NamespaceClaim
metadata:
  name: meu-app
  namespace: default
spec:
  namespaceName: producao
  labels:
    environment: production
    team: backend
```

Aplique:

```bash
kubectl apply -f meu-namespace.yaml
```

## 🔍 Acessar ArgoCD UI

1. Obter a senha do admin:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

2. Port-forward:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

3. Acessar: https://localhost:8080
   - **Usuário**: admin
   - **Senha**: (obtida no passo 1)

## 📚 Conceitos

### Crossplane

- **Provider**: Plugin que permite gerenciar recursos de uma plataforma (Kubernetes, AWS, Azure, etc.)
- **XRD (CompositeResourceDefinition)**: Define um novo tipo de recurso customizado
- **Composition**: Define COMO criar os recursos reais a partir de um XRD
- **Claim**: Instância que solicita um recurso composto

### ArgoCD

- **Application**: Define o que deve ser sincronizado do Git para o Kubernetes
- **Sync Policy**: Como e quando sincronizar (automático, manual, etc.)

## 🎓 Próximos Passos

1. **Adicionar mais providers**: AWS, Azure, GCP
2. **Criar compositions mais complexas**: Banco de dados, redes, etc.
3. **Implementar RBAC**: Controlar quem pode criar Claims
4. **Adicionar validações**: Webhooks para validar inputs
5. **Multi-cluster**: Gerenciar recursos em múltiplos clusters

## 📖 Recursos Úteis

- [Documentação Crossplane](https://docs.crossplane.io/)
- [Documentação ArgoCD](https://argo-cd.readthedocs.io/)
- [Crossplane Community](https://github.com/crossplane/crossplane)
- [ArgoCD Examples](https://github.com/argoproj/argocd-example-apps)

## 🤝 Contribuindo

Sinta-se livre para abrir issues ou pull requests com melhorias!

## 📝 Licença

MIT

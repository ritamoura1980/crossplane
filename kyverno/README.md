# Kyverno Policies

Políticas de validação, mutação e geração para o cluster Kubernetes.

## Políticas Implementadas

### 1. require-resources.yaml
**Tipo**: Validação  
**Ação**: Enforce  
**Descrição**: Garante que todos os Deployments tenham resources (requests/limits) definidos.

**Exemplo de erro**:
```
CPU e Memory limits são obrigatórios para todos os containers
```

### 2. block-placeholder-secrets.yaml
**Tipo**: Validação  
**Ação**: Enforce  
**Descrição**: Bloqueia Secrets com valores "CHANGE-ME" ou vazios.

**Exemplo de erro**:
```
Secrets não podem conter valores CHANGE-ME ou estar vazios
```

### 3. require-image-tag.yaml
**Tipo**: Validação  
**Ação**: Enforce  
**Descrição**: Exige que imagens tenham tags específicas (não :latest ou :alpine).

**Exemplo de erro**:
```
Imagem deve ter tag específica e versionada (ex: nginx:1.21.0, não nginx:alpine ou nginx:latest)
```

### 4. add-environment-labels.yaml
**Tipo**: Mutação  
**Ação**: Automática  
**Descrição**: Adiciona labels de ambiente automaticamente baseado no namespace.

**Labels adicionadas**:
- `environment: dev|staging|production`
- `managed-by: kyverno`

### 5. require-app-env.yaml
**Tipo**: Validação  
**Ação**: Enforce  
**Descrição**: ConfigMaps chamados "app-config" devem ter APP_ENV.

### 6. generate-network-policy.yaml
**Tipo**: Geração  
**Ação**: Automática  
**Descrição**: Cria NetworkPolicies automaticamente para namespaces dev/staging/production.

**Políticas criadas**:
- `default-deny-all`: Nega todo tráfego por padrão
- `allow-same-namespace`: Permite tráfego dentro do mesmo namespace

## Instalação

```bash
# Instalar Kyverno
kubectl create -f https://github.com/kyverno/kyverno/releases/download/v1.11.0/install.yaml

# Aplicar políticas
kubectl apply -k kyverno/

# Via ArgoCD
kubectl apply -f argocd/kyverno-policies-app.yaml
```

## Testando as Políticas

### Teste 1: Deployment sem resources (deve falhar)
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-no-resources
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: nginx
        image: nginx:1.25.3
EOF
```

### Teste 2: Secret com CHANGE-ME (deve falhar)
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: test-secret
  namespace: dev
type: Opaque
stringData:
  password: "CHANGE-ME"
EOF
```

### Teste 3: Imagem sem tag específica (deve falhar)
```bash
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-latest
  namespace: dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
EOF
```

## Verificando Políticas

```bash
# Listar todas as políticas
kubectl get clusterpolicy

# Ver detalhes de uma política
kubectl describe clusterpolicy require-resources

# Ver violações de políticas
kubectl get policyreport -A
```

## Modo Audit vs Enforce

Para testar sem bloquear recursos, mude `validationFailureAction` para `Audit`:

```yaml
spec:
  validationFailureAction: Audit  # Apenas loga, não bloqueia
```

Para produção, use `Enforce`:

```yaml
spec:
  validationFailureAction: Enforce  # Bloqueia recursos inválidos
```

## ⚠️ Nota Importante

As políticas de validação só são aplicadas em recursos NOVOS ou ATUALIZADOS. Recursos existentes não são afetados automaticamente.

Para aplicar em recursos existentes, você precisa:
1. Recriar os recursos
2. Ou aguardar que o ArgoCD sincronize novamente

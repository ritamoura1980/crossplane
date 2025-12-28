# 🧪 GUIA DE TESTES - Crossplane + ArgoCD

## ✅ Testes Realizados com Sucesso:

### 1. Crossplane - Criação de Namespaces
- ✅ Namespace "dev" criado via NamespaceClaim
- ✅ Namespace "producao" criado via NamespaceClaim
- ✅ Labels aplicadas automaticamente
- ✅ Provider Kubernetes funcionando
- ✅ Composition executando patches corretamente

### 2. Aplicação Completa - Staging
- ✅ Namespace staging criado
- ✅ Deployment nginx-demo com 2 réplicas
- ✅ Service ClusterIP expondo port 80
- ✅ ConfigMap com variáveis de ambiente
- ✅ Secret com credenciais
- ✅ HTTP request funcionando (nginx respondendo)

### 3. ArgoCD
- ✅ 4 Applications criadas e sincronizadas
- ✅ UI acessível em https://localhost:8080
- ✅ GitOps funcionando

---

## 🔬 Comandos para Testar Mais:

### Ver Tudo que Foi Criado:
```powershell
# Status geral
kubectl get namespaces,deployments,services -A | Select-String "dev|staging|producao"

# Crossplane
kubectl get providers,functions,compositions,namespaceclaims

# ArgoCD Applications
kubectl get applications -n argocd
```

### Testar Criar Novo Namespace:
```powershell
# Criar arquivo
@"
apiVersion: example.crossplane.io/v1alpha1
kind: NamespaceClaim
metadata:
  name: qa-environment
  namespace: default
spec:
  namespaceName: qa
  labels:
    environment: qa
    team: quality
"@ | Out-File -Encoding utf8 examples/qa-namespace.yaml

# Aplicar
kubectl apply -f examples/qa-namespace.yaml

# Verificar
kubectl get namespaceclaim qa-environment
kubectl get namespace qa
```

### Escalar Nginx no Staging:
```powershell
# Aumentar para 5 réplicas
kubectl scale deployment nginx-demo -n staging --replicas=5

# Ver pods
kubectl get pods -n staging -w
```

### Testar Conectividade:
```powershell
# Criar pod temporário para testes
kubectl run test-pod --image=curlimages/curl:latest --rm -i --restart=Never -n staging -- sh

# Dentro do pod, testar:
curl http://nginx-demo
curl http://nginx-demo.staging.svc.cluster.local
```

### Ver Logs:
```powershell
# Logs do Crossplane
kubectl logs -n crossplane-system -l app=crossplane --tail=50

# Logs do Provider
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-kubernetes --tail=50

# Logs do Nginx
kubectl logs -n staging -l app=nginx-demo --tail=20
```

### Monitorar em Tempo Real:
```powershell
# Watch Claims
kubectl get namespaceclaims -w

# Watch Pods no staging
kubectl get pods -n staging -w

# Watch Applications do ArgoCD
kubectl get applications -n argocd -w
```

---

## 🎯 Testes Avançados:

### 1. Testar Ciclo de Vida Completo:
```powershell
# Criar
kubectl apply -f examples/producao-namespace.yaml

# Verificar
kubectl get namespaceclaim producao-app -o yaml

# Deletar (vai remover o namespace também!)
kubectl delete namespaceclaim producao-app

# Verificar que o namespace foi removido
kubectl get namespace producao
```

### 2. Testar Atualização de Labels:
```powershell
# Editar a Claim
kubectl edit namespaceclaim dev-environment

# Adicionar/modificar labels em spec.labels
# Salvar e verificar
kubectl get namespace dev -o yaml | Select-String "labels:" -Context 0,5
```

### 3. Testar ArgoCD Sync:
```powershell
# Via CLI (se tiver argocd CLI instalado)
argocd app sync staging-app

# Ou via kubectl
kubectl patch application staging-app -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"HEAD"}}}'
```

### 4. Deploy de Outra App via ArgoCD:
```powershell
# Criar Application para guestbook
@"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/argoproj/argocd-example-apps
    targetRevision: HEAD
    path: guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: producao
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
"@ | Out-File -Encoding utf8 argocd/guestbook-app.yaml

kubectl apply -f argocd/guestbook-app.yaml
```

---

## 🐛 Troubleshooting:

### Claim não fica Ready:
```powershell
# Ver detalhes
kubectl describe namespaceclaim <nome>

# Ver XR criado
kubectl get xnamespaces

# Ver Object gerenciado
kubectl get object -A
```

### Provider com erro:
```powershell
# Ver status
kubectl get providers -o yaml

# Ver logs
kubectl logs -n crossplane-system -l pkg.crossplane.io/provider=provider-kubernetes
```

### ArgoCD Application com problema:
```powershell
# Ver detalhes
kubectl describe application <nome> -n argocd

# Ver eventos
kubectl get events -n argocd --sort-by='.lastTimestamp'
```

---

## 📊 Dashboards e Visualização:

### Ver no ArgoCD UI:
1. Acesse: https://localhost:8080
2. Login: admin / FEO-87caPRNfLHHX
3. Veja todas as Applications e seus status
4. Clique em uma App para ver o grafo de recursos

### Port-forward para Nginx (testar localmente):
```powershell
kubectl port-forward -n staging service/nginx-demo 8081:80
# Acesse: http://localhost:8081
```

---

## 🎓 Exemplos de Uso Real:

### Criar Namespace com ResourceQuota:
Edite a Composition para adicionar ResourceQuota automaticamente!

### Multi-Tenant:
Crie uma XRD para "Tenant" que cria namespace + RBAC + NetworkPolicy + ResourceQuota

### Database via Crossplane:
Instale provider AWS/GCP e crie Compositions para RDS/CloudSQL

---

## 🔗 Recursos:

- **ArgoCD UI**: https://localhost:8080
- **Docs Crossplane**: https://docs.crossplane.io/
- **Docs ArgoCD**: https://argo-cd.readthedocs.io/
- **Examples**: c:\projetos\crossplane\examples\

---

**Todos os testes passaram! Sistema funcionando perfeitamente! 🚀**

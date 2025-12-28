# 🔒 SECURITY - Informações Importantes

## ⚠️ Credenciais e Secrets

Este repositório NÃO contém credenciais hardcoded. Todas as senhas e secrets devem ser obtidas diretamente do cluster.

## 🔑 Como Obter Credenciais

### ArgoCD Admin Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Secrets da Aplicação:
Os Secrets em `examples/staging-complete.yaml` usam valores placeholder (`CHANGE-ME`).
Em produção, substitua por valores reais ou use um Secret Manager (Vault, AWS Secrets Manager, etc).

## 🛡️ Boas Práticas

1. **Nunca commite secrets no Git**
   - Use `.gitignore` para arquivos sensíveis
   - Configure Git hooks para prevenir commits acidentais

2. **Use Secret Managers**
   - Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager
   - Sealed Secrets (Kubernetes)

3. **Rotacione Credenciais Regularmente**
   - Passwords do ArgoCD
   - Tokens de acesso
   - API keys

4. **Use RBAC**
   - Limite acesso aos Secrets
   - Principle of least privilege
   - Audite acessos

## 📋 Checklist de Segurança

- [x] Nenhuma senha hardcoded no repositório
- [x] .gitignore configurado para secrets
- [x] Documentação de como obter credenciais
- [ ] Implementar Sealed Secrets ou External Secrets Operator
- [ ] Configurar rotação automática de credenciais
- [ ] Implementar políticas de segurança (OPA/Gatekeeper)

## 🔄 Se Você Expôs uma Credencial

1. **Revogue imediatamente**
2. **Gere uma nova**
3. **Remova do histórico Git:**
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch caminho/arquivo-com-secret" \
     --prune-empty --tag-name-filter cat -- --all
   ```
4. **Force push (cuidado!):**
   ```bash
   git push origin --force --all
   ```

## 📚 Recursos

- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)
- [GitLeaks](https://github.com/gitleaks/gitleaks) - Detector de secrets

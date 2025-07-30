# Troubleshooting Guide

## 🚨 Common Issues & Solutions

### Infrastructure Deployment Issues

#### Issue: `azd up` fails with quota errors
**Error**: `Quota exceeded for family standardDv3Family`

**Solution**:
```bash
# Try different Azure region
azd env set AZURE_LOCATION westus2

# Or request quota increase in Azure portal
```

#### Issue: OpenAI deployment fails
**Error**: `The subscription doesn't have access to the OpenAI service`

**Solution**:
1. Apply for Azure OpenAI access: https://aka.ms/oai/access
2. Use different region where OpenAI is available
3. Check service availability: https://azure.microsoft.com/global-infrastructure/services/

#### Issue: Bicep compilation errors
**Error**: `The template deployment failed with error: 'InvalidTemplate'`

**Solution**:
```bash
# Validate Bicep template
az bicep build --file infra/main.bicep

# Check for syntax errors
azd provision --preview
```

### Authentication Issues

#### Issue: Azure login fails
**Error**: `AADSTS70002: Error validating credentials`

**Solution**:
```bash
# Clear auth cache
az account clear
azd auth logout

# Re-authenticate
az login
azd auth login

# Use device code if needed
az login --use-device-code
```

#### Issue: Insufficient permissions
**Error**: `Authorization failed`

**Solution**:
- Ensure you have Contributor or Owner role on subscription
- Check resource provider registrations
- Verify Azure policy compliance

### Container Apps Issues

#### Issue: Container app fails to start
**Error**: `Container failed to start`

**Solution**:
```bash
# Check container logs
az containerapp logs show --name <app-name> --resource-group <rg-name>

# Verify image exists in registry
az acr repository show --name <registry-name> --image docgenai-api:latest
```

#### Issue: API returns 500 errors
**Error**: `Internal Server Error`

**Solution**:
1. Check Application Insights for detailed errors
2. Verify environment variables are set correctly
3. Test API locally first
4. Check Azure service connections

### AI/OpenAI Issues

#### Issue: OpenAI API returns 401
**Error**: `Invalid API key`

**Solution**:
```bash
# Verify managed identity has correct roles
az role assignment list --assignee <managed-identity-id>

# Check OpenAI endpoint configuration
az cognitiveservices account show --name <openai-name> --resource-group <rg-name>
```

#### Issue: Embeddings generation fails
**Error**: `Model deployment not found`

**Solution**:
1. Verify embedding model is deployed
2. Check model deployment name matches code
3. Ensure sufficient quota for embeddings

### Frontend Issues

#### Issue: React app can't connect to API
**Error**: `Network Error` or `CORS error`

**Solution**:
```bash
# Verify API URL in environment
echo $REACT_APP_API_URL

# Check CORS configuration in Container Apps
# Ensure API is running and accessible
```

#### Issue: Build fails with dependency errors
**Error**: `npm install failed`

**Solution**:
```bash
# Clear npm cache
npm cache clean --force

# Delete node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Use specific Node.js version
nvm use 18
```

### Copilot Studio Issues

#### Issue: Bot doesn't respond
**Error**: `No response from bot`

**Solution**:
1. Check if HTTP action is configured correctly
2. Verify API endpoint is accessible
3. Test API independently first
4. Check bot topic triggers

#### Issue: Teams integration fails
**Error**: `App installation failed`

**Solution**:
1. Verify bot is published
2. Check Teams app permissions
3. Ensure organization allows custom bots
4. Try private installation first

## 🔧 Debugging Tools

### Azure CLI Commands
```bash
# Check resource status
az resource list --resource-group <rg-name> --output table

# Get deployment logs
az deployment group show --resource-group <rg-name> --name <deployment-name>

# Check Container Apps logs
az containerapp logs show --name <app-name> --resource-group <rg-name> --follow
```

### Monitoring & Diagnostics
```bash
# Application Insights query
az monitor app-insights query --app <app-insights-name> --analytics-query "requests | top 10 by timestamp desc"

# Check OpenAI usage
az cognitiveservices account list-usage --name <openai-name> --resource-group <rg-name>
```

### Local Testing
```bash
# Test API health
curl https://<container-app-url>/health

# Test OpenAI connectivity
curl -H "Authorization: Bearer $(az account get-access-token --query accessToken -o tsv)" \
     https://<openai-endpoint>/openai/deployments/<model>/chat/completions?api-version=2024-02-15-preview
```

## 🐛 Common Error Codes

| Error Code | Description | Solution |
|------------|-------------|----------|
| 429 | Rate limit exceeded | Implement retry logic, check quotas |
| 401 | Authentication failed | Verify credentials, check RBAC |
| 404 | Resource not found | Check resource names, verify deployment |
| 500 | Internal server error | Check logs, verify configuration |
| 503 | Service unavailable | Check service health, try different region |

## 📊 Performance Issues

### Slow API responses
**Symptoms**: High latency, timeouts

**Solutions**:
- Check AI Search query performance
- Optimize embedding generation
- Add caching layer
- Scale Container Apps

### High costs
**Symptoms**: Unexpected Azure charges

**Solutions**:
- Monitor OpenAI token usage
- Implement request throttling
- Optimize AI Search queries
- Review resource SKUs

## 🔄 Recovery Procedures

### Complete redeployment
```bash
# Clean up resources
azd down --force --purge

# Redeploy everything
azd up
```

### Partial redeployment
```bash
# Redeploy specific service
azd deploy api

# Update specific resource
az deployment group create --resource-group <rg-name> --template-file infra/modules/openai.bicep
```

## 📞 Getting Additional Help

### During Workshop
- Raise hand for instructor assistance
- Ask questions in chat
- Collaborate with teammates

### Post-Workshop Resources
- GitHub Issues: Create issues in workshop repository
- Azure Support: For Azure-specific problems
- Community Forums: Stack Overflow, Azure Community
- Documentation: Official Microsoft docs

### Emergency Contacts
- Workshop Instructor: [instructor-email]
- Azure Support: https://azure.microsoft.com/support/
- Technical Issues: Create GitHub issue

---

**Remember: Every expert was once a beginner. Don't hesitate to ask for help! 🤝**

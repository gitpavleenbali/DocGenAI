# Pre-Workshop Checklist

## ✅ Mandatory Requirements

### Azure Access
- [ ] Active Azure subscription
- [ ] Contributor or Owner permissions on subscription
- [ ] Azure OpenAI access approved (apply at https://aka.ms/oai/access)
- [ ] Sufficient quota for:
  - [ ] Azure OpenAI (at least 10K TPM for gpt-4o-mini)
  - [ ] Container Apps (2 vCPU, 4GB memory)
  - [ ] Storage accounts

### Software Installation
- [ ] Azure CLI installed and working
- [ ] Azure Developer CLI (azd) installed
- [ ] Docker Desktop installed and running
- [ ] Node.js 18+ and npm
- [ ] Python 3.9+ and pip
- [ ] Git client
- [ ] VS Code (recommended)

### Verification Commands
Run these commands to verify your setup:

```bash
# Azure CLI
az --version
az account show

# Azure Developer CLI
azd version

# Docker
docker --version
docker run hello-world

# Node.js
node --version
npm --version

# Python
python --version
pip --version

# Git
git --version
```

## 🎯 Workshop Preparation

### Repository Setup
- [ ] Repository cloned locally
- [ ] Environment file configured
- [ ] Sample documents prepared for testing

### Azure Setup
- [ ] Logged into Azure CLI (`az login`)
- [ ] Correct subscription selected
- [ ] Resource providers registered
- [ ] Region selected (recommend: East US 2, West Europe, or Australia East)

### Test Materials
- [ ] Sample PDF documents ready (technical docs, reports, articles)
- [ ] List of questions to ask about documents
- [ ] Microsoft Teams access for bot testing

## 🚨 Common Issues to Check

### Azure Quotas
Verify you have sufficient quotas in your chosen region:
- Azure OpenAI service availability
- Container Apps core quota
- Storage account limits

### Network Access
- Corporate firewall allows Azure endpoints
- Docker Desktop can pull images
- VS Code can access Azure extensions

### Permissions
- Azure subscription admin rights
- Ability to create resource groups
- Ability to assign managed identity roles

## 📞 Support Contacts

**During Workshop:**
- Primary Instructor: [Your Name] - [Email]
- Technical Assistant: [Assistant Name] - [Email]

**Emergency Contacts:**
- Azure Support: https://azure.microsoft.com/support/
- Workshop Repository Issues: [GitHub Issues Link]

## 📚 Recommended Pre-Reading

### Essential (15 minutes)
- [Azure AI Foundry Overview](https://docs.microsoft.com/azure/ai-foundry/)
- [What is RAG?](https://docs.microsoft.com/azure/ai-services/openai/concepts/rag)

### Optional (30 minutes)
- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Copilot Studio Basics](https://docs.microsoft.com/copilot-studio/)

---

## ✅ Final Check

I confirm that I have:
- [ ] All required software installed and tested
- [ ] Azure access verified
- [ ] Repository downloaded and configured
- [ ] Sample materials prepared
- [ ] Read the essential documentation

**Date:** ___________  **Signature:** _______________

---

**See you at the workshop! 🚀**

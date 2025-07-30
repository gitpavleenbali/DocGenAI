# Quick Start Commands

## Windows PowerShell (Recommended)
```powershell
git clone https://github.com/gitpavleenbali/DocGenAI.git
cd DocGenAI
.\deploy.ps1
```

## Alternative PowerShell with Custom Environment
```powershell
.\deploy.ps1 -EnvironmentName "my-demo"
```

## Mac/Linux Bash
```bash
git clone https://github.com/gitpavleenbali/DocGenAI.git
cd DocGenAI
chmod +x deploy.sh
./deploy.sh
```

## What Happens Next
1. Script checks prerequisites (Azure CLI, azd, Docker)
2. Prompts for Azure login if needed
3. Deploys complete infrastructure (5-10 minutes)
4. Provides web application URL
5. Creates test document for immediate testing

## Expected Output
```
🚀 DocGenAI - One-Command Deployment Starting...
📋 Checking Prerequisites...
✅ Azure CLI found
✅ Azure Developer CLI found
✅ Docker found
🔐 Checking Azure Authentication...
✅ Logged in as: user@domain.com
🚀 Deploying DocGenAI to Azure...
✅ Deployment successful!
🌐 Web Application: https://ca-webapp-dev-xxx.azurecontainerapps.io/
```

## Test Your Deployment
1. Open the provided Web Application URL
2. Upload the generated `test-document.md` (or any PDF)
3. Ask: "What Azure services are used?"
4. See real RAG responses!

## Cleanup (When Done Testing)
```powershell
azd down --purge
```

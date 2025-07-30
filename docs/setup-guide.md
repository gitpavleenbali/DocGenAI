# Workshop Setup Guide

## 🔧 Tool Installation

### 1. Azure CLI
```bash
# Windows (PowerShell)
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'

# Verify installation
az --version
```

### 2. Azure Developer CLI (azd)
```bash
# Windows (PowerShell)
powershell -ex AllSigned -c "Invoke-RestMethod 'https://aka.ms/install-azd.ps1' | Invoke-Expression"

# Verify installation
azd version
```

### 3. Docker Desktop
- Download from: https://www.docker.com/products/docker-desktop
- Follow installation wizard
- Ensure Docker is running

### 4. Node.js
```bash
# Download from: https://nodejs.org/
# Verify installation
node --version
npm --version
```

### 5. Python
```bash
# Download from: https://www.python.org/downloads/
# Verify installation
python --version
pip --version
```

## 🔐 Azure Setup

### 1. Azure Subscription
- Ensure you have an Azure subscription
- Verify you have Contributor or Owner permissions
- Check your subscription has sufficient quota for:
  - Azure OpenAI
  - Container Apps
  - Storage accounts

### 2. Azure Login
```bash
# Login to Azure CLI
az login

# Set your subscription (if you have multiple)
az account set --subscription "Your Subscription Name"

# Login to Azure Developer CLI
azd auth login
```

### 3. Required Azure Providers
```bash
# Register required resource providers
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.MachineLearningServices
az provider register --namespace Microsoft.App
az provider register --namespace Microsoft.ContainerRegistry
```

## 📁 Repository Setup

### 1. Clone Repository
```bash
git clone https://github.com/your-org/docgenai-workshop
cd docgenai-workshop
```

### 2. Environment Configuration
```bash
# Copy environment template
cp .env.template .env

# Edit .env file with your settings
# AZURE_SUBSCRIPTION_ID=your-subscription-id
# AZURE_LOCATION=eastus2
# AZURE_ENV_NAME=docgenai-dev
```

### 3. Verify Setup
```bash
# Run setup verification script
azd env refresh
azd env list
```

## 🔍 Pre-Workshop Checklist

- [ ] Azure CLI installed and logged in
- [ ] Azure Developer CLI installed and authenticated
- [ ] Docker Desktop running
- [ ] Node.js and npm available
- [ ] Python and pip available
- [ ] Repository cloned locally
- [ ] Environment variables configured
- [ ] Azure providers registered
- [ ] Sufficient Azure quotas available

## 🧪 Test Your Setup

### 1. Test Azure CLI
```bash
az account show
az group list
```

### 2. Test Azure Developer CLI
```bash
azd version
azd env list
```

### 3. Test Docker
```bash
docker --version
docker run hello-world
```

### 4. Test Node.js
```bash
node --version
npm --version
```

### 5. Test Python
```bash
python --version
pip --version
```

## 🚨 Common Issues

### Issue: Azure CLI not found
**Solution**: 
- Restart terminal after installation
- Add Azure CLI to PATH manually if needed

### Issue: Docker permission denied
**Solution**: 
- Ensure Docker Desktop is running
- On Linux: Add user to docker group

### Issue: Azure login fails
**Solution**: 
- Clear browser cache
- Try `az login --use-device-code`

### Issue: Insufficient Azure quotas
**Solution**: 
- Request quota increases in Azure portal
- Choose different Azure region
- Use smaller VM sizes

## 💡 Tips

- 🔄 **Keep tools updated**: Run updates before the workshop
- 🌐 **Test internet connection**: Ensure stable connection for downloads
- 💾 **Free up disk space**: Ensure at least 5GB free space
- 🔑 **Have Azure credentials ready**: Know your subscription details

---

**Setup complete? You're ready for the workshop! 🎉**

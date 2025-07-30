# DocGenAI - Enterprise RAG Solution

## 🚀 One-Command Deployment

Deploy a complete PDF document analysis solution with Azure AI Foundry + RAG capabilities in just **one command**!

### Quick Start (Windows PowerShell)
```powershell
git clone https://github.com/gitpavleenbali/DocGenAI.git
cd DocGenAI
.\deploy.ps1
```

### Quick Start (Mac/Linux Bash)
```bash
git clone https://github.com/gitpavleenbali/DocGenAI.git
cd DocGenAI
chmod +x deploy.sh
./deploy.sh
```

## 🎯 What You Get

- **Complete RAG Pipeline**: Upload PDFs, ask questions, get intelligent answers
- **Azure AI Integration**: GPT-4o-mini, text-embedding-3-small, Azure AI Search
- **Modern Web Interface**: React TypeScript app with Fluent UI
- **Production Ready**: Container Apps, Blob Storage, Cosmos DB
- **One-Command Deploy**: From zero to working RAG in 10 minutes

## 📋 Prerequisites

The deployment script automatically installs:
- Azure CLI
- Azure Developer CLI (azd)
- Docker Desktop (manual install required)

### Manual Prerequisites
1. **Azure Subscription** with permissions to create resources
2. **Docker Desktop** - [Download here](https://www.docker.com/products/docker-desktop)

## 🔧 Advanced Usage

### Custom Environment Name
```powershell
.\deploy.ps1 -EnvironmentName "my-custom-env"
```

### Skip Prerequisites Check
```powershell
.\deploy.ps1 -SkipPrerequisites
```

### Bash Options
```bash
./deploy.sh custom-env-name true  # true = skip prerequisites
```

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Web     │    │   FastAPI       │    │   Azure OpenAI  │
│   Application   │───▶│   Backend       │───▶│   GPT-4o-mini   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       ▼                       │
         │              ┌─────────────────┐              │
         │              │  Azure AI       │              │
         │              │  Search         │              │
         │              │  (Vector Store) │              │
         │              └─────────────────┘              │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Blob Storage  │    │   Cosmos DB     │    │  Container Apps │
│   (Documents)   │    │   (Metadata)    │    │   (Hosting)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🧪 Testing Your Deployment

1. **Upload Test Document**: Use the included `test-document.md`
2. **Ask Questions**:
   - "What Azure services are used in DocGenAI?"
   - "How does the RAG chat work?"
   - "What are the main features?"

## 🔍 Deployment Details

### What Gets Created
- **Resource Group**: Contains all Azure resources
- **Container Apps Environment**: Hosts web app and API
- **Azure OpenAI**: GPT-4o-mini + text-embedding-3-small
- **Azure AI Search**: Vector search index
- **Blob Storage**: PDF document storage
- **Cosmos DB**: Document metadata
- **Application Insights**: Monitoring and logging

### Estimated Costs
- **Development**: ~$10-20/month
- **Production**: Scales with usage

## 📊 Features

### Document Processing
- ✅ PDF text extraction
- ✅ Intelligent chunking
- ✅ Vector embeddings
- ✅ Metadata extraction

### RAG Capabilities
- ✅ Semantic search
- ✅ Context-aware responses
- ✅ Multi-document queries
- ✅ Real-time processing

### User Interface
- ✅ Drag & drop upload
- ✅ Real-time chat
- ✅ Document management
- ✅ Responsive design

## 🔧 Customization

### Environment Variables
The deployment automatically configures:
- `AZURE_OPENAI_ENDPOINT`
- `AZURE_SEARCH_ENDPOINT`
- `AZURE_STORAGE_ACCOUNT`
- `COSMOS_DB_ENDPOINT`

### Scaling
- Container Apps auto-scale based on demand
- Azure AI services scale automatically
- Storage costs scale with usage

## 🚨 Troubleshooting

### Common Issues

**"Azure CLI not found"**
```powershell
# Install Azure CLI
winget install Microsoft.AzureCLI
```

**"azd command not found"**
```powershell
# Install Azure Developer CLI
winget install Microsoft.Azd
```

**"Docker not running"**
- Start Docker Desktop
- Ensure Docker daemon is running

**"Deployment failed"**
```powershell
# Check detailed logs
azd show
az group list
```

### Resource Cleanup
```powershell
# Remove all resources
azd down --purge
```

## 📝 Development

### Local Development
```powershell
# API development
cd api
pip install -r requirements.txt
uvicorn main:app --reload

# Web app development
cd webapp
npm install
npm start
```

### Project Structure
```
DocGenAI/
├── deploy.ps1          # Windows deployment script
├── deploy.sh           # Mac/Linux deployment script
├── azure.yaml          # AZD configuration
├── infra/              # Bicep infrastructure templates
├── api/                # FastAPI backend
├── webapp/             # React frontend
└── docs/               # Documentation
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Test deployment script
4. Submit pull request

## 📜 License

This project is licensed under the MIT License.

## 🆘 Support

For issues or questions:
1. Check troubleshooting section
2. Review deployment logs: `azd show`
3. Create GitHub issue with logs

---

## 🎉 Success!

After deployment, you'll get:
- 🌐 **Web Application URL** - Your RAG interface
- 🔌 **API Endpoint** - Backend services
- 📊 **Azure Portal Link** - Resource management

**Happy Document Chatting! 🤖📄**

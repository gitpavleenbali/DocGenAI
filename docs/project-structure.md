# 📁 Workshop Project Structure

This document provides a comprehensive overview of the DocGenAI workshop project structure to help participants navigate and understand the codebase.

## 🗂️ Root Directory Structure

```
DocGenAI/
│
├── 📋 README.md                    # Workshop overview and quick start
├── 🔧 azure.yaml                   # Azure Developer CLI configuration
├── 🌍 .env.template                # Environment configuration template
├── 📄 .gitignore                   # Git ignore patterns
├── 📜 LICENSE                      # MIT License
│
├── 📚 docs/                        # Workshop documentation
│   ├── 📖 workshop-guide.md        # Main 3-hour workshop curriculum
│   ├── 🛠️ setup-guide.md           # Pre-workshop setup instructions
│   ├── 📋 pre-workshop-checklist.md # Verification checklist
│   ├── 🔧 troubleshooting.md       # Common issues and solutions
│   └── 🏗️ architecture.md          # Technical architecture deep dive
│
├── 🏗️ infra/                       # Infrastructure as Code (Bicep)
│   ├── 🏠 main.bicep               # Main deployment template
│   ├── 📊 main.parameters.json     # Default parameters
│   ├── 📋 abbreviations.json       # Azure resource naming conventions
│   └── 📦 modules/                 # Reusable Bicep modules
│       ├── 🤖 ai-foundry.bicep     # Azure AI Foundry workspace
│       ├── 📦 container-apps.bicep  # Container Apps environment
│       ├── 🐳 container-registry.bicep # Azure Container Registry
│       ├── 🌐 cosmos-db.bicep      # Cosmos DB for metadata
│       ├── 📊 monitoring.bicep      # Application Insights & Log Analytics
│       ├── 🔍 search.bicep         # Azure AI Search
│       ├── 🌐 static-web-app.bicep # Static Web Apps for frontend
│       └── 💾 storage.bicep        # Azure Storage for documents
│
├── 🔧 scripts/                     # Utility scripts
│   ├── ✅ verify-setup.sh          # Prerequisites verification (Linux/Mac)
│   ├── ✅ verify-setup.ps1         # Prerequisites verification (Windows)
│   ├── 🚀 deploy-workshop.sh       # Deployment script (Linux/Mac)
│   └── 🚀 deploy-workshop.ps1      # Deployment script (Windows)
│
├── 🖥️ api/                         # Backend API (FastAPI)
│   ├── 🐍 main.py                  # Application entry point
│   ├── ⚙️ requirements.txt         # Python dependencies
│   ├── 🐳 Dockerfile               # Container configuration
│   ├── 📁 routers/                 # API route handlers
│   │   ├── 📄 documents.py         # Document upload/processing
│   │   ├── 💬 chat.py              # Chat/conversation endpoints
│   │   └── ❤️ health.py            # Health check endpoint
│   ├── 🔧 services/                # Business logic services
│   │   ├── 📝 document_processor.py # PDF text extraction
│   │   ├── 🔍 search_service.py    # Vector search implementation
│   │   ├── 🤖 ai_service.py        # OpenAI integration
│   │   └── 💾 storage_service.py   # Azure Storage operations
│   ├── 🗃️ models/                  # Data models and schemas
│   │   ├── 📄 document.py          # Document data models
│   │   └── 💬 chat.py              # Chat message models
│   └── 🧪 tests/                   # Unit and integration tests
│       ├── 🔧 test_api.py          # API endpoint tests
│       └── 🔧 test_services.py     # Service layer tests
│
├── 🌐 webapp/                      # Frontend Web Application (React)
│   ├── 📦 package.json             # npm dependencies and scripts
│   ├── 🔧 tsconfig.json            # TypeScript configuration
│   ├── ⚛️ src/                     # React source code
│   │   ├── 🏠 App.tsx              # Main application component
│   │   ├── 🎯 index.tsx            # Application entry point
│   │   ├── 📁 components/          # Reusable React components
│   │   │   ├── 📤 DocumentUpload.tsx    # File upload component
│   │   │   ├── 💬 ChatInterface.tsx     # Chat UI component
│   │   │   ├── 📋 DocumentList.tsx      # Document management
│   │   │   └── 🎨 Layout.tsx            # Application layout
│   │   ├── 🛠️ services/            # API client services
│   │   │   ├── 📡 api.ts           # HTTP client configuration
│   │   │   ├── 📄 documents.ts     # Document API calls
│   │   │   └── 💬 chat.ts          # Chat API calls
│   │   ├── 🎨 styles/              # CSS and styling
│   │   │   └── 🎨 App.css          # Main application styles
│   │   └── 🖼️ assets/             # Static assets (images, icons)
│   └── 🌐 public/                  # Public static files
│       ├── 🌐 index.html           # HTML template
│       └── 🖼️ favicon.ico          # Application icon
│
├── 🤖 bot/                         # Copilot Studio Configuration
│   ├── ⚙️ bot-config.json          # Bot configuration schema
│   ├── 📝 copilot-studio-setup.md  # Step-by-step setup guide
│   └── 🔧 topics/                  # Bot conversation topics
│       ├── 👋 greeting.json        # Welcome messages
│       ├── 📄 document-analysis.json # Document processing flows
│       └── ❓ help.json             # Help and support topics
│
└── 🧪 tests/                       # End-to-end tests
    ├── 🧪 e2e/                     # End-to-end test scenarios
    │   ├── 📄 document-upload.spec.ts   # Document upload testing
    │   └── 💬 chat-flow.spec.ts         # Chat functionality testing
    └── ⚙️ playwright.config.ts     # Test framework configuration
```

## 🎯 Key Workshop Files

### Essential Workshop Materials
- **📖 `docs/workshop-guide.md`** - Your main companion for the 3-hour workshop
- **🛠️ `docs/setup-guide.md`** - Complete this BEFORE the workshop
- **📋 `docs/pre-workshop-checklist.md`** - Verify you're ready
- **🔧 `docs/troubleshooting.md`** - Reference when things go wrong

### Infrastructure & Deployment
- **🏠 `infra/main.bicep`** - Main infrastructure template (Module 1)
- **🔧 `azure.yaml`** - Azure Developer CLI configuration
- **🌍 `.env.template`** - Environment variables template

### Backend Development (Module 3)
- **🐍 `api/main.py`** - FastAPI application entry point
- **📄 `api/routers/documents.py`** - Document processing endpoints
- **💬 `api/routers/chat.py`** - Chat conversation endpoints
- **🔍 `api/services/search_service.py`** - RAG implementation

### Frontend Development (Module 4)
- **⚛️ `webapp/src/App.tsx`** - Main React application
- **📤 `webapp/src/components/DocumentUpload.tsx`** - File upload UI
- **💬 `webapp/src/components/ChatInterface.tsx`** - Chat interface

### Bot Development (Module 5)
- **⚙️ `bot/bot-config.json`** - Copilot Studio configuration
- **📝 `bot/copilot-studio-setup.md`** - Setup instructions

## 🛠️ Development Workflow

### 1. Workshop Preparation
```bash
# Verify setup
./scripts/verify-setup.ps1

# Configure environment
cp .env.template .env
# Edit .env with your values
```

### 2. Infrastructure Deployment
```bash
# Deploy all Azure resources
azd up

# Check deployment status
azd env get-values
```

### 3. Local Development
```bash
# Backend API
cd api
python -m uvicorn main:app --reload

# Frontend Web App (new terminal)
cd webapp
npm install && npm start
```

### 4. Testing & Debugging
```bash
# Check application logs
azd logs --follow

# Run tests
cd api && python -m pytest
cd webapp && npm test
```

## 📊 Workshop Progress Tracking

Use this checklist to track your progress through the workshop:

### Module 1: Environment Setup (15 mins)
- [ ] Prerequisites verified with scripts
- [ ] Azure resources deployed with `azd up`
- [ ] Environment variables configured

### Module 2: AI Foundry Deep Dive (20 mins)
- [ ] Accessed Azure AI Foundry at https://ai.azure.com
- [ ] Explored deployed AI hub and project
- [ ] Tested OpenAI models in playground

### Module 3: Backend Development (45 mins)
- [ ] FastAPI application running locally
- [ ] Document upload endpoint working
- [ ] RAG implementation completed
- [ ] API deployed to Container Apps

### Module 4: Frontend Development (30 mins)
- [ ] React application running locally
- [ ] Document upload component working
- [ ] Chat interface functional
- [ ] Frontend deployed to Static Web Apps

### Module 5: Copilot Studio Integration (30 mins)
- [ ] Copilot Studio bot created
- [ ] Bot connected to backend API
- [ ] Bot deployed to Microsoft Teams

### Module 6: Testing & Demo (20 mins)
- [ ] End-to-end testing completed
- [ ] Demo scenario prepared
- [ ] All services healthy and responding

## 🆘 Quick Reference

### Useful Commands
```bash
# Deployment & Management
azd up                    # Deploy everything
azd deploy               # Deploy code changes only
azd down                 # Clean up resources
azd env get-values       # Show environment variables

# Development
npm start                # Start React dev server
python -m uvicorn main:app --reload  # Start FastAPI with hot reload

# Monitoring
azd logs --follow        # Watch application logs
az monitor metrics list  # View Azure metrics
```

### Important URLs
- **Azure AI Foundry**: https://ai.azure.com
- **Azure Portal**: https://portal.azure.com
- **Copilot Studio**: https://copilotstudio.microsoft.com
- **Workshop Repository**: [Insert your repo URL]

---

**🎓 Happy Learning! This structure is designed to guide you through building a complete enterprise AI solution. Follow the workshop guide and don't hesitate to ask for help!**

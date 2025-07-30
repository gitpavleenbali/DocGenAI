# DocGenAI Workshop - Azure AI Foundry & Copilot Studio Integration

🎯 **Workshop Objective**: Build an enterprise PDF document analysis solution with Azure AI Foundry, Copilot Studio, and modern web technologies.

## 🎪 Workshop Overview

This hands-on workshop will guide you through creating a complete AI-powered document analysis solution that includes:
- **Azure AI Foundry** for RAG (Retrieval Augmented Generation)
- **Microsoft Copilot Studio** for Teams integration
- **React Web Application** for document upload and chat
- **Azure Infrastructure** deployed with Infrastructure as Code

## 📋 Prerequisites

### Required Tools
- [ ] Azure subscription with sufficient permissions
- [ ] Azure CLI installed and configured
- [ ] Azure Developer CLI (azd) installed
- [ ] Docker Desktop installed and running
- [ ] VS Code with Azure extensions
- [ ] Node.js 18+ and npm
- [ ] Python 3.9+ and pip

### Knowledge Requirements
- Basic understanding of Azure services
- Familiarity with command line operations
- Basic knowledge of web development concepts

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Web     │    │  Copilot Studio │    │  Azure AI       │
│   Application   │◄──►│      Bot        │◄──►│    Foundry      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Container Apps │    │  Microsoft      │    │  Azure OpenAI   │
│   (FastAPI)     │    │     Teams       │    │   GPT-4o-mini   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │
         ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Azure Storage  │    │   Cosmos DB     │    │  Azure AI       │
│   (Documents)   │    │   (Metadata)    │    │    Search       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 Workshop Modules

### Module 1: Environment Setup (15 mins)
- Azure subscription preparation
- Tool installation verification
- Repository setup

### Module 2: Infrastructure Deployment (30 mins)
- Understanding the Bicep templates
- Deploying with Azure Developer CLI
- Verifying Azure resources

### Module 3: AI Foundry Configuration (20 mins)
- Setting up Azure OpenAI models
- Configuring ML workspace
- Testing AI capabilities

### Module 4: Backend API Development (45 mins)
- FastAPI application setup
- Document processing pipeline
- RAG implementation

### Module 5: Frontend Development (30 mins)
- React application setup
- Azure Fluent UI integration
- Document upload functionality

### Module 6: Copilot Studio Integration (30 mins)
- Creating the bot in Copilot Studio
- Connecting to Azure services
- Teams deployment

### Module 7: Testing & Demo (20 mins)
- End-to-end testing
- Troubleshooting common issues
- Demo preparation

## 📚 Learning Outcomes

By the end of this workshop, you will:
- ✅ Deploy a complete AI solution on Azure
- ✅ Integrate Azure AI Foundry with custom applications
- ✅ Create and deploy Copilot Studio bots
- ✅ Implement RAG patterns for document analysis
- ✅ Use Infrastructure as Code with Bicep
- ✅ Build modern web applications with React

## 🔧 Quick Start

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-org/docgenai-workshop
   cd docgenai-workshop
   ```

2. **Login to Azure**
   ```bash
   az login
   azd auth login
   ```

3. **Deploy infrastructure**
   ```bash
   azd up
   ```

4. **Follow the workshop guide**
   - Open `/docs/workshop-guide.md`
   - Follow step-by-step instructions

## 📖 Workshop Materials

| Document | Description |
|----------|-------------|
| [Setup Guide](./setup-guide.md) | Detailed setup instructions |
| [Workshop Guide](./workshop-guide.md) | Step-by-step workshop content |
| [Troubleshooting](./troubleshooting.md) | Common issues and solutions |
| [Reference Architecture](./architecture.md) | Detailed architecture documentation |

## 💡 Tips for Success

- 🎯 **Follow the sequence**: Complete modules in order
- 🔄 **Check prerequisites**: Ensure all tools are installed
- 🤝 **Ask questions**: Don't hesitate to ask for help
- 📝 **Take notes**: Document your learnings
- 🧪 **Experiment**: Try modifications after completing each module

## 🆘 Getting Help

- **During workshop**: Raise your hand or ask in chat
- **Technical issues**: Check troubleshooting guide
- **Post-workshop**: Use GitHub issues for questions

---

**Ready to build the future of document AI? Let's get started! 🚀**

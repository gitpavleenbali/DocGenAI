# DocGenAI - Architecture Overview

## 🏗️ **Current Architecture Diagram**

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                    AZURE CLOUD                                     │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                     │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐                │
│  │   Users/Clients │    │   Stakeholders  │    │   Developers    │                │
│  └─────────┬───────┘    └─────────┬───────┘    └─────────┬───────┘                │
│            │                      │                      │                        │
│            │              HTTPS/TLS Encrypted            │                        │
│            ▼                      ▼                      ▼                        │
│  ┌─────────────────────────────────────────────────────────────────────────────────┐ │
│  │                        CONTAINER APPS ENVIRONMENT                              │ │
│  │                         (Production - ACTIVE)                                  │ │
│  │  ┌─────────────────┐              ┌─────────────────────────────────────────┐  │ │
│  │  │  React Frontend │◄────────────►│         FastAPI Backend                │  │ │
│  │  │  (TypeScript)   │              │       (Python RAG Engine)              │  │ │
│  │  │                 │              │                                         │  │ │
│  │  │ • Document UI   │              │ • PDF Processing                        │  │ │
│  │  │ • Chat Interface│              │ • Text Chunking                         │  │ │
│  │  │ • File Upload   │              │ • Vector Embeddings                     │  │ │
│  │  │ • Fluent UI     │              │ • RAG Pipeline                          │  │ │
│  │  │                 │              │ • Document Management                   │  │ │
│  │  └─────────────────┘              └─────────────────┬───────────────────────┘  │ │
│  │           │                                          │                          │ │
│  │  🌐 ca-webapp-dev-xxx              🔌 ca-api-dev-xxx                          │ │
│  └──┼─────────────────────────────────────────────────────────────────────────────┘ │
│     │                                          │                                    │
│     │                                          │                                    │
│  ┌──┼──────────────────────────────────────────┼────────────────────────────────────┐ │
│  │  │              AZURE AI & DATA SERVICES    │                                    │ │
│  │  │                                          │                                    │ │
│  │  │  ┌─────────────────┐                     │                                    │ │
│  │  │  │  Azure OpenAI   │◄────────────────────┘                                    │ │
│  │  │  │                 │                                                          │ │
│  │  │  │ • GPT-4o-mini   │                                                          │ │
│  │  │  │ • text-embed-3  │                                                          │ │
│  │  │  │ • Chat Completion│                                                         │ │
│  │  │  │ • Vector Generate│                                                         │ │
│  │  │  └─────────────────┘                                                          │ │
│  │  │                                                                               │ │
│  │  │  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐          │ │
│  │  │  │ Azure AI Search │    │  Blob Storage   │    │   Cosmos DB     │          │ │
│  │  │  │                 │    │                 │    │                 │          │ │
│  │  │  │ • Vector Index  │    │ • PDF Files     │    │ • Metadata      │          │ │
│  │  │  │ • Semantic      │    │ • Raw Documents │    │ • Document Info │          │ │
│  │  │  │   Search        │    │ • File Storage  │    │ • Chat History  │          │ │
│  │  │  │ • 1536-dim      │    │ • Authentication│    │ • User Sessions │          │ │
│  │  │  └─────────────────┘    └─────────────────┘    └─────────────────┘          │ │
│  │  │            ▲                      ▲                      ▲                  │ │
│  │  │            │                      │                      │                  │ │
│  │  │            └──────────────────────┼──────────────────────┘                  │ │
│  │  │                                   │                                         │ │
│  │  └───────────────────────────────────┼─────────────────────────────────────────┘ │
│  │                                      │                                           │
│  │  ┌───────────────────────────────────┼─────────────────────────────────────────┐ │
│  │  │            MONITORING & SECURITY  │                                         │ │
│  │  │                                   │                                         │ │
│  │  │  ┌─────────────────┐              │   ┌─────────────────┐                  │ │
│  │  │  │ App Insights    │              │   │ Managed Identity│                  │ │
│  │  │  │                 │              │   │                 │                  │ │
│  │  │  │ • Performance   │              │   │ • Service Auth  │                  │ │
│  │  │  │ • Error Tracking│              │   │ • RBAC          │                  │ │
│  │  │  │ • Usage Analytics│             │   │ • Zero Trust    │                  │ │
│  │  │  └─────────────────┘              │   └─────────────────┘                  │ │
│  │  │                                   │                                         │ │
│  │  │  ┌─────────────────┐              │   ┌─────────────────┐                  │ │
│  │  │  │ Log Analytics   │              │   │Container Registry│                 │ │
│  │  │  │                 │              │   │                 │                  │ │
│  │  │  │ • Centralized   │              │   │ • Docker Images │                  │ │
│  │  │  │   Logging       │              │   │ • Version Control│                 │ │
│  │  │  │ • Query & Alert │              │   │ • Security Scan │                  │ │
│  │  │  └─────────────────┘              │   └─────────────────┘                  │ │
│  │  └───────────────────────────────────┼─────────────────────────────────────────┘ │
│  │                                      │                                           │
│  │  ┌───────────────────────────────────┼─────────────────────────────────────────┐ │
│  │  │              UNUSED RESOURCES     │                                         │ │
│  │  │                (Created but Empty)│                                         │ │
│  │  │                                   │                                         │ │
│  │  │  ┌─────────────────┐              │                                         │ │
│  │  │  │ Static Web App  │              │                                         │ │
│  │  │  │                 │              │                                         │ │
│  │  │  │ ❌ Not Used     │              │                                         │ │
│  │  │  │ ❌ Empty        │              │                                         │ │
│  │  │  │ ❌ Default Page │              │                                         │ │
│  │  │  │                 │              │                                         │ │
│  │  │  │ 🌐 victorious-  │              │                                         │ │
│  │  │  │    cliff-xxx    │              │                                         │ │
│  │  │  └─────────────────┘              │                                         │ │
│  │  └───────────────────────────────────┼─────────────────────────────────────────┘ │
│  │                                      │                                           │
│  └──────────────────────────────────────┼───────────────────────────────────────────┘
│                                         │                                             │
│  ┌─────────────────────────────────────┼─────────────────────────────────────────┐   │
│  │              DEPLOYMENT TOOLS       │                                         │   │
│  │                                     │                                         │   │
│  │  ┌─────────────────┐                │   ┌─────────────────┐                  │   │
│  │  │ Azure Dev CLI   │                │   │ Azure CLI       │                  │   │
│  │  │     (azd)       │                │   │     (az)        │                  │   │
│  │  │                 │                │   │                 │                  │   │
│  │  │ • Infrastructure│                │   │ • Resource Mgmt │                  │   │
│  │  │ • App Deploy    │                │   │ • Authentication│                  │   │
│  │  │ • Environment   │                │   │ • Subscription  │                  │   │
│  │  └─────────────────┘                │   └─────────────────┘                  │   │
│  │                                     │                                         │   │
│  │  ┌─────────────────┐                │   ┌─────────────────┐                  │   │
│  │  │ Bicep Templates │                │   │ Docker Build    │                  │   │
│  │  │                 │                │   │                 │                  │   │
│  │  │ • IaC Definition│                │   │ • Multi-stage   │                  │   │
│  │  │ • Resource Deps │                │   │ • Optimization  │                  │   │
│  │  │ • Configuration │                │   │ • Registry Push │                  │   │
│  │  └─────────────────┘                │   └─────────────────┘                  │   │
│  └─────────────────────────────────────┼─────────────────────────────────────────┘   │
└─────────────────────────────────────────┼─────────────────────────────────────────────┘
                                          │
                                          ▼
                              ┌─────────────────┐
                              │ One-Command     │
                              │ Deploy Script   │
                              │                 │
                              │ • deploy.ps1    │
                              │ • deploy.sh     │
                              │ • Prerequisites │
                              │ • Full Deploy   │
                              └─────────────────┘
```

## 📊 **Data Flow Diagram**

```
USER INTERACTION FLOW:
┌─────────────┐    HTTPS    ┌─────────────┐    REST API    ┌─────────────┐
│    User     │────────────▶│   React     │───────────────▶│   FastAPI   │
│   Browser   │◄────────────│  Frontend   │◄───────────────│   Backend   │
└─────────────┘    HTML/JS  └─────────────┘   JSON/Data   └─────────────┘
                                                                  │
                                                                  ▼
RAG PROCESSING FLOW:                                    ┌─────────────┐
┌─────────────┐    PDF     ┌─────────────┐    Text     │ OpenAI API  │
│  PDF Upload │───────────▶│   Extract   │────────────▶│ Embeddings  │
└─────────────┘            └─────────────┘             └─────────────┘
                                  │                           │
                                  ▼                           ▼
┌─────────────┐   Metadata  ┌─────────────┐   Vectors  ┌─────────────┐
│  Cosmos DB  │◄───────────│    Chunk    │───────────▶│ AI Search   │
└─────────────┘            └─────────────┘            └─────────────┘
                                  │                           │
                                  ▼                           ▼
┌─────────────┐   Binary    ┌─────────────┐   Index    ┌─────────────┐
│ Blob Storage│◄───────────│    Store    │───────────▶│ Vector DB   │
└─────────────┘            └─────────────┘            └─────────────┘

CHAT QUERY FLOW:
┌─────────────┐   Question  ┌─────────────┐  Similarity ┌─────────────┐
│    User     │────────────▶│ AI Search   │────────────▶│   Context   │
│   Query     │             └─────────────┘             │ Retrieval   │
└─────────────┘                    │                   └─────────────┘
      ▲                            ▼                           │
      │                   ┌─────────────┐                     ▼
      │                   │   Vector    │            ┌─────────────┐
      │                   │  Embedding  │            │   Prompt    │
      │                   └─────────────┘            │ Engineering │
      │                                              └─────────────┘
      │                                                      │
      │                                                      ▼
      │               ┌─────────────┐   Completion   ┌─────────────┐
      └───────────────│  Response   │◄───────────────│  OpenAI     │
          Answer      │ Generation  │                │  GPT-4o     │
                      └─────────────┘                └─────────────┘
```

## 🎯 **Resource Utilization Status**

### ✅ **ACTIVE RESOURCES** (Production Ready)
| Resource | Type | Status | Purpose | URL |
|----------|------|--------|---------|-----|
| `ca-webapp-dev-xxx` | Container App | 🟢 Active | React Frontend | https://ca-webapp-dev-xxx.azurecontainerapps.io/ |
| `ca-api-dev-xxx` | Container App | 🟢 Active | FastAPI Backend | https://ca-api-dev-xxx.azurecontainerapps.io/ |
| `cs-openai-xxx` | OpenAI Service | 🟢 Active | GPT-4o-mini + Embeddings | AI Processing |
| `srch-dev-xxx` | AI Search | 🟢 Active | Vector Search Index | Document Retrieval |
| `stdevxxx000` | Blob Storage | 🟢 Active | PDF Document Storage | File Repository |
| `cosmos-dev-xxx` | Cosmos DB | 🟢 Active | Metadata & Chat History | Database |
| `appi-dev-xxx` | App Insights | 🟢 Active | Monitoring & Analytics | Telemetry |
| `log-dev-xxx` | Log Analytics | 🟢 Active | Centralized Logging | Diagnostics |
| `id-dev-xxx` | Managed Identity | 🟢 Active | Service Authentication | Security |
| `docgenxxx` | Container Registry | 🟢 Active | Docker Image Storage | DevOps |

### ❌ **UNUSED RESOURCES** (Infrastructure Waste)
| Resource | Type | Status | Purpose | Action Needed |
|----------|------|--------|---------|---------------|
| `stapp-dev-xxx` | Static Web App | 🔴 Unused | Empty/Default Page | Consider Removal |

## 💰 **Cost Optimization**

### Current Monthly Estimate:
- **Container Apps**: ~$15-25
- **Azure OpenAI**: ~$10-20 (usage-based)
- **AI Search**: ~$250 (Standard tier)
- **Cosmos DB**: ~$25
- **Storage**: ~$5
- **Static Web App**: ~$9 (**WASTED**)
- **Other Services**: ~$10
- **Total**: ~$324-354/month

### Optimization:
- ❌ Remove Static Web App: **Save $9/month**
- ✅ Keep Container Apps: **Production Ready**

## 🚀 **Deployment Architecture**

```
DEVELOPMENT WORKFLOW:
┌─────────────┐    git     ┌─────────────┐    azd up   ┌─────────────┐
│ Local Dev   │───────────▶│  Git Repo   │────────────▶│   Azure     │
│ Environment │            │   GitHub    │             │ Production  │
└─────────────┘            └─────────────┘             └─────────────┘
      │                           │                            │
      ▼                           ▼                            ▼
┌─────────────┐            ┌─────────────┐             ┌─────────────┐
│ • VS Code   │            │ • Source    │             │ • Container │
│ • Docker    │            │   Control   │             │   Apps      │
│ • Testing   │            │ • CI/CD     │             │ • Monitoring│
└─────────────┘            └─────────────┘             └─────────────┘

ONE-COMMAND DEPLOYMENT:
Customer Experience:
git clone repo → .\deploy.ps1 → Working RAG System (10 minutes)
```

## 🔒 **Security Architecture**

```
SECURITY LAYERS:
┌─────────────────────────────────────────────────────────────┐
│                        PERIMETER                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │    HTTPS    │    │   TLS 1.3   │    │  Azure AD   │     │
│  │ Encryption  │    │ Transport   │    │ Identity    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                       NETWORK                              │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Container  │    │   Private   │    │   Network   │     │
│  │ Environment │    │ Endpoints   │    │  Security   │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                      APPLICATION                           │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │  Managed    │    │    RBAC     │    │   API Key   │     │
│  │ Identities  │    │ Permissions │    │ Management  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────────┐
│                        DATA                                │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ Encryption  │    │  Backup &   │    │   Audit     │     │
│  │ at Rest     │    │  Recovery   │    │  Logging    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 **Stakeholder Summary**

### ✅ **What's Working**
- **Complete RAG Pipeline**: Operational end-to-end
- **Production Ready**: Container Apps with monitoring
- **One-Command Deploy**: Customer-friendly installation
- **Enterprise Security**: Azure AD + Managed Identities
- **Real-time Processing**: Immediate document analysis

### 🎯 **Business Value**
- **Time to Market**: 10-minute deployment
- **Scalability**: Auto-scaling Azure services
- **Cost Effective**: Pay-per-use model
- **Maintainable**: Modern container architecture
- **Secure**: Enterprise-grade security

### 📈 **Next Steps**
1. **Remove Static Web App** (cost optimization)
2. **Monitor usage patterns** (scaling decisions)
3. **Add CI/CD pipeline** (automated deployments)
4. **Implement backup strategy** (data protection)

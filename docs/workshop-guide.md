# DocGenAI Workshop Guide

## 🎯 Workshop Flow (3 hours total)

### Pre-Workshop Setup (Complete before workshop)
- Follow [Setup Guide](setup-guide.md)
- Verify all tools are installed
- Test Azure access

---

## Module 1: Environment Setup & Overview (15 minutes)

### 🎪 Welcome & Introductions (5 mins)

**What we're building today:**
- 📄 PDF document analysis system
- 🤖 AI-powered Q&A with RAG
- 💬 Teams bot integration
- 🌐 Modern web application

### 🏗️ Architecture Deep Dive (10 mins)

**Azure Services we'll use:**
- **Azure AI Foundry**: OpenAI models + ML workspace
- **Container Apps**: Scalable API hosting
- **Cosmos DB**: Document metadata storage
- **Azure Storage**: Document file storage
- **Azure AI Search**: Vector search & indexing
- **Static Web Apps**: React frontend hosting
- **Copilot Studio**: Teams bot creation

**Data Flow:**
1. User uploads PDF → Storage
2. Document processed → Embeddings created
3. Embeddings stored → Cosmos DB + AI Search
4. User asks questions → RAG retrieval
5. AI generates answers → Returns to user

---

## Module 2: Infrastructure Deployment (30 minutes)

### 🔧 Understanding the Code Structure (10 mins)

Let's explore the repository structure:

```
docgenai-workshop/
├── infra/                    # Infrastructure as Code
│   ├── main.bicep           # Main deployment template
│   ├── modules/             # Bicep modules
│   └── abbreviations.json   # Resource naming
├── api/                     # FastAPI backend
├── webapp/                  # React frontend
├── bot/                     # Copilot Studio config
└── docs/                    # Workshop documentation
```

**Key files to understand:**
- `azure.yaml` - Azure Developer CLI configuration
- `infra/main.bicep` - Infrastructure orchestration
- `infra/modules/` - Individual service templates

### 🚀 Deploy Infrastructure (15 mins)

**Step 1: Initialize environment**
```bash
# Navigate to project root
cd docgenai-workshop

# Initialize azd environment
azd env new docgenai-dev

# Set location (choose closest to you)
azd env set AZURE_LOCATION eastus2
```

**Step 2: Deploy everything**
```bash
# Deploy infrastructure and apps
azd up
```

⏱️ **Deployment will take ~10-15 minutes**

**What `azd up` does:**
1. Creates resource group
2. Deploys all Azure services
3. Builds and deploys applications
4. Configures service connections

### 🔍 Verify Deployment (5 mins)

**Check Azure Portal:**
1. Navigate to your resource group
2. Verify these resources exist:
   - AI Hub workspace
   - OpenAI account
   - Container Apps Environment
   - Cosmos DB account
   - Storage account
   - AI Search service
   - Static Web App

**Get important URLs:**
```bash
azd env get-values
```

Save these values - we'll need them later!

---

## Module 3: AI Foundry Configuration (20 minutes)

### 🧠 Explore Azure AI Foundry (10 mins)

**Step 1: Open AI Foundry**
1. Go to Azure Portal → Your AI Hub
2. Click "Launch Azure AI Foundry"
3. Explore the interface:
   - Model catalog
   - Deployments
   - Playground
   - Data connections

**Step 2: Verify Model Deployments**
1. Navigate to "Deployments"
2. Confirm these models are deployed:
   - `gpt-4o-mini` for chat completion
   - `text-embedding-3-small` for embeddings

### 🧪 Test AI Capabilities (10 mins)

**Step 1: Chat Playground**
1. Go to "Playground" → "Chat"
2. Select your `gpt-4o-mini` deployment
3. Test with prompt:
   ```
   You are a helpful document analysis assistant. 
   Explain what RAG (Retrieval Augmented Generation) is.
   ```

**Step 2: Embeddings Test**
1. Go to "Playground" → "Embeddings"
2. Select your `text-embedding-3-small` deployment
3. Test with text: "This is a sample document for embedding"
4. Observe the vector output

**✅ Success criteria:**
- Chat responses are generated
- Embeddings return vector arrays
- No API errors

---

## Module 4: Backend API Development (45 minutes)

### 📁 Explore API Structure (10 mins)

**Navigate to `/api` folder:**
```bash
cd api
```

**Key files:**
- `main.py` - FastAPI application entry point
- `routers/` - API route handlers
- `services/` - Business logic
- `models/` - Data models
- `Dockerfile` - Container configuration

### 🔧 Local Development Setup (10 mins)

**Step 1: Create virtual environment**
```bash
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

**Step 2: Install dependencies**
```bash
pip install -r requirements.txt
```

**Step 3: Environment configuration**
```bash
# Copy environment template
cp .env.template .env

# Get Azure service endpoints
azd env get-values > .env.generated

# Merge the values into .env
```

### 🏗️ Build Document Processing (15 mins)

**Step 1: Document Upload Handler**

Open `routers/documents.py` and examine:
```python
@router.post("/upload")
async def upload_document(file: UploadFile):
    # 1. Validate file type (PDF only)
    # 2. Save to Azure Storage
    # 3. Extract text content
    # 4. Create embeddings
    # 5. Store in Cosmos DB + AI Search
    # 6. Return document ID
```

**Step 2: Chat Handler**

Open `routers/chat.py` and examine:
```python
@router.post("/chat")
async def chat_with_document(request: ChatRequest):
    # 1. Create embedding for user question
    # 2. Search similar content in AI Search
    # 3. Prepare context from retrieved documents
    # 4. Send to OpenAI with RAG prompt
    # 5. Return AI response
```

### 🧪 Test API Locally (10 mins)

**Step 1: Start development server**
```bash
uvicorn main:app --reload --port 8000
```

**Step 2: Test endpoints**
```bash
# Check health endpoint
curl http://localhost:8000/health

# View API documentation
# Open: http://localhost:8000/docs
```

**Step 3: Test document upload**
1. Open FastAPI docs at http://localhost:8000/docs
2. Find `/documents/upload` endpoint
3. Upload a sample PDF
4. Verify response contains document ID

---

## Module 5: Frontend Development (30 minutes)

### 📱 Explore React Application (10 mins)

**Navigate to `/webapp` folder:**
```bash
cd webapp
```

**Key files:**
- `src/App.tsx` - Main application component
- `src/components/` - Reusable UI components
- `src/pages/` - Page components
- `src/services/` - API integration
- `package.json` - Dependencies

### 🎨 UI Components Tour (10 mins)

**Key components we'll examine:**

1. **DocumentUpload.tsx**
   - Drag & drop file upload
   - Progress indicator
   - File validation

2. **ChatInterface.tsx**
   - Message thread display
   - Input field with send button
   - Typing indicators

3. **DocumentList.tsx**
   - List uploaded documents
   - Delete functionality
   - Document status

### 🚀 Run Frontend Locally (10 mins)

**Step 1: Install dependencies**
```bash
npm install
```

**Step 2: Configure environment**
```bash
# Copy environment template
cp .env.template .env.local

# Set API URL
echo "REACT_APP_API_URL=http://localhost:8000" > .env.local
```

**Step 3: Start development server**
```bash
npm start
```

**Step 4: Test application**
1. Open http://localhost:3000
2. Try uploading a document
3. Test the chat interface
4. Verify API integration works

---

## Module 6: Copilot Studio Integration (30 minutes)

### 🤖 Create Copilot Studio Bot (15 mins)

**Step 1: Access Copilot Studio**
1. Go to https://copilotstudio.microsoft.com
2. Sign in with your Azure account
3. Select your environment

**Step 2: Create new bot**
1. Click "Create" → "New copilot"
2. Choose "Conversational" type
3. Name: "DocGenAI Assistant"
4. Description: "AI-powered document analysis bot"

**Step 3: Configure basic settings**
1. Set greeting message:
   ```
   Hi! I'm your document analysis assistant. 
   I can help you analyze and answer questions about your PDF documents.
   ```

### 🔗 Connect to Azure Services (15 mins)

**Step 1: Add Custom Action**
1. Go to "Actions" → "Add an action"
2. Choose "Create a new flow"
3. Name: "QueryDocuments"

**Step 2: Configure HTTP Request**
1. Add "HTTP" action
2. Method: POST
3. URI: `https://your-container-app-url/chat`
4. Headers:
   ```
   Content-Type: application/json
   ```
5. Body:
   ```json
   {
     "message": "{userQuestion}",
     "document_id": "{documentId}"
   }
   ```

**Step 3: Add to Topics**
1. Create new topic: "Document Query"
2. Trigger phrases:
   - "Ask about document"
   - "Query my files"
   - "What does the document say about"

**Step 4: Test the bot**
1. Use "Test your copilot" panel
2. Try sample queries
3. Verify responses from your API

---

## Module 7: Testing & Demo (20 minutes)

### 🧪 End-to-End Testing (10 mins)

**Test Scenario: Complete workflow**

1. **Upload document via web app**
   - Upload a sample PDF
   - Verify processing completion
   - Check document appears in list

2. **Query via web app**
   - Ask questions about the document
   - Verify AI responses are relevant
   - Test different question types

3. **Query via Teams bot**
   - Add bot to Teams
   - Ask same questions
   - Compare responses

### 🎭 Demo Preparation (10 mins)

**Prepare demo materials:**
- Sample PDF documents (technical docs, reports)
- List of interesting questions to ask
- Screenshots of key features

**Demo flow:**
1. Show architecture diagram
2. Upload document via web app
3. Ask questions and show responses
4. Switch to Teams and demonstrate bot
5. Show Azure resources in portal

**Key talking points:**
- RAG implementation benefits
- Scalability of Container Apps
- Security with managed identities
- Multi-channel access (web + Teams)

---

## 🎉 Workshop Wrap-up

### 🎯 What You've Accomplished

✅ **Infrastructure**: Complete Azure AI solution deployed
✅ **AI Integration**: Azure OpenAI models configured and tested
✅ **Backend**: FastAPI with RAG implementation
✅ **Frontend**: React application with modern UI
✅ **Bot**: Copilot Studio Teams integration
✅ **DevOps**: Infrastructure as Code with Bicep

### 🚀 Next Steps

**Enhance the solution:**
- Add user authentication
- Implement document versioning
- Add more AI models
- Create mobile app
- Add analytics dashboard

**Production considerations:**
- Security hardening
- Performance optimization
- Monitoring and alerting
- Backup and disaster recovery
- Cost optimization

### 📚 Resources for Continued Learning

- [Azure AI Foundry Documentation](https://docs.microsoft.com/azure/ai-foundry/)
- [Copilot Studio Learning Path](https://docs.microsoft.com/learn/copilot-studio/)
- [Azure Container Apps Tutorials](https://docs.microsoft.com/azure/container-apps/)
- [RAG Implementation Patterns](https://docs.microsoft.com/azure/ai-services/openai/concepts/rag)

---

**Congratulations! You've built a complete enterprise AI solution! 🎊**

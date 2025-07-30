# 🎓 Workshop Instructor Guide - DocGenAI

**Comprehensive guide for delivering the DocGenAI Azure AI Foundry & Copilot Studio workshop**

## 📋 Pre-Workshop Preparation (Day Before)

### 1. Instructor Setup Checklist
- [ ] **Azure Subscription**: Ensure sufficient quotas and OpenAI access
- [ ] **Demo Environment**: Deploy a complete working solution for demonstrations
- [ ] **Backup Plans**: Have troubleshooting scenarios ready
- [ ] **Materials**: All documentation reviewed and updated
- [ ] **Teams Meeting**: Workshop environment configured

### 2. Participant Communication
Send participants:
- [ ] **Pre-workshop email** with setup instructions (docs/setup-guide.md)
- [ ] **Checklist** to complete (docs/pre-workshop-checklist.md)
- [ ] **Verification script** to run (scripts/verify-setup.ps1)
- [ ] **Workshop materials** access link

### 3. Technical Prerequisites Verification
- [ ] **Azure OpenAI**: Confirm all participants have access
- [ ] **Resource Quotas**: Verify sufficient Container Apps, Storage, etc.
- [ ] **Network Access**: Ensure corporate firewalls allow Azure access
- [ ] **Tool Versions**: Confirm latest Azure CLI and azd versions

## 🎯 Workshop Delivery Guide (3 Hours)

### Module 1: Environment Setup (15 minutes)
**🎯 Objective**: Get everyone's infrastructure deployed and working

#### Instructor Actions:
1. **Welcome & Overview** (3 mins)
   - Introduce the solution architecture
   - Set expectations for the workshop
   - Review the day's agenda

2. **Prerequisites Check** (5 mins)
   - Have participants run verification scripts
   - Identify and help those with setup issues
   - Form helper groups for peer support

3. **Infrastructure Deployment** (7 mins)
   - Demonstrate `azd up` command
   - Monitor deployment progress across participants
   - Address common deployment issues

#### Success Criteria:
- [ ] All participants have Azure resources deployed
- [ ] Azure AI Foundry workspaces accessible
- [ ] Environment variables configured

#### Common Issues & Solutions:
- **Quota Exceeded**: Use alternative regions or reduce SKUs
- **OpenAI Access**: Help apply for access or share demo environment
- **Authentication**: Guide through `az login` and `azd auth login`

---

### Module 2: AI Foundry Deep Dive (20 minutes)
**🎯 Objective**: Understand Azure AI Foundry and test OpenAI models

#### Instructor Actions:
1. **AI Foundry Tour** (8 mins)
   - Navigate to https://ai.azure.com
   - Show deployed hubs and projects
   - Demonstrate model deployments

2. **Model Playground** (7 mins)
   - Test GPT-4o-mini with sample prompts
   - Show embedding model capabilities
   - Explain token usage and costs

3. **Integration Preview** (5 mins)
   - Preview how models connect to applications
   - Show connection strings and endpoints
   - Discuss security and authentication

#### Success Criteria:
- [ ] Participants can access their AI Foundry workspace
- [ ] Successfully tested both chat and embedding models
- [ ] Understanding of model integration concepts

#### Demo Prompts:
```
Chat Model Test:
"Analyze this document summary and provide 3 key insights about enterprise AI adoption."

Embedding Test:
"Compare the semantic similarity between these two sentences about cloud computing."
```

---

### Module 3: Backend API Development (45 minutes)
**🎯 Objective**: Build the FastAPI backend with RAG implementation

#### Instructor Actions:
1. **Project Structure Overview** (5 mins)
   - Walk through `api/` folder structure
   - Explain FastAPI architecture
   - Show key files: main.py, routers/, services/

2. **Core API Development** (20 mins)
   - **Document Processing** (8 mins):
     - Show `api/routers/documents.py`
     - Demonstrate PDF text extraction
     - Explain file upload handling
   
   - **RAG Implementation** (12 mins):
     - Walk through `api/services/search_service.py`
     - Show vector embedding generation
     - Demonstrate similarity search

3. **AI Integration** (10 mins)
   - Show `api/services/ai_service.py`
   - Demonstrate OpenAI client setup
   - Test chat completion with context

4. **Local Testing** (10 mins)
   - Run API locally with `uvicorn main:app --reload`
   - Test endpoints with curl or Postman
   - Show health check and document upload

#### Success Criteria:
- [ ] FastAPI application running locally
- [ ] Document upload endpoint functional
- [ ] Chat endpoint responding with AI-generated answers
- [ ] RAG pipeline processing documents correctly

#### Key Code Demonstrations:
```python
# Document Processing Pipeline
@router.post("/upload")
async def upload_document(file: UploadFile):
    # Extract text from PDF
    # Generate embeddings
    # Store in vector database
    
# RAG Chat Implementation
@router.post("/chat")
async def chat_with_documents(message: ChatMessage):
    # Retrieve relevant documents
    # Generate context-aware response
    # Return formatted answer
```

---

### Module 4: Frontend Development (30 minutes)
**🎯 Objective**: Build the React web application with Azure Fluent UI

#### Instructor Actions:
1. **React Project Overview** (5 mins)
   - Show `webapp/` folder structure
   - Explain component architecture
   - Demonstrate Azure Fluent UI integration

2. **Document Upload Component** (10 mins)
   - Build `DocumentUpload.tsx`
   - Show drag-and-drop functionality
   - Demonstrate file validation and progress

3. **Chat Interface** (10 mins)
   - Create `ChatInterface.tsx`
   - Show message rendering
   - Implement real-time chat functionality

4. **Application Integration** (5 mins)
   - Connect components in `App.tsx`
   - Test full user workflow
   - Show responsive design

#### Success Criteria:
- [ ] React application running at localhost:3000
- [ ] Document upload working with progress indicators
- [ ] Chat interface displaying messages correctly
- [ ] Full user workflow functional

#### Key Component Demonstrations:
```tsx
// Document Upload with Progress
const DocumentUpload: React.FC = () => {
  const [uploading, setUploading] = useState(false);
  const [progress, setProgress] = useState(0);
  
  // Show drag-and-drop implementation
  // Demonstrate progress tracking
};

// Chat Interface with AI Responses
const ChatInterface: React.FC = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [loading, setLoading] = useState(false);
  
  // Show message rendering
  // Demonstrate real-time updates
};
```

---

### Module 5: Copilot Studio Integration (30 minutes)
**🎯 Objective**: Create and deploy a Teams bot using Copilot Studio

#### Instructor Actions:
1. **Copilot Studio Setup** (10 mins)
   - Navigate to https://copilotstudio.microsoft.com
   - Create new bot from template
   - Configure bot settings and permissions

2. **Bot Development** (15 mins)
   - **Topics Creation** (7 mins):
     - Create document analysis topic
     - Configure trigger phrases
     - Set up conversation flow
   
   - **API Integration** (8 mins):
     - Connect to deployed FastAPI backend
     - Configure authentication
     - Test API calls from bot

3. **Teams Deployment** (5 mins)
   - Publish bot to Teams
   - Test conversation flow
   - Demonstrate document analysis capabilities

#### Success Criteria:
- [ ] Copilot Studio bot created and configured
- [ ] Bot successfully calling backend API
- [ ] Bot deployed and accessible in Teams
- [ ] End-to-end document analysis working

#### Bot Configuration Example:
```yaml
# Bot Topic: Document Analysis
Trigger Phrases:
  - "analyze document"
  - "upload file"
  - "ask about document"

Actions:
  1. Prompt for document upload
  2. Call API: POST /documents/upload
  3. Confirm processing
  4. Enable Q&A mode
```

---

### Module 6: Testing & Demo Preparation (20 minutes)
**🎯 Objective**: End-to-end testing and demo scenario preparation

#### Instructor Actions:
1. **End-to-End Testing** (10 mins)
   - Test complete workflow from web app
   - Verify Teams bot functionality
   - Check all integrations working

2. **Demo Scenario Preparation** (10 mins)
   - Prepare sample documents for demo
   - Create interesting questions to ask
   - Practice smooth demonstration flow

#### Success Criteria:
- [ ] All components working together seamlessly
- [ ] Demo scenarios tested and ready
- [ ] Participants prepared to present their solutions

#### Suggested Demo Scenarios:
1. **Enterprise Policy Analysis**
   - Upload company policy document
   - Ask compliance questions
   - Show accurate, sourced responses

2. **Technical Documentation Q&A**
   - Upload API documentation
   - Ask implementation questions
   - Demonstrate code examples in responses

## 🆘 Troubleshooting During Workshop

### Common Issues & Quick Fixes

#### Infrastructure Deployment Issues
- **Problem**: `azd up` fails with quota errors
- **Solution**: Use alternative regions or reduce SKUs in main.parameters.json

- **Problem**: Container Apps not starting
- **Solution**: Check logs with `azd logs --follow`, often networking or image issues

#### API Development Issues
- **Problem**: OpenAI connection errors
- **Solution**: Verify environment variables and model deployment names

- **Problem**: Document upload fails
- **Solution**: Check Azure Storage connection string and container permissions

#### Frontend Issues
- **Problem**: API calls failing from React app
- **Solution**: Verify CORS settings and API base URL configuration

- **Problem**: Components not rendering
- **Solution**: Check console for JavaScript errors, often dependency issues

#### Copilot Studio Issues
- **Problem**: Bot not responding in Teams
- **Solution**: Check bot publication status and Teams app permissions

- **Problem**: API calls from bot failing
- **Solution**: Verify backend API endpoints and authentication configuration

### Backup Plans
1. **Shared Demo Environment**: Have a working solution ready for demonstration
2. **Pre-built Components**: Ready-made code snippets for common issues
3. **Pair Programming**: Encourage participants to help each other
4. **Extended Time**: Have optional advanced features ready if running ahead

## 📊 Workshop Success Metrics

### Technical Metrics
- [ ] **Infrastructure**: 90%+ successful deployments
- [ ] **API**: All core endpoints functional
- [ ] **Frontend**: Basic UI working for 85%+ participants
- [ ] **Bot**: At least 70% successfully deployed to Teams

### Learning Metrics
- [ ] **Understanding**: Participants can explain RAG concepts
- [ ] **Skills**: Can modify and extend the solution
- [ ] **Confidence**: Feel ready to build similar solutions

### Satisfaction Metrics
- [ ] **Engagement**: Active participation throughout
- [ ] **Feedback**: Positive workshop evaluation scores
- [ ] **Follow-up**: Interest in advanced workshops

## 🎓 Post-Workshop Activities

### Immediate Follow-up (Same Day)
1. **Wrap-up Survey**: Collect feedback and suggestions
2. **Resource Sharing**: Send additional learning materials
3. **Next Steps**: Provide guidance for extending the solution

### Week 1 Follow-up
1. **Office Hours**: Schedule optional Q&A session
2. **Advanced Topics**: Share additional workshop opportunities
3. **Community**: Invite to ongoing user groups or forums

### Month 1 Follow-up
1. **Success Stories**: Collect implementation examples
2. **Feedback**: Gather lessons learned for workshop improvement
3. **Advanced Training**: Offer specialized workshops

## 📚 Additional Resources for Instructors

### Technical Deep Dives
- [Azure AI Foundry Best Practices](https://docs.microsoft.com/azure/ai-foundry/)
- [RAG Implementation Patterns](https://docs.microsoft.com/azure/ai-services/openai/concepts/rag)
- [Copilot Studio Advanced Features](https://docs.microsoft.com/power-virtual-agents/)

### Workshop Delivery Training
- [Technical Workshop Best Practices](https://docs.microsoft.com/learn/educator-center/)
- [Adult Learning Principles for Technical Training](https://docs.microsoft.com/learn/educator-center/adult-learning/)
- [Managing Technical Workshops](https://docs.microsoft.com/learn/educator-center/workshop-management/)

---

## 🎉 Workshop Delivery Checklist

### Day Of Workshop - 30 Minutes Before
- [ ] **Technical Setup**: Verify demo environment working
- [ ] **Materials Ready**: All links and resources accessible
- [ ] **Backup Plans**: Alternative scenarios prepared
- [ ] **Communication**: Teams meeting configured and tested

### During Workshop
- [ ] **Energy Management**: Keep pace appropriate, take breaks
- [ ] **Inclusion**: Ensure all participants engaged
- [ ] **Flexibility**: Adapt to group needs and skill levels
- [ ] **Documentation**: Take notes for future improvements

### After Workshop
- [ ] **Feedback Collection**: Send evaluation surveys
- [ ] **Resource Cleanup**: Help participants clean up Azure resources if desired
- [ ] **Follow-up Planning**: Schedule any promised office hours
- [ ] **Improvement Notes**: Document lessons learned

---

**🎓 Ready to deliver an amazing workshop! Remember: the goal is learning and empowerment, not perfect execution. Help participants build confidence in Azure AI technologies! 🚀**

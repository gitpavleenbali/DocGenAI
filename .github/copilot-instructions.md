<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# DocGenAI - Azure AI Foundry + Copilot Studio Integration

## Project Overview
This is an enterprise PDF document analysis solution built with:
- **Azure AI Foundry** for RAG (Retrieval Augmented Generation) capabilities
- **Microsoft Copilot Studio** for Teams integration and bot interface
- **React Web Application** for document upload and chat interface
- **Azure Infrastructure** (Bicep/ARM templates) for cloud deployment

## Development Guidelines

### Azure AI Foundry Integration
- Use Azure OpenAI GPT-4o-mini for document analysis and chat responses
- Implement text-embedding-3-small for document vectorization
- Follow Azure AI Studio best practices for prompt engineering and content safety
- Use Azure AI Search for semantic search capabilities

### Copilot Studio Bot Development
- Design conversational flows for document upload and Q&A scenarios
- Implement proper authentication and authorization flows
- Use Power Virtual Agents triggers and actions for Teams integration
- Follow Microsoft Bot Framework best practices

### Web Application Development
- Use React with TypeScript for type safety
- Implement modern UI/UX with Azure Fluent UI components
- Design responsive layouts for desktop and mobile
- Follow accessibility guidelines (WCAG 2.1)

### Infrastructure as Code
- Use Azure Bicep templates for infrastructure deployment
- Implement proper resource naming conventions
- Configure RBAC and security policies
- Set up Application Insights for monitoring

### Security & Compliance
- Implement Azure AD authentication for both web app and bot
- Use managed identities for service-to-service authentication
- Follow zero-trust security principles
- Ensure data residency and compliance requirements

### Code Quality
- Use type hints in Python code
- Implement proper error handling and logging
- Write unit tests for critical business logic
- Follow PEP 8 style guidelines for Python
- Use ESLint and Prettier for TypeScript/React code

### API Design
- Design RESTful APIs with proper HTTP status codes
- Implement rate limiting and throttling
- Use OpenAPI/Swagger for API documentation
- Version APIs appropriately

### Deployment & DevOps
- Use Azure DevOps or GitHub Actions for CI/CD
- Implement blue-green deployment strategies
- Set up automated testing pipelines
- Configure monitoring and alerting

### Performance Optimization
- Implement caching strategies for frequently accessed data
- Optimize document processing workflows
- Use CDN for static web assets
- Monitor and optimize Azure AI service usage costs

## File Structure Guidelines
- `/infra/` - Azure Bicep templates and deployment scripts
- `/bot/` - Copilot Studio bot configuration and custom code
- `/webapp/` - React web application source code
- `/api/` - Backend API services (Python FastAPI)
- `/docs/` - Documentation and architecture diagrams
- `/tests/` - Unit and integration tests
- `/scripts/` - Deployment and utility scripts

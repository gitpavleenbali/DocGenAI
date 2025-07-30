#!/bin/bash
# deploy-workshop.sh - Simplified workshop deployment script

echo "🚀 DocGenAI Workshop - Deployment Script"
echo "========================================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check prerequisites
check_prerequisites() {
    echo -e "${BLUE}🔍 Checking prerequisites...${NC}"
    
    # Check if .env exists
    if [ ! -f ".env" ]; then
        echo -e "${RED}❌ .env file not found${NC}"
        echo "Please copy .env.template to .env and configure your values"
        exit 1
    fi
    
    # Check Azure authentication
    if ! az account show >/dev/null 2>&1; then
        echo -e "${RED}❌ Azure CLI not authenticated${NC}"
        echo "Please run: az login"
        exit 1
    fi
    
    if ! azd auth list >/dev/null 2>&1; then
        echo -e "${RED}❌ Azure Developer CLI not authenticated${NC}"
        echo "Please run: azd auth login"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Prerequisites check passed${NC}"
}

# Function to deploy infrastructure
deploy_infrastructure() {
    echo -e "${BLUE}🏗️ Deploying Azure infrastructure...${NC}"
    echo "This may take 10-15 minutes..."
    
    if azd up --no-prompt; then
        echo -e "${GREEN}✅ Infrastructure deployment completed${NC}"
    else
        echo -e "${RED}❌ Infrastructure deployment failed${NC}"
        echo "Check the error messages above and troubleshoot"
        exit 1
    fi
}

# Function to verify deployment
verify_deployment() {
    echo -e "${BLUE}🔍 Verifying deployment...${NC}"
    
    # Get environment values
    echo "📋 Deployed resources:"
    azd env get-values | grep -E "(URL|ENDPOINT|CONNECTION)" || true
    
    # Check if API is responding (if URL is available)
    API_URL=$(azd env get-value API_BASE_URL 2>/dev/null || echo "")
    if [ ! -z "$API_URL" ]; then
        echo -e "${BLUE}🔍 Testing API health endpoint...${NC}"
        if curl -sf "$API_URL/health" >/dev/null; then
            echo -e "${GREEN}✅ API is responding${NC}"
        else
            echo -e "${YELLOW}⚠️  API not yet responding (this is normal for first deployment)${NC}"
            echo "It may take a few minutes for containers to start"
        fi
    fi
    
    echo -e "${GREEN}✅ Deployment verification completed${NC}"
}

# Function to display next steps
show_next_steps() {
    echo ""
    echo -e "${BLUE}🎉 Workshop deployment completed!${NC}"
    echo "========================================"
    echo ""
    echo "Next steps:"
    echo "1. 📖 Follow the workshop guide: docs/workshop-guide.md"
    echo "2. 🌐 Access Azure AI Foundry: https://ai.azure.com"
    echo "3. 💬 Continue with Copilot Studio setup"
    echo "4. 🔧 Build and deploy your applications"
    echo ""
    echo "Useful commands:"
    echo "• azd env get-values    - Show all environment variables"
    echo "• azd logs --follow     - View application logs"
    echo "• azd deploy           - Deploy code changes"
    echo "• azd down             - Clean up resources"
    echo ""
    echo -e "${GREEN}Happy coding! 🚀${NC}"
}

# Main deployment flow
main() {
    check_prerequisites
    deploy_infrastructure
    verify_deployment
    show_next_steps
}

# Run the deployment
main

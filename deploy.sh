#!/bin/bash

# DocGenAI - One-Command Deployment Script (Bash Version)
# This script deploys the complete RAG solution to Azure

ENVIRONMENT_NAME="${1:-docgenai-demo}"
SKIP_PREREQUISITES="${2:-false}"

echo "🚀 DocGenAI - One-Command Deployment Starting..."
echo "Environment: $ENVIRONMENT_NAME"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install prerequisites
install_prerequisites() {
    echo -e "${YELLOW}📋 Checking Prerequisites...${NC}"
    
    # Check Azure CLI
    if ! command_exists "az"; then
        echo -e "${RED}❌ Azure CLI not found.${NC}"
        echo -e "${YELLOW}Installing Azure CLI...${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            brew install azure-cli
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
        else
            echo -e "${RED}Please install Azure CLI manually: https://aka.ms/installazurecli${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Azure CLI found${NC}"
    fi
    
    # Check Azure Developer CLI
    if ! command_exists "azd"; then
        echo -e "${RED}❌ Azure Developer CLI not found.${NC}"
        echo -e "${YELLOW}Installing Azure Developer CLI...${NC}"
        
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            brew tap azure/azd && brew install azd
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            curl -fsSL https://aka.ms/install-azd.sh | bash
        else
            echo -e "${RED}Please install Azure Developer CLI manually: https://aka.ms/azd-install${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}✅ Azure Developer CLI found${NC}"
    fi
    
    # Check Docker
    if ! command_exists "docker"; then
        echo -e "${RED}❌ Docker not found. Please install Docker Desktop${NC}"
        echo -e "${YELLOW}Download from: https://www.docker.com/products/docker-desktop${NC}"
        exit 1
    else
        echo -e "${GREEN}✅ Docker found${NC}"
    fi
    
    echo -e "${GREEN}✅ All prerequisites satisfied!${NC}"
}

# Function to check Azure login
test_azure_login() {
    echo -e "${YELLOW}🔐 Checking Azure Authentication...${NC}"
    
    local account=$(az account show --query "user.name" -o tsv 2>/dev/null)
    if [[ -n "$account" ]]; then
        echo -e "${GREEN}✅ Logged in as: $account${NC}"
        return 0
    fi
    
    echo -e "${RED}❌ Not logged into Azure. Please login...${NC}"
    az login
    
    # Verify login
    account=$(az account show --query "user.name" -o tsv 2>/dev/null)
    if [[ -n "$account" ]]; then
        echo -e "${GREEN}✅ Successfully logged in as: $account${NC}"
        return 0
    else
        echo -e "${RED}❌ Azure login failed${NC}"
        exit 1
    fi
}

# Function to select subscription
select_azure_subscription() {
    echo -e "${YELLOW}📋 Selecting Azure Subscription...${NC}"
    
    az account list --query "[].{Name:name, Id:id, IsDefault:isDefault}" -o table
    
    local current_sub=$(az account show --query "name" -o tsv)
    echo -e "${YELLOW}Current subscription: $current_sub${NC}"
    
    read -p "Continue with current subscription? (y/n): " continue_choice
    if [[ "$continue_choice" != "y" && "$continue_choice" != "Y" ]]; then
        echo -e "${YELLOW}Available subscriptions:${NC}"
        az account list --query "[].{Name:name, Id:id}" -o table
        read -p "Enter subscription ID: " sub_id
        az account set --subscription "$sub_id"
        local new_sub=$(az account show --query "name" -o tsv)
        echo -e "${GREEN}✅ Switched to subscription: $new_sub${NC}"
    fi
}

# Function to initialize AZD
initialize_azure_dev_cli() {
    echo -e "${YELLOW}🔧 Initializing Azure Developer CLI...${NC}"
    
    if [[ -d ".azure" ]]; then
        echo -e "${YELLOW}Found existing .azure folder${NC}"
        read -p "Reinitialize? (y/n): " reinit_choice
        if [[ "$reinit_choice" == "y" || "$reinit_choice" == "Y" ]]; then
            rm -rf ".azure"
        fi
    fi
    
    if [[ ! -d ".azure" ]]; then
        echo -e "${YELLOW}Initializing new environment...${NC}"
        azd init --environment "$ENVIRONMENT_NAME"
    fi
    
    # Set environment
    export AZURE_ENV_NAME="$ENVIRONMENT_NAME"
    azd env select "$ENVIRONMENT_NAME"
}

# Function to deploy infrastructure and applications
deploy_application() {
    echo -e "${YELLOW}🚀 Deploying DocGenAI to Azure...${NC}"
    echo -e "${YELLOW}This will take 5-10 minutes...${NC}"
    
    if azd up --environment "$ENVIRONMENT_NAME"; then
        echo -e "${GREEN}✅ Deployment successful!${NC}"
    else
        echo -e "${RED}❌ Deployment failed${NC}"
        exit 1
    fi
}

# Function to display deployment results
show_deployment_results() {
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo -e "${CYAN}========================================${NC}"
    
    # Get endpoints
    local endpoints_json=$(azd show --output json 2>/dev/null)
    
    if [[ -n "$endpoints_json" ]]; then
        echo -e "${YELLOW}📱 Your DocGenAI Application:${NC}"
        echo ""
        
        # Extract webapp URL
        local webapp_url=$(echo "$endpoints_json" | grep -o '"webapp"[^}]*"endpoint":"[^"]*' | grep -o 'https://[^"]*' | head -1)
        if [[ -n "$webapp_url" ]]; then
            echo -e "${CYAN}🌐 Web Application: $webapp_url${NC}"
            echo -e "${WHITE}   👆 Click here to upload PDFs and chat with documents!${NC}"
        fi
        
        # Extract API URL
        local api_url=$(echo "$endpoints_json" | grep -o '"api"[^}]*"endpoint":"[^"]*' | grep -o 'https://[^"]*' | head -1)
        if [[ -n "$api_url" ]]; then
            echo -e "${CYAN}🔌 API Endpoint: $api_url${NC}"
        fi
        
        echo ""
        echo -e "${YELLOW}✨ Test Instructions:${NC}"
        echo -e "${WHITE}1. Open the Web Application URL above${NC}"
        echo -e "${WHITE}2. Upload a PDF document${NC}"
        echo -e "${WHITE}3. Ask questions about the document content${NC}"
        echo -e "${WHITE}4. See real-time RAG responses!${NC}"
    else
        echo -e "${YELLOW}⚠️ Could not retrieve endpoints. Check 'azd show' manually.${NC}"
    fi
}

# Function to create test document
create_test_document() {
    echo -e "${YELLOW}📄 Creating test document...${NC}"
    
    cat > test-document.md << 'EOF'
# DocGenAI Test Document

## Overview
This is a test document for the DocGenAI RAG (Retrieval Augmented Generation) system.

## Features
- **Document Upload**: Upload PDF files for analysis
- **Vector Search**: Uses Azure AI Search for semantic understanding
- **RAG Chat**: Ask questions about uploaded documents
- **Real-time Processing**: Immediate text extraction and indexing

## Azure Services Used
- Azure OpenAI (GPT-4o-mini, text-embedding-3-small)
- Azure AI Search (vector search capabilities)
- Azure Blob Storage (document storage)
- Azure Cosmos DB (metadata storage)
- Azure Container Apps (hosting)

## Test Questions
Try asking these questions after uploading this document:
- "What Azure services are used in DocGenAI?"
- "What are the main features of this system?"
- "How does the RAG chat work?"
- "What models are used for embeddings?"

## Conclusion
This document demonstrates the full RAG pipeline working with real document content analysis.
EOF

    echo -e "${GREEN}✅ Created test-document.md for testing${NC}"
}

# Main execution flow
main() {
    # Check prerequisites
    if [[ "$SKIP_PREREQUISITES" != "true" ]]; then
        install_prerequisites
    fi
    
    # Azure authentication
    test_azure_login
    
    # Subscription selection
    select_azure_subscription
    
    # Initialize AZD
    initialize_azure_dev_cli
    
    # Create test document
    create_test_document
    
    # Deploy application
    deploy_application
    
    # Show results
    show_deployment_results
    
    echo ""
    echo -e "${GREEN}🎊 SUCCESS! DocGenAI is ready to use!${NC}"
    echo -e "${YELLOW}Total deployment time: Complete RAG solution deployed!${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo -e "${WHITE}- Open the Web Application URL${NC}"
    echo -e "${WHITE}- Upload the test-document.md (convert to PDF) or any PDF${NC}"
    echo -e "${WHITE}- Start chatting with your documents!${NC}"
}

# Run main function with error handling
if ! main "$@"; then
    echo -e "${RED}💥 Deployment failed${NC}"
    echo -e "${YELLOW}Please check the error message above and try again.${NC}"
    exit 1
fi

#!/bin/bash
# verify-setup.sh - Workshop prerequisite verification script

echo "🎓 DocGenAI Workshop - Setup Verification"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Track overall success
SETUP_SUCCESS=true

check_command() {
    local cmd=$1
    local name=$2
    local version_flag=$3
    
    if command -v $cmd >/dev/null 2>&1; then
        local version=$($cmd $version_flag 2>&1 | head -n 1)
        echo -e "✅ ${GREEN}$name${NC} - $version"
    else
        echo -e "❌ ${RED}$name not found${NC}"
        SETUP_SUCCESS=false
    fi
}

check_azure_login() {
    echo "🔍 Checking Azure Authentication..."
    
    if az account show >/dev/null 2>&1; then
        local account=$(az account show --query "name" -o tsv)
        echo -e "✅ ${GREEN}Azure CLI authenticated${NC} - $account"
    else
        echo -e "❌ ${RED}Azure CLI not authenticated${NC}"
        echo "   Run: az login"
        SETUP_SUCCESS=false
    fi
    
    if azd auth list >/dev/null 2>&1; then
        echo -e "✅ ${GREEN}Azure Developer CLI authenticated${NC}"
    else
        echo -e "❌ ${RED}Azure Developer CLI not authenticated${NC}"
        echo "   Run: azd auth login"
        SETUP_SUCCESS=false
    fi
}

check_azure_openai_access() {
    echo "🔍 Checking Azure OpenAI Access..."
    
    local subscription_id=$(az account show --query "id" -o tsv 2>/dev/null)
    if [ ! -z "$subscription_id" ]; then
        local openai_services=$(az cognitiveservices account list --query "[?kind=='OpenAI'].name" -o tsv 2>/dev/null | wc -l)
        if [ $openai_services -gt 0 ]; then
            echo -e "✅ ${GREEN}Azure OpenAI services found${NC} ($openai_services services)"
        else
            echo -e "⚠️  ${YELLOW}No Azure OpenAI services found${NC}"
            echo "   You may need to create an Azure OpenAI service"
        fi
    fi
}

check_docker() {
    echo "🔍 Checking Docker..."
    
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            local version=$(docker --version)
            echo -e "✅ ${GREEN}Docker running${NC} - $version"
        else
            echo -e "❌ ${RED}Docker installed but not running${NC}"
            echo "   Start Docker Desktop"
            SETUP_SUCCESS=false
        fi
    else
        echo -e "❌ ${RED}Docker not found${NC}"
        SETUP_SUCCESS=false
    fi
}

check_environment_file() {
    echo "🔍 Checking Environment Configuration..."
    
    if [ -f ".env" ]; then
        echo -e "✅ ${GREEN}.env file exists${NC}"
        
        # Check for required variables
        local required_vars=("AZURE_SUBSCRIPTION_ID" "AZURE_LOCATION" "AZURE_RESOURCE_GROUP")
        for var in "${required_vars[@]}"; do
            if grep -q "^$var=" .env; then
                local value=$(grep "^$var=" .env | cut -d'=' -f2)
                if [ ! -z "$value" ] && [ "$value" != "your-value-here" ]; then
                    echo -e "  ✅ ${GREEN}$var configured${NC}"
                else
                    echo -e "  ❌ ${RED}$var not configured${NC}"
                    SETUP_SUCCESS=false
                fi
            else
                echo -e "  ❌ ${RED}$var missing${NC}"
                SETUP_SUCCESS=false
            fi
        done
    else
        echo -e "❌ ${RED}.env file not found${NC}"
        echo "   Copy .env.template to .env and configure values"
        SETUP_SUCCESS=false
    fi
}

echo "1. Checking Required Tools..."
echo "----------------------------"
check_command "az" "Azure CLI" "--version"
check_command "azd" "Azure Developer CLI" "version"
check_command "node" "Node.js" "--version"
check_command "npm" "npm" "--version"
check_command "python" "Python" "--version"
check_command "pip" "pip" "--version"
check_command "git" "Git" "--version"

echo ""
echo "2. Checking Docker..."
echo "--------------------"
check_docker

echo ""
echo "3. Checking Azure Authentication..."
echo "----------------------------------"
check_azure_login

echo ""
echo "4. Checking Azure OpenAI Access..."
echo "---------------------------------"
check_azure_openai_access

echo ""
echo "5. Checking Environment Configuration..."
echo "---------------------------------------"
check_environment_file

echo ""
echo "========================================"
if [ "$SETUP_SUCCESS" = true ]; then
    echo -e "🎉 ${GREEN}Setup verification completed successfully!${NC}"
    echo -e "You're ready for the workshop! 🚀"
else
    echo -e "⚠️  ${YELLOW}Setup verification found issues${NC}"
    echo "Please resolve the issues above before attending the workshop."
    echo ""
    echo "📖 For help, check:"
    echo "   - docs/setup-guide.md"
    echo "   - docs/troubleshooting.md"
fi
echo "========================================"

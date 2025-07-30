# DocGenAI - One-Command Deployment Script
# This script deploys the complete RAG solution to Azure

param(
    [string]$EnvironmentName = "docgenai-demo",
    [switch]$SkipPrerequisites = $false
)

Write-Host "🚀 DocGenAI - One-Command Deployment Starting..." -ForegroundColor Green
Write-Host "Environment: $EnvironmentName" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

# Function to check if a command exists
function Test-Command($Command) {
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to install prerequisites
function Install-Prerequisites {
    Write-Host "📋 Checking Prerequisites..." -ForegroundColor Yellow
    
    # Check Azure CLI
    if (-not (Test-Command "az")) {
        Write-Host "❌ Azure CLI not found. Installing..." -ForegroundColor Red
        Write-Host "Please install Azure CLI from: https://aka.ms/installazurecli" -ForegroundColor Yellow
        Write-Host "After installation, restart PowerShell and run this script again." -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "✅ Azure CLI found" -ForegroundColor Green
    }
    
    # Check Azure Developer CLI
    if (-not (Test-Command "azd")) {
        Write-Host "❌ Azure Developer CLI not found. Installing..." -ForegroundColor Red
        if ($IsWindows -or $env:OS -eq "Windows_NT") {
            Write-Host "Installing Azure Developer CLI..." -ForegroundColor Yellow
            winget install microsoft.azd
        } else {
            Write-Host "Please install Azure Developer CLI from: https://aka.ms/azd-install" -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "✅ Azure Developer CLI found" -ForegroundColor Green
    }
    
    # Check Docker
    if (-not (Test-Command "docker")) {
        Write-Host "❌ Docker not found. Please install Docker Desktop" -ForegroundColor Red
        Write-Host "Download from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "✅ Docker found" -ForegroundColor Green
    }
    
    Write-Host "✅ All prerequisites satisfied!" -ForegroundColor Green
}

# Function to check Azure login
function Test-AzureLogin {
    Write-Host "🔐 Checking Azure Authentication..." -ForegroundColor Yellow
    
    try {
        $account = az account show --query "user.name" -o tsv 2>$null
        if ($account) {
            Write-Host "✅ Logged in as: $account" -ForegroundColor Green
            return $true
        }
    }
    catch {}
    
    Write-Host "❌ Not logged into Azure. Please login..." -ForegroundColor Red
    az login
    
    # Verify login
    $account = az account show --query "user.name" -o tsv 2>$null
    if ($account) {
        Write-Host "✅ Successfully logged in as: $account" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ Azure login failed" -ForegroundColor Red
        exit 1
    }
}

# Function to select subscription
function Select-AzureSubscription {
    Write-Host "📋 Selecting Azure Subscription..." -ForegroundColor Yellow
    
    $subscriptions = az account list --query "[].{Name:name, Id:id, IsDefault:isDefault}" -o table
    Write-Host $subscriptions
    
    $currentSub = az account show --query "name" -o tsv
    Write-Host "Current subscription: $currentSub" -ForegroundColor Yellow
    
    $continue = Read-Host "Continue with current subscription? (y/n)"
    if ($continue -ne "y" -and $continue -ne "Y") {
        Write-Host "Available subscriptions:" -ForegroundColor Yellow
        az account list --query "[].{Name:name, Id:id}" -o table
        $subId = Read-Host "Enter subscription ID"
        az account set --subscription $subId
        $newSub = az account show --query "name" -o tsv
        Write-Host "✅ Switched to subscription: $newSub" -ForegroundColor Green
    }
}

# Function to initialize AZD
function Initialize-AzureDevCli {
    Write-Host "🔧 Initializing Azure Developer CLI..." -ForegroundColor Yellow
    
    if (Test-Path ".azure") {
        Write-Host "Found existing .azure folder" -ForegroundColor Yellow
        $reinit = Read-Host "Reinitialize? (y/n)"
        if ($reinit -eq "y" -or $reinit -eq "Y") {
            Remove-Item ".azure" -Recurse -Force
        }
    }
    
    if (-not (Test-Path ".azure")) {
        Write-Host "Initializing new environment..." -ForegroundColor Yellow
        azd init --environment $EnvironmentName
    }
    
    # Set environment
    $env:AZURE_ENV_NAME = $EnvironmentName
    azd env select $EnvironmentName
}

# Function to deploy infrastructure and applications
function Deploy-Application {
    Write-Host "🚀 Deploying DocGenAI to Azure..." -ForegroundColor Yellow
    Write-Host "This will take 5-10 minutes..." -ForegroundColor Yellow
    
    try {
        # Deploy everything
        azd up --environment $EnvironmentName
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Deployment successful!" -ForegroundColor Green
        } else {
            Write-Host "❌ Deployment failed" -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "❌ Deployment error: $_" -ForegroundColor Red
        exit 1
    }
}

# Function to display deployment results
function Show-DeploymentResults {
    Write-Host "🎉 Deployment Complete!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    
    try {
        # Get endpoints
        $endpoints = azd show --output json | ConvertFrom-Json
        
        if ($endpoints.services) {
            Write-Host "📱 Your DocGenAI Application:" -ForegroundColor Yellow
            Write-Host ""
            
            foreach ($service in $endpoints.services.PSObject.Properties) {
                $serviceName = $service.Name
                $serviceUrl = $service.Value.endpoint
                
                if ($serviceName -eq "webapp") {
                    Write-Host "🌐 Web Application: $serviceUrl" -ForegroundColor Cyan
                    Write-Host "   👆 Click here to upload PDFs and chat with documents!" -ForegroundColor White
                }
                elseif ($serviceName -eq "api") {
                    Write-Host "🔌 API Endpoint: $serviceUrl" -ForegroundColor Cyan
                }
            }
            
            Write-Host ""
            Write-Host "🔗 Azure Portal: $($endpoints.portalUrl)" -ForegroundColor Cyan
            Write-Host ""
            Write-Host "✨ Test Instructions:" -ForegroundColor Yellow
            Write-Host "1. Open the Web Application URL above" -ForegroundColor White
            Write-Host "2. Upload a PDF document" -ForegroundColor White
            Write-Host "3. Ask questions about the document content" -ForegroundColor White
            Write-Host "4. See real-time RAG responses!" -ForegroundColor White
        }
    }
    catch {
        Write-Host "⚠️ Could not retrieve endpoints. Check 'azd show' manually." -ForegroundColor Yellow
    }
}

# Function to create test document
function Create-TestDocument {
    Write-Host "📄 Creating test document..." -ForegroundColor Yellow
    
    $testContent = @"
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
"@

    $testContent | Out-File -FilePath "test-document.md" -Encoding UTF8
    Write-Host "✅ Created test-document.md for testing" -ForegroundColor Green
}

# Main execution flow
try {
    # Check prerequisites
    if (-not $SkipPrerequisites) {
        Install-Prerequisites
    }
    
    # Azure authentication
    Test-AzureLogin
    
    # Subscription selection
    Select-AzureSubscription
    
    # Initialize AZD
    Initialize-AzureDevCli
    
    # Create test document
    Create-TestDocument
    
    # Deploy application
    Deploy-Application
    
    # Show results
    Show-DeploymentResults
    
    Write-Host ""
    Write-Host "🎊 SUCCESS! DocGenAI is ready to use!" -ForegroundColor Green
    Write-Host "Total deployment time: Complete RAG solution deployed!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "- Open the Web Application URL" -ForegroundColor White
    Write-Host "- Upload the test-document.md (convert to PDF) or any PDF" -ForegroundColor White
    Write-Host "- Start chatting with your documents!" -ForegroundColor White
    
}
catch {
    Write-Host "💥 Deployment failed: $_" -ForegroundColor Red
    Write-Host "Please check the error message above and try again." -ForegroundColor Yellow
    exit 1
}

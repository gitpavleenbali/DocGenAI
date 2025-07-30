# deploy-workshop.ps1 - Simplified workshop deployment script for Windows

Write-Host "🚀 DocGenAI Workshop - Deployment Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to check prerequisites
function Test-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Blue
    
    # Check if .env exists
    if (-not (Test-Path ".env")) {
        Write-Host "❌ .env file not found" -ForegroundColor Red
        Write-Host "Please copy .env.template to .env and configure your values" -ForegroundColor White
        exit 1
    }
    
    # Check Azure authentication
    try {
        $null = az account show 2>$null
    }
    catch {
        Write-Host "❌ Azure CLI not authenticated" -ForegroundColor Red
        Write-Host "Please run: az login" -ForegroundColor White
        exit 1
    }
    
    try {
        $null = azd auth list 2>$null
    }
    catch {
        Write-Host "❌ Azure Developer CLI not authenticated" -ForegroundColor Red
        Write-Host "Please run: azd auth login" -ForegroundColor White
        exit 1
    }
    
    Write-Host "✅ Prerequisites check passed" -ForegroundColor Green
}

# Function to deploy infrastructure
function Deploy-Infrastructure {
    Write-Host "🏗️ Deploying Azure infrastructure..." -ForegroundColor Blue
    Write-Host "This may take 10-15 minutes..." -ForegroundColor White
    
    $deployResult = azd up --no-prompt
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Infrastructure deployment completed" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Infrastructure deployment failed" -ForegroundColor Red
        Write-Host "Check the error messages above and troubleshoot" -ForegroundColor White
        exit 1
    }
}

# Function to verify deployment
function Test-Deployment {
    Write-Host "🔍 Verifying deployment..." -ForegroundColor Blue
    
    # Get environment values
    Write-Host "📋 Deployed resources:" -ForegroundColor White
    $envValues = azd env get-values 2>$null
    if ($envValues) {
        $envValues | Where-Object { $_ -match "(URL|ENDPOINT|CONNECTION)" }
    }
    
    # Check if API is responding (if URL is available)
    try {
        $apiUrl = azd env get-value API_BASE_URL 2>$null
        if ($apiUrl) {
            Write-Host "🔍 Testing API health endpoint..." -ForegroundColor Blue
            try {
                $response = Invoke-RestMethod -Uri "$apiUrl/health" -Method Get -TimeoutSec 10
                Write-Host "✅ API is responding" -ForegroundColor Green
            }
            catch {
                Write-Host "⚠️  API not yet responding (this is normal for first deployment)" -ForegroundColor Yellow
                Write-Host "It may take a few minutes for containers to start" -ForegroundColor White
            }
        }
    }
    catch {
        # API URL not available yet
    }
    
    Write-Host "✅ Deployment verification completed" -ForegroundColor Green
}

# Function to display next steps
function Show-NextSteps {
    Write-Host ""
    Write-Host "🎉 Workshop deployment completed!" -ForegroundColor Blue
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "1. 📖 Follow the workshop guide: docs/workshop-guide.md" -ForegroundColor White
    Write-Host "2. 🌐 Access Azure AI Foundry: https://ai.azure.com" -ForegroundColor White
    Write-Host "3. 💬 Continue with Copilot Studio setup" -ForegroundColor White
    Write-Host "4. 🔧 Build and deploy your applications" -ForegroundColor White
    Write-Host ""
    Write-Host "Useful commands:" -ForegroundColor White
    Write-Host "• azd env get-values    - Show all environment variables" -ForegroundColor Gray
    Write-Host "• azd logs --follow     - View application logs" -ForegroundColor Gray
    Write-Host "• azd deploy           - Deploy code changes" -ForegroundColor Gray
    Write-Host "• azd down             - Clean up resources" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Happy coding! 🚀" -ForegroundColor Green
}

# Main deployment flow
function Main {
    Test-Prerequisites
    Deploy-Infrastructure
    Test-Deployment
    Show-NextSteps
}

# Run the deployment
Main

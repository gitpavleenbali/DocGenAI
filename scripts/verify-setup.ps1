# verify-setup.ps1 - Workshop prerequisite verification script for Windows

Write-Host "🎓 DocGenAI Workshop - Setup Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Track overall success
$SetupSuccess = $true

function Test-Command {
    param(
        [string]$Command,
        [string]$Name,
        [string]$VersionFlag = "--version"
    )
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        $version = & $Command $VersionFlag 2>$null | Select-Object -First 1
        Write-Host "✅ $Name - $version" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $Name not found" -ForegroundColor Red
        $script:SetupSuccess = $false
    }
}

function Test-AzureLogin {
    Write-Host "🔍 Checking Azure Authentication..." -ForegroundColor Yellow
    
    try {
        $account = az account show --query "name" -o tsv 2>$null
        if ($account) {
            Write-Host "✅ Azure CLI authenticated - $account" -ForegroundColor Green
        }
        else {
            throw "Not authenticated"
        }
    }
    catch {
        Write-Host "❌ Azure CLI not authenticated" -ForegroundColor Red
        Write-Host "   Run: az login" -ForegroundColor White
        $script:SetupSuccess = $false
    }
    
    try {
        $azdAuth = azd auth list 2>$null
        if ($azdAuth) {
            Write-Host "✅ Azure Developer CLI authenticated" -ForegroundColor Green
        }
        else {
            throw "Not authenticated"
        }
    }
    catch {
        Write-Host "❌ Azure Developer CLI not authenticated" -ForegroundColor Red
        Write-Host "   Run: azd auth login" -ForegroundColor White
        $script:SetupSuccess = $false
    }
}

function Test-AzureOpenAIAccess {
    Write-Host "🔍 Checking Azure OpenAI Access..." -ForegroundColor Yellow
    
    try {
        $subscriptionId = az account show --query "id" -o tsv 2>$null
        if ($subscriptionId) {
            $openaiServices = az cognitiveservices account list --query "[?kind=='OpenAI'].name" -o tsv 2>$null
            if ($openaiServices) {
                $count = ($openaiServices | Measure-Object -Line).Lines
                Write-Host "✅ Azure OpenAI services found ($count services)" -ForegroundColor Green
            }
            else {
                Write-Host "⚠️  No Azure OpenAI services found" -ForegroundColor Yellow
                Write-Host "   You may need to create an Azure OpenAI service" -ForegroundColor White
            }
        }
    }
    catch {
        Write-Host "⚠️  Could not check Azure OpenAI access" -ForegroundColor Yellow
    }
}

function Test-Docker {
    Write-Host "🔍 Checking Docker..." -ForegroundColor Yellow
    
    try {
        $null = Get-Command docker -ErrorAction Stop
        try {
            $null = docker info 2>$null
            $version = docker --version
            Write-Host "✅ Docker running - $version" -ForegroundColor Green
        }
        catch {
            Write-Host "❌ Docker installed but not running" -ForegroundColor Red
            Write-Host "   Start Docker Desktop" -ForegroundColor White
            $script:SetupSuccess = $false
        }
    }
    catch {
        Write-Host "❌ Docker not found" -ForegroundColor Red
        $script:SetupSuccess = $false
    }
}

function Test-EnvironmentFile {
    Write-Host "🔍 Checking Environment Configuration..." -ForegroundColor Yellow
    
    if (Test-Path ".env") {
        Write-Host "✅ .env file exists" -ForegroundColor Green
        
        $envContent = Get-Content ".env"
        $requiredVars = @("AZURE_SUBSCRIPTION_ID", "AZURE_LOCATION", "AZURE_RESOURCE_GROUP_NAME")
        
        foreach ($var in $requiredVars) {
            $line = $envContent | Where-Object { $_ -match "^$var=" }
            if ($line) {
                $value = ($line -split "=", 2)[1]
                if ($value -and $value -ne "your-value-here") {
                    Write-Host "  ✅ $var configured" -ForegroundColor Green
                }
                else {
                    Write-Host "  ❌ $var not configured" -ForegroundColor Red
                    $script:SetupSuccess = $false
                }
            }
            else {
                Write-Host "  ❌ $var missing" -ForegroundColor Red
                $script:SetupSuccess = $false
            }
        }
    }
    else {
        Write-Host "❌ .env file not found" -ForegroundColor Red
        Write-Host "   Copy .env.template to .env and configure values" -ForegroundColor White
        $script:SetupSuccess = $false
    }
}

Write-Host "1. Checking Required Tools..." -ForegroundColor Cyan
Write-Host "----------------------------" -ForegroundColor Cyan
Test-Command "az" "Azure CLI" "--version"
Test-Command "azd" "Azure Developer CLI" "version"
Test-Command "node" "Node.js" "--version"
Test-Command "npm" "npm" "--version"
Test-Command "python" "Python" "--version"
Test-Command "pip" "pip" "--version"
Test-Command "git" "Git" "--version"

Write-Host ""
Write-Host "2. Checking Docker..." -ForegroundColor Cyan
Write-Host "--------------------" -ForegroundColor Cyan
Test-Docker

Write-Host ""
Write-Host "3. Checking Azure Authentication..." -ForegroundColor Cyan
Write-Host "----------------------------------" -ForegroundColor Cyan
Test-AzureLogin

Write-Host ""
Write-Host "4. Checking Azure OpenAI Access..." -ForegroundColor Cyan
Write-Host "---------------------------------" -ForegroundColor Cyan
Test-AzureOpenAIAccess

Write-Host ""
Write-Host "5. Checking Environment Configuration..." -ForegroundColor Cyan
Write-Host "---------------------------------------" -ForegroundColor Cyan
Test-EnvironmentFile

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
if ($SetupSuccess) {
    Write-Host "🎉 Setup verification completed successfully!" -ForegroundColor Green
    Write-Host "You're ready for the workshop! 🚀" -ForegroundColor Green
}
else {
    Write-Host "⚠️  Setup verification found issues" -ForegroundColor Yellow
    Write-Host "Please resolve the issues above before attending the workshop." -ForegroundColor White
    Write-Host ""
    Write-Host "📖 For help, check:" -ForegroundColor White
    Write-Host "   - docs/setup-guide.md" -ForegroundColor White
    Write-Host "   - docs/troubleshooting.md" -ForegroundColor White
}
Write-Host "========================================" -ForegroundColor Cyan

#!/usr/bin/env pwsh

Write-Host "Starting post-provision script..."

# Set error action preference
$ErrorActionPreference = "Stop"

try {
    # Get environment variables from azd
    $resourceGroupName = $env:AZURE_RESOURCE_GROUP_NAME
    $subscriptionId = $env:AZURE_SUBSCRIPTION_ID
    $location = $env:AZURE_LOCATION
    
    Write-Host "Resource Group: $resourceGroupName"
    Write-Host "Subscription: $subscriptionId"
    Write-Host "Location: $location"
    
    # Check if Azure CLI is available
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error "Azure CLI is not installed or not in PATH"
        exit 1
    }
    
    # Check if logged in to Azure
    $account = az account show --query "id" -o tsv 2>$null
    if (-not $account) {
        Write-Host "Logging into Azure..."
        az login
    }
    
    # Set the correct subscription
    if ($subscriptionId) {
        Write-Host "Setting subscription to: $subscriptionId"
        az account set --subscription $subscriptionId
    }
    
    Write-Host "Post-provision script completed successfully!"
    
} catch {
    Write-Error "Post-provision script failed: $_"
    exit 1
}

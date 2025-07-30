targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Name of the resource group. If empty, a unique name will be generated.')
param resourceGroupName string = ''

// Generate unique resource names
var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
  'azd-template': 'docgenai-azure-ai-foundry'
}

// Resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Monitoring module (Log Analytics + Application Insights)
module monitoring 'modules/monitoring.bicep' = {
  name: 'monitoring'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
  }
}

// AI Foundry module (Azure OpenAI + ML Workspace)
module aiFoundry 'modules/ai-foundry.bicep' = {
  name: 'ai-foundry'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
  }
}

// Storage module (Blob, Queue, Table storage)
module storage 'modules/storage.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    principalId: aiFoundry.outputs.principalId
  }
}

// Cosmos DB module (Document database with vector support)
module cosmos 'modules/cosmos.bicep' = {
  name: 'cosmos'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    principalId: aiFoundry.outputs.principalId
  }
}

// Azure AI Search module (Vector search and indexing)
module search 'modules/search.bicep' = {
  name: 'search'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    principalId: aiFoundry.outputs.principalId
  }
}

// Container Registry module (Docker image hosting)
module containerRegistry 'modules/container-registry.bicep' = {
  name: 'container-registry'
  scope: rg
  params: {
    location: location
    resourceToken: resourceToken
    tags: tags
    principalId: aiFoundry.outputs.principalId
  }
}

// Container Apps module (API hosting)
module containerApps 'modules/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    environmentName: environmentName
    location: location
    resourceToken: resourceToken
    tags: tags
    userAssignedIdentityId: aiFoundry.outputs.userAssignedIdentityId
    logAnalyticsWorkspaceId: monitoring.outputs.logAnalyticsWorkspaceId
    applicationInsightsConnectionString: monitoring.outputs.applicationInsightsConnectionString
    containerRegistryLoginServer: containerRegistry.outputs.containerRegistryLoginServer
  }
}

// Static Web App module (React frontend hosting) - Using Container App instead
// module staticWebApp 'modules/static-web-app.bicep' = {
//   name: 'static-web-app'
//   scope: rg
//   params: {
//     environmentName: environmentName
//     location: location
//     resourceToken: resourceToken
//     tags: tags
//     apiContainerAppUrl: containerApps.outputs.apiContainerAppUrl
//   }
// }

// Outputs for azd
output AZURE_LOCATION string = location
output AZURE_RESOURCE_GROUP_NAME string = rg.name
output AZURE_STORAGE_ACCOUNT_NAME string = storage.outputs.storageAccountName
output AZURE_COSMOS_ACCOUNT_NAME string = cosmos.outputs.cosmosAccountName
output AZURE_SEARCH_SERVICE_NAME string = search.outputs.searchServiceName
output AZURE_OPENAI_ACCOUNT_NAME string = aiFoundry.outputs.openAiAccountName
// AI Hub outputs commented out for workshop simplicity
// output AZURE_AI_HUB_NAME string = aiFoundry.outputs.aiHubName
// output AZURE_AI_PROJECT_NAME string = aiFoundry.outputs.aiProjectName
// Static Web App outputs - using Container App instead
// output AZURE_STATIC_WEB_APP_NAME string = staticWebApp.outputs.staticWebAppName
output AZURE_APPLICATION_INSIGHTS_NAME string = monitoring.outputs.applicationInsightsName
output API_BASE_URL string = containerApps.outputs.apiContainerAppUrl
output WEB_APP_URL string = containerApps.outputs.webAppContainerAppUrl
output AZURE_CONTAINER_APPS_ENVIRONMENT_NAME string = containerApps.outputs.containerAppsEnvironmentName
output AZURE_LOG_ANALYTICS_WORKSPACE_NAME string = monitoring.outputs.logAnalyticsWorkspaceName

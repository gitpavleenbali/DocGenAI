@description('Environment name')
param environmentName string

@description('Location for resources')
param location string

@description('Resource token for unique naming')
param resourceToken string

@description('Tags for resources')
param tags object

var abbrs = loadJsonContent('../abbreviations.json')

// User Assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${abbrs.managedIdentityUserAssignedIdentities}${environmentName}-${resourceToken}'
  location: location
  tags: tags
}

// Azure OpenAI Account
resource openAiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: '${abbrs.cognitiveServicesAccounts}openai-${resourceToken}'
  location: location
  tags: tags
  kind: 'OpenAI'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: '${abbrs.cognitiveServicesAccounts}openai-${resourceToken}'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
  }
}

// Azure ML Workspace (AI Hub) - Simplified for workshop
// resource aiHubWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
//   name: '${abbrs.machineLearningServicesWorkspaces}aihub-${resourceToken}'
//   location: location
//   tags: tags
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     friendlyName: 'DocGenAI Hub'
//     description: 'AI Hub for DocGenAI PDF document analysis solution'
//     
//     // Required associated services - will be created in other modules
//     storageAccount: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Storage/storageAccounts/${abbrs.storageStorageAccounts}${resourceToken}'
//     keyVault: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.KeyVault/vaults/${abbrs.keyVaultVaults}${resourceToken}'
//     applicationInsights: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Insights/components/${abbrs.insightsComponents}${resourceToken}'
//     
//     // Hub-specific configuration
//     hubResourceId: resourceId('Microsoft.MachineLearningServices/workspaces', '${abbrs.machineLearningServicesWorkspaces}aihub-${resourceToken}')
//     
//     publicNetworkAccess: 'Enabled'
//     managedNetwork: {
//       isolationMode: 'AllowInternetOutbound'
//     }
//   }
// }

// AI Project (Child workspace) - Simplified for workshop  
// resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
//   name: '${abbrs.machineLearningServicesWorkspaces}aiproject-${resourceToken}'
//   location: location
//   tags: tags
//   identity: {
//     type: 'SystemAssigned'
//   }
//   properties: {
//     friendlyName: 'DocGenAI Project'
//     description: 'AI Project for PDF document analysis and chat'
//     
//     // Link to parent hub
//     hubResourceId: aiHubWorkspace.id
//     
//     // Inherit configuration from hub
//     storageAccount: aiHubWorkspace.properties.storageAccount
//     keyVault: aiHubWorkspace.properties.keyVault
//     applicationInsights: aiHubWorkspace.properties.applicationInsights
//     
//     publicNetworkAccess: 'Enabled'
//   }
// }

// Model deployments for the OpenAI account
resource gpt4oMiniDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openAiAccount
  name: 'gpt-4o-mini'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'gpt-4o-mini'
      version: '2024-07-18'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  sku: {
    name: 'GlobalStandard'
    capacity: 1000
  }
}

resource embeddingDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = {
  parent: openAiAccount
  name: 'text-embedding-3-small'
  properties: {
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
    raiPolicyName: 'Microsoft.DefaultV2'
  }
  sku: {
    name: 'Standard'
    capacity: 100
  }
  dependsOn: [
    gpt4oMiniDeployment
  ]
}

// Role assignments for the user-assigned identity - Simplified for workshop
resource openAiCognitiveServicesUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: openAiAccount
  name: guid(openAiAccount.id, userAssignedIdentity.id, '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd') // Cognitive Services OpenAI User
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// AI Hub role assignments commented out for workshop simplicity
// resource aiHubContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   scope: aiHubWorkspace
//   name: guid(aiHubWorkspace.id, userAssignedIdentity.id, 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121') // AzureML Data Scientist
//     principalId: userAssignedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// resource aiProjectContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   scope: aiProject
//   name: guid(aiProject.id, userAssignedIdentity.id, 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
//   properties: {
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121') // AzureML Data Scientist
//     principalId: userAssignedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }

// Outputs
output openAiAccountName string = openAiAccount.name
output openAiAccountEndpoint string = openAiAccount.properties.endpoint
// AI Hub and Project outputs commented out for workshop simplicity
// output aiHubName string = aiHubWorkspace.name
// output aiProjectName string = aiProject.name
// output aiHubId string = aiHubWorkspace.id
// output aiProjectId string = aiProject.id
output userAssignedIdentityId string = userAssignedIdentity.id
output principalId string = userAssignedIdentity.properties.principalId

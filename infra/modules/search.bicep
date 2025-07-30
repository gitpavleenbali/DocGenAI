@description('Environment name')
param environmentName string

@description('Location for all resources')
param location string = resourceGroup().location

@description('Resource token for unique naming')
param resourceToken string

@description('Tags to apply to all resources')
param tags object = {}

@description('Principal ID of the user-assigned managed identity')
param principalId string

// Import abbreviations
var abbrs = loadJsonContent('../abbreviations.json')

// Azure AI Search service
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: '${abbrs.searchSearchServices}${environmentName}-${resourceToken}'
  location: location
  tags: tags
  sku: {
    name: 'basic'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    publicNetworkAccess: 'enabled'
    semanticSearch: 'free'
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    disableLocalAuth: false
    encryptionWithCmk: {
      enforcement: 'Unspecified'
    }
    networkRuleSet: {
      ipRules: []
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// Role assignment for Search Index Data Contributor
resource searchIndexDataContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, principalId, 'Search Index Data Contributor')
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8ebe5a00-799e-43f5-93ac-243d3dce84a7')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment for Search Service Contributor
resource searchServiceContributorRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, principalId, 'Search Service Contributor')
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7ca78c08-252a-4471-8644-bb5ff32d4ba0')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment for Search Index Data Reader
resource searchIndexDataReaderRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(searchService.id, principalId, 'Search Index Data Reader')
  scope: searchService
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1407120a-92aa-4202-b7e9-c0e197c71c8f')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
@description('Search service name')
output searchServiceName string = searchService.name

@description('Search service endpoint')
output searchServiceEndpoint string = 'https://${searchService.name}.search.windows.net'

@description('Search service admin key secret name')
output adminKeySecretName string = 'AZURE_SEARCH_ADMIN_KEY'

@description('Search service query key secret name')
output queryKeySecretName string = 'AZURE_SEARCH_QUERY_KEY'

@description('Search service resource ID')
output searchServiceId string = searchService.id

@description('Search service principal ID')
output principalId string = searchService.identity.principalId

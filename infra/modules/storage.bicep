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

// Storage account for documents and embeddings
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: take('${abbrs.storageStorageAccounts}${environmentName}${resourceToken}000', 24)
  location: location
  tags: tags
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    allowCrossTenantReplication: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Account'
        }
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
  }
}

// Blob services configuration
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Container for uploaded documents
resource documentsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'documents'
  properties: {
    publicAccess: 'None'
    metadata: {
      description: 'Container for uploaded documents'
    }
  }
}

// Container for processed embeddings
resource embeddingsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'embeddings'
  properties: {
    publicAccess: 'None'
    metadata: {
      description: 'Container for processed document embeddings'
    }
  }
}

// Container for application logs and metadata
resource logsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobServices
  name: 'logs'
  properties: {
    publicAccess: 'None'
    metadata: {
      description: 'Container for application logs and metadata'
    }
  }
}

// Role assignment for Storage Blob Data Contributor
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, 'Storage Blob Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment for Storage Queue Data Contributor
resource storageQueueRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, 'Storage Queue Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '974c5e8b-45b9-4653-ba55-5f855dd0fb88')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Role assignment for Storage Table Data Contributor
resource storageTableRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.id, principalId, 'Storage Table Data Contributor')
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Queue services configuration
resource queueServices 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {}
}

// Queue for document processing tasks
resource processingQueue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
  parent: queueServices
  name: 'document-processing'
  properties: {
    metadata: {
      description: 'Queue for document processing tasks'
    }
  }
}

// Table services configuration
resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {}
}

// Table for storing document metadata
resource documentsTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  parent: tableServices
  name: 'documents'
  properties: {}
}

// Table for storing conversation history
resource conversationsTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  parent: tableServices
  name: 'conversations'
  properties: {}
}

// Table for storing user sessions
resource sessionsTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  parent: tableServices
  name: 'sessions'
  properties: {}
}

// Outputs
@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Storage account primary endpoints')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('Storage account connection string environment variable')
output connectionStringSecretName string = 'AZURE_STORAGE_CONNECTION_STRING'

@description('Storage account blob endpoint')
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('Storage account queue endpoint')  
output queueEndpoint string = storageAccount.properties.primaryEndpoints.queue

@description('Storage account table endpoint')
output tableEndpoint string = storageAccount.properties.primaryEndpoints.table

@description('Documents container name')
output documentsContainerName string = documentsContainer.name

@description('Embeddings container name')
output embeddingsContainerName string = embeddingsContainer.name

@description('Logs container name')
output logsContainerName string = logsContainer.name

@description('Processing queue name')
output processingQueueName string = processingQueue.name

@description('Documents table name')
output documentsTableName string = documentsTable.name

@description('Conversations table name')
output conversationsTableName string = conversationsTable.name

@description('Sessions table name')
output sessionsTableName string = sessionsTable.name

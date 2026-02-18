@description('The name of the AI Hub')
param name string

@description('The location of the AI Hub')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('The resource ID of the Log Analytics workspace')
param logAnalyticsWorkspaceId string

// Storage account for AI Hub
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'st${uniqueString(resourceGroup().id, name)}'
  location: location
  tags: tags
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}

// Key Vault for AI Hub
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-${uniqueString(resourceGroup().id, name)}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
  }
}

// AI Hub (Azure AI Services)
resource aiHub 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    storageAccount: storageAccount.id
    keyVault: keyVault.id
    applicationInsights: logAnalyticsWorkspaceId
    publicNetworkAccess: 'Enabled'
  }
  kind: 'Hub'
}

output id string = aiHub.id
output name string = aiHub.name

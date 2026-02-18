@description('The name of the AI Project')
param name string

@description('The location of the AI Project')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('The resource ID of the AI Hub')
param aiHubId string

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2024-04-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: name
    hubResourceId: aiHubId
    publicNetworkAccess: 'Enabled'
  }
  kind: 'Project'
}

output id string = aiProject.id
output name string = aiProject.name

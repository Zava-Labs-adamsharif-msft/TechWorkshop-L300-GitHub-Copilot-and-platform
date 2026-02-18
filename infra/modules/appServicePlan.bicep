@description('The name of the App Service Plan')
param name string

@description('The location of the App Service Plan')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('The SKU of the App Service Plan')
param sku object = {
  name: 'B1'
  tier: 'Basic'
}

@description('The kind of App Service Plan (linux or windows)')
param kind string = 'linux'

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  kind: kind
  properties: {
    reserved: true // Required for Linux
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name

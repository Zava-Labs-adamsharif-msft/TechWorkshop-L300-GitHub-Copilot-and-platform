@description('The name of the App Service')
param name string

@description('The location of the App Service')
param location string = resourceGroup().location

@description('Tags for the resource')
param tags object = {}

@description('The resource ID of the App Service Plan')
param appServicePlanId string

@description('The Application Insights connection string')
param appInsightsConnectionString string

@description('The Application Insights instrumentation key')
param appInsightsInstrumentationKey string

@description('The name of the Azure Container Registry')
param containerRegistryName string

@description('The Docker image name to deploy')
param imageName string

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: name
  location: location
  tags: tags
  kind: 'app,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${imageName}'
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'DOCKER_REGISTRY_SERVER_URL'
          value: 'https://${containerRegistryName}.azurecr.io'
        }
        {
          name: 'DOCKER_ENABLE_CI'
          value: 'true'
        }
        {
          name: 'WEBSITES_ENABLE_APP_SERVICE_STORAGE'
          value: 'false'
        }
      ]
      acrUseManagedIdentityCreds: true
    }
  }
}

output id string = appService.id
output name string = appService.name
output uri string = 'https://${appService.properties.defaultHostName}'
output systemAssignedIdentityPrincipalId string = appService.identity.principalId

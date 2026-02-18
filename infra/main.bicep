targetScope = 'resourceGroup'

@minLength(1)
@maxLength(64)
@description('Name of the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
@allowed([
  'westus3'
])
param location string = 'westus3'

@description('The image name for the container')
param imageName string = ''

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = {
  'azd-env-name': environmentName
}

// Log Analytics Workspace
module logAnalytics './modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  params: {
    name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
    tags: tags
  }
}

// Application Insights
module appInsights './modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    name: '${abbrs.insightsComponents}${resourceToken}'
    location: location
    tags: tags
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

// Azure Container Registry
module containerRegistry './modules/acr.bicep' = {
  name: 'containerRegistry'
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    location: location
    tags: tags
  }
}

// App Service Plan
module appServicePlan './modules/appServicePlan.bicep' = {
  name: 'appServicePlan'
  params: {
    name: '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: 'B1'
      tier: 'Basic'
    }
    kind: 'linux'
  }
}

// App Service (Web App for Containers)
module appService './modules/appService.bicep' = {
  name: 'appService'
  params: {
    name: '${abbrs.webSitesAppService}${resourceToken}'
    location: location
    tags: tags
    appServicePlanId: appServicePlan.outputs.id
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
    containerRegistryName: containerRegistry.outputs.name
    imageName: !empty(imageName) ? imageName : 'nginx:latest'
  }
}

// Role Assignment: Grant App Service AcrPull access to Container Registry
module acrPullRoleAssignment './modules/acrPullRoleAssignment.bicep' = {
  name: 'acrPullRoleAssignment'
  params: {
    containerRegistryName: containerRegistry.outputs.name
    principalId: appService.outputs.systemAssignedIdentityPrincipalId
  }
}

// Microsoft Foundry (AI Hub and AI Project)
module aiHub './modules/aiHub.bicep' = {
  name: 'aiHub'
  params: {
    name: '${abbrs.cognitiveServicesAccounts}hub-${resourceToken}'
    location: location
    tags: tags
    applicationInsightsId: appInsights.outputs.id
  }
}

module aiProject './modules/aiProject.bicep' = {
  name: 'aiProject'
  params: {
    name: '${abbrs.cognitiveServicesAccounts}proj-${resourceToken}'
    location: location
    tags: tags
    aiHubId: aiHub.outputs.id
  }
}

// Outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerRegistry.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerRegistry.outputs.name
output APPLICATIONINSIGHTS_CONNECTION_STRING string = appInsights.outputs.connectionString
output AZURE_LOCATION string = location
output WEBAPP_NAME string = appService.outputs.name
output WEBAPP_URI string = appService.outputs.uri
output AI_HUB_NAME string = aiHub.outputs.name
output AI_PROJECT_NAME string = aiProject.outputs.name

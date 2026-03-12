targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment (e.g., dev, staging, prod)')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string = 'westus3'

@description('Name of the resource group')
param resourceGroupName string = ''

@description('Name of the Azure Container Registry')
param acrName string = ''

@description('Name of the App Service Plan')
param appServicePlanName string = ''

@description('Name of the Web App')
param webAppName string = ''

@description('Name of the Log Analytics workspace')
param logAnalyticsName string = ''

@description('Name of the Application Insights instance')
param appInsightsName string = ''

@description('Name of the AI Foundry resource')
param aiFoundryName string = ''

@description('ACR SKU')
param acrSku string = 'Basic'

@description('App Service Plan SKU')
param appServicePlanSku string = 'B1'

@description('Docker image name and tag')
param dockerImageName string = 'zava-storefront:latest'

var abbrs = {
  resourceGroup: 'rg-'
  containerRegistry: 'acr'
  appServicePlan: 'plan-'
  webApp: 'app-'
  logAnalytics: 'log-'
  appInsights: 'appi-'
  aiFoundry: 'aif-'
}

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

var rgName = !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourceGroup}${environmentName}-${resourceToken}'
var acrResourceName = !empty(acrName) ? acrName : '${abbrs.containerRegistry}${resourceToken}'
var planName = !empty(appServicePlanName) ? appServicePlanName : '${abbrs.appServicePlan}${environmentName}-${resourceToken}'
var appName = !empty(webAppName) ? webAppName : '${abbrs.webApp}${environmentName}-${resourceToken}'
var logName = !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.logAnalytics}${environmentName}-${resourceToken}'
var insightsName = !empty(appInsightsName) ? appInsightsName : '${abbrs.appInsights}${environmentName}-${resourceToken}'
var aiName = !empty(aiFoundryName) ? aiFoundryName : '${abbrs.aiFoundry}${environmentName}-${resourceToken}'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}

module logAnalytics 'modules/logAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rg
  params: {
    name: logName
    location: location
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  scope: rg
  params: {
    name: insightsName
    location: location
    logAnalyticsWorkspaceId: logAnalytics.outputs.id
  }
}

module acr 'modules/acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    name: acrResourceName
    location: location
    sku: acrSku
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  scope: rg
  params: {
    planName: planName
    appName: appName
    location: location
    planSku: appServicePlanSku
    appInsightsConnectionString: appInsights.outputs.connectionString
    appInsightsInstrumentationKey: appInsights.outputs.instrumentationKey
  }
}

module acrPullRole 'modules/acrRoleAssignment.bicep' = {
  name: 'acrPullRole'
  scope: rg
  params: {
    acrName: acr.outputs.name
    principalId: appService.outputs.identityPrincipalId
  }
}

module aiFoundry 'modules/aiFoundry.bicep' = {
  name: 'aiFoundry'
  scope: rg
  params: {
    name: aiName
    location: location
  }
}

output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_ACR_NAME string = acr.outputs.name
output AZURE_ACR_LOGIN_SERVER string = acr.outputs.loginServer
output AZURE_APP_SERVICE_NAME string = appService.outputs.name
output AZURE_APP_SERVICE_URL string = appService.outputs.url
output AZURE_APP_INSIGHTS_NAME string = appInsights.outputs.name
output AZURE_AI_FOUNDRY_NAME string = aiFoundry.outputs.name

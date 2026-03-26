@description('Name of the AI Foundry resource')
param name string

@description('Location for the resource')
param location string

resource aiAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  kind: 'AIServices'
  sku: {
    name: 'S0'
  }
  properties: {
    customSubDomainName: name
    publicNetworkAccess: 'Enabled'
  }
}

output id string = aiAccount.id
output name string = aiAccount.name
output endpoint string = aiAccount.properties.endpoint

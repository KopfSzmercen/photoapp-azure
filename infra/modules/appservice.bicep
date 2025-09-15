param prefix string
param env string
param location string
param identityId string
param apiAlwaysOn bool

var planName = '${prefix}-${env}-plan'
var appName = '${prefix}-${env}-api'

resource plan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: planName
  location: location
  sku: {
    name: 'F1'
    tier: 'Free'
    size: 'F1'
    capacity: 1
  }
  properties: {
    reserved: true
  }
  kind: 'linux'
}

resource app 'Microsoft.Web/sites@2024-11-01' = {
  name: appName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|9.0'
      alwaysOn: apiAlwaysOn
    }
  }
}

output name string = app.name
output defaultHostName string = app.properties.defaultHostName

param prefix string
param env string
param location string

var resourceGroupId = resourceGroup().id
var vaultName = '${prefix}-${env}-kv-${take(uniqueString(resourceGroupId), 5)}'

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: vaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    accessPolicies: []
  }
}

output name string = kv.name
output id string = kv.id
output uri string = kv.properties.vaultUri

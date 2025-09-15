param principalId string
param storageId string
param kvId string
param cosmosId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageId
}

resource kv 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: kvId
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' existing = {
  name: cosmosId
}

resource storageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageId, principalId, 'StorageBlobDataContributor')
  scope: storageAccount
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  }
}


resource kvRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kvId, principalId, 'KeyVaultSecretsUser')
  scope: kv
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')
  }
}


resource cosmosRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(cosmosId, principalId, 'CosmosDBDataContributor')
  scope: cosmos
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  }
}

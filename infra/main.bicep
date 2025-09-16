targetScope = 'resourceGroup'

param location string = resourceGroup().location
param env string = 'dev'
param prefix string = 'photoapp'
param apiAlwaysOn bool = false
param databaseName string

module storage './modules/storage.bicep' = {
  name: 'storage'
  params: {
    prefix: prefix
    location: location
    env: env
  }
}

module cosmos './modules/cosmosdb.bicep' = {
  name: 'cosmos'
  params: {
    prefix: prefix
    location: location
    env: env
    databaseName: databaseName
  }
}

module kv './modules/keyvault.bicep' = {
  name: 'keyvault'
  params: {
    prefix: prefix
    location: location
    env: env
  }
}

module id './modules/identity.bicep' = {
  name: 'identity'
  params: {
    prefix: prefix
    location: location
    env: env
  }
}

module appsvc './modules/appservice.bicep' = {
  name: 'appservice'
  params: {
    prefix: prefix
    location: location
    env: env
    identityId: id.outputs.identityId
    apiAlwaysOn: apiAlwaysOn
  }
}

module func './modules/functionapp.bicep' = {
  name: 'function'
  params: {
    prefix: prefix
    location: location
    env: env
    identityId: id.outputs.identityId
    storageAccountName: storage.outputs.name
    identityClientId: id.outputs.identityClientId
  }
}

module roleAssignments './modules/roleassignments.bicep' = {
  name: 'roleAssignments'
  params: {
    principalId: id.outputs.identityClientId
    storageId: storage.outputs.name
    kvId: kv.outputs.name
    cosmosId: cosmos.outputs.name
    databaseName: databaseName
    identityPrincipalId: id.outputs.identiyPrincipalId
  }
}

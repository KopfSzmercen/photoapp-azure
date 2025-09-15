param prefix string
param env string
param location string
param identityId string
param storageAccountName string
param identityClientId string

param resourceToken string = toLower(uniqueString(subscription().id, location))
param appName string = 'func-${resourceToken}'

var deploymentStorageContainerName = 'function-releases-${take(appName, 32)}-${take(resourceToken, 7)}'

var functionName = '${prefix}-${env}-func'
var planName = '${prefix}-${env}-funcplan'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storageAccount.name}/default/${deploymentStorageContainerName}'
  properties: {
    publicAccess: 'None'
  }
  dependsOn: [
    storageAccount
  ]
}

resource plan 'Microsoft.Web/serverfarms@2024-11-01' = {
  name: planName
  location: location
  sku: {
    tier: 'FlexConsumption'
    name: 'FC1'
  }
  kind: 'functionapp'
  properties: {
    reserved: true
  }
}


resource function 'Microsoft.Web/sites@2024-11-01' = {
  name: functionName
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    serverFarmId: plan.id
    httpsOnly: true 
    functionAppConfig: {
      scaleAndConcurrency: {
        maximumInstanceCount: 40
        instanceMemoryMB: 512
      }
      runtime: {
        name: 'dotnet-isolated'
        version: '9.0'
      }
      deployment: {
        storage: {
          type: 'blobContainer'
          value: '${storageAccount.properties.primaryEndpoints.blob}${deploymentStorageContainerName}'
          authentication: {
            type: 'UserAssignedIdentity'
            userAssignedIdentityResourceId: identityId
          }
        }
      }
    }
  }
  resource configAppSettings 'config' = {
    name: 'appsettings'
    properties: {
      AzureWebJobsStorage__accountName: storageAccountName
      AzureWebJobsStorage__credential: 'managedIdentity'
      AzureWebJobsStorage__clientId: identityClientId
      WEBSITE_RUN_FROM_PACKAGE: '1'
    }
  }
}

output name string = function.name
output defaultHostName string = function.properties.defaultHostName

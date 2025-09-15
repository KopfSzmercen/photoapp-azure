param prefix string
param env string
param location string

var storageName = toLower('${prefix}${env}storage')

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

resource originals 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/originals'
  properties: {
    publicAccess: 'None'
  }
}

resource processed 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = {
  name: '${storage.name}/default/processed'
  properties: {
    publicAccess: 'None'
  }
}

output name string = storage.name
output id string = storage.id

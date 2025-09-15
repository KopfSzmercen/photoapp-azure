param prefix string
param env string
param location string

var accountName = toLower('${prefix}${env}cosmos')

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
      }
    ]
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-04-15' = {
  parent: cosmos
  name: 'photoapp'
  properties: {
    resource: {
      id: 'photoapp'
    }
  }
}

resource users 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: database
  name: 'users'
  properties: {
    resource: {
      id: 'users'
      partitionKey: {
        paths: ['/userId']
        kind: 'Hash'
      }
    }
  }
}

resource files 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-04-15' = {
  parent: database
  name: 'files'
  properties: {
    resource: {
      id: 'files'
      partitionKey: {
        paths: ['/userId']
        kind: 'Hash'
      }
    }
  }
}

output name string = cosmos.name
output id string = cosmos.id

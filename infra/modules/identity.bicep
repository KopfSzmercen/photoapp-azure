param prefix string
param env string
param location string

var identityName = '${prefix}-${env}-mi'

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

output identityId string = uami.id
output identityClientId string = uami.properties.clientId
output identiyPrincipalId string = uami.properties.principalId

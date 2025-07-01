param location string = resourceGroup().location
var storageAccount_name = 'sasecure${uniqueString(resourceGroup().id)}'
param saKind string = 'StorageV2'
param saSkuName string = 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccount_name
  location: location
  kind: saKind
  sku: {
    name: saSkuName
  }

  properties: {
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name

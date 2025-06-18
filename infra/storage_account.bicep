param location string = 'australiaeast'
var storageAccount_name = 'saaif${uniqueString(resourceGroup().id)}'



resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccount_name
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }

  properties: {
    publicNetworkAccess: 'Disabled'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true  // Required for Azure ML Hub
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}



output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name

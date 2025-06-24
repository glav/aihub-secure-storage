param location string = 'australiaeast'
var storageAccount_name = 'saaif${uniqueString(resourceGroup().id)}'
param saKind string = 'StorageV2' // Default kind for Azure ML Hub
param saSkuName string = 'Standard_LRS' // Default SKU for Azure ML Hub

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
    allowSharedKeyAccess: true  // Required for Azure ML Hub
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'  // This allows trusted Microsoft services including Azure ML managed VNet
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name

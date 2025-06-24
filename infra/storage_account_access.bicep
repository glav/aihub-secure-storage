param storageAccountName string
param hubResourceId string
param location string
param saKind string = 'StorageV2' // Default kind for Azure ML Hub
param saSkuName string = 'Standard_LRS' // Default SKU for Azure ML Hub

// Update the storage account network access rules to allow Azure ML Hub access
resource storageNetworkRules 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: storageAccountName
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
    networkAcls: {
      bypass: 'AzureServices'  // This allows trusted Microsoft services including Azure ML
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
      resourceAccessRules: [
        {
          tenantId: subscription().tenantId
          resourceId: hubResourceId
        }
      ]
    }
  }
}

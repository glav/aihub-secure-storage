param storageAccountName string
param hubResourceId string
param location string
param saKind string = 'StorageV2' // Default kind for Azure ML Hub
param saSkuName string = 'Standard_LRS' // Default SKU for Azure ML Hub

resource storageAccountAccess 'Microsoft.Storage/storageAccounts@2024-01-01' = {
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
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
      resourceAccessRules: [
        {
          tenantId: subscription().tenantId
          resourceId: hubResourceId
        }
        {
          tenantId: subscription().tenantId
          resourceId: resourceId('Microsoft.Security/datascanners', 'storageDataScanner')
          //resourceId: '/subscriptions/c0652cf3-6d51-4e8d-a5dd-e5805aabb3ef/providers/Microsoft.Security/datascanners/storageDataScanner'
        }
      ]
    }
  }
}

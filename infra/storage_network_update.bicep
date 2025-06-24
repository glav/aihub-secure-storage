param storageAccountName string
param hubResourceId string
param location string
param saKind string = 'StorageV2'
param saSkuName string = 'Standard_LRS'

// Update network ACLs to include resource access rules for the workspace
resource storageNetworkUpdate 'Microsoft.Storage/storageAccounts@2024-01-01' = {
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
      bypass: 'AzureServices'  // Allow trusted Microsoft services
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

output storageAccountId string = storageNetworkUpdate.id

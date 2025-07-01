param location string = resourceGroup().location
param storageAccountId string
param storageAccountName string
param subnetId string
param privateDnsZoneId string

// Private Endpoint for Storage Account
resource storagePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-${storageAccountName}'
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'storage-connection'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            'blob'
          ]
        }
      }
    ]
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = {
  name: 'default'
  parent: storagePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'storage-config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output privateEndpointId string = storagePrivateEndpoint.id
output privateEndpointIp string = storagePrivateEndpoint.properties.customDnsConfigs[0].ipAddresses[0]

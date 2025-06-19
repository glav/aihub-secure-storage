param storageAccountName string
param location string = 'australiaeast'
param hubName string = 'hub-test-network'

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: storageAccountName
}

// Create a Virtual Network for private endpoints
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-${hubName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'private-endpoints'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }

    ]
  }
}

// Storage Account Private Endpoint for Blob
resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pep-${hubName}-blob'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pls-${hubName}-blob'
        properties: {
          privateLinkServiceId: storageaccount.id
          groupIds: [
            'blob'
          ]
        }
      }
    ]
    subnet: {
      id: virtualNetwork.properties.subnets[0].id
    }
  }
}

// Storage Account Private Endpoint for File
resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pep-${hubName}-file'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pls-${hubName}-file'
        properties: {
          privateLinkServiceId: storageaccount.id
          groupIds: [
            'file'
          ]
        }
      }
    ]
    subnet: {
      id: virtualNetwork.properties.subnets[0].id
    }
  }
}

// Create Private DNS Zones for Storage
var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var filePrivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
}

// Link the Private DNS Zones to the Virtual Network
resource blobPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: '${hubName}-blob-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

resource filePrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: filePrivateDnsZone
  name: '${hubName}-file-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

// Create DNS Zone Groups for the Private Endpoints
resource blobPrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: blobPrivateEndpoint
  name: 'dnsgroupblob'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: blobPrivateDnsZone.id
        }
      }
    ]
  }
}

resource filePrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: filePrivateEndpoint
  name: 'dnsgroupfile'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}

// resource pepConnectionResource_1 'Microsoft.Storage/storageAccounts/privateEndpointConnections@2024-01-01' = {
//   parent: storageaccount
//   name: 'pepc_1_${storageaccount.name}'
//   properties: {
//     privateEndpoint: {}
//     privateLinkServiceConnectionState: {
//       status: 'Approved'
//       description: 'Auto-approved by Azure AI managed network for workspace: hub-junk'
//       actionRequired: 'None'
//     }
//   }
// }

// resource pepConnectionResource_2 'Microsoft.Storage/storageAccounts/privateEndpointConnections@2024-01-01' = {
//   parent: storageaccount
//   name: 'pepc_2_${storageaccount.name}'
//   properties: {
//     privateEndpoint: {

//     }
//     privateLinkServiceConnectionState: {
//       status: 'Approved'
//       description: 'Auto-approved by Azure AI managed network for workspace: hub-junk'
//       actionRequired: 'None'
//     }
//   }
// }

// output privateEndpointConnection1 string = pepConnectionResource_1.id
// output privateEndpointConnection2 string = pepConnectionResource_2.id
output vnetId string = virtualNetwork.id
output blobPrivateEndpointId string = blobPrivateEndpoint.id
output filePrivateEndpointId string = filePrivateEndpoint.id
output blobPrivateDnsZoneName string = blobPrivateDnsZoneName
output filePrivateDnsZoneName string = filePrivateDnsZoneName


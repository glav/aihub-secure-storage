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

resource hubPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = {
  name: 'pep-${hubName}-aihub'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: 'pls-${hubName}-aihub'
        properties: {
          privateLinkServiceId: resourceId('Microsoft.MachineLearningServices/workspaces', hubName)
          groupIds: [
            'amlworkspace'
          ]
        }
      }
    ]
    subnet: {
      id: virtualNetwork.properties.subnets[1].id
    }
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
      id: virtualNetwork.properties.subnets[1].id
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
      id: virtualNetwork.properties.subnets[1].id
    }
  }
}

// Create Private DNS Zones for Storage
var blobPrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var filePrivateDnsZoneName = 'privatelink.file.${environment().suffixes.storage}'
var mlPrivateDnsZoneName = 'privatelink.api.azureml.ms'

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobPrivateDnsZoneName
  location: 'global'
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: filePrivateDnsZoneName
  location: 'global'
}

resource mlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: mlPrivateDnsZoneName
  location: 'global'
}

resource mlPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: mlPrivateDnsZone
  name: '${hubName}-azureml-link'
  location: 'global'
  properties: {
    registrationEnabled: true
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
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

resource mlPrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: hubPrivateEndpoint
  name: 'dnsgroupaihub'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: mlPrivateDnsZoneVnetLink.name
        properties: {
          privateDnsZoneId: mlPrivateDnsZone.id
        }
      }
    ]
  }
}

// Create DNS Zone Groups for the Private Endpoints
resource blobPrivateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-05-01' = {
  parent: blobPrivateEndpoint
  name: 'dnsgroupblob'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: blobPrivateDnsZoneVnetLink.name
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
        name: filePrivateDnsZoneVnetLink.name
        properties: {
          privateDnsZoneId: filePrivateDnsZone.id
        }
      }
    ]
  }
}

output vnetId string = virtualNetwork.id
output blobPrivateEndpointId string = blobPrivateEndpoint.id
output filePrivateEndpointId string = filePrivateEndpoint.id
output blobPrivateDnsZoneName string = blobPrivateDnsZoneName
output filePrivateDnsZoneName string = filePrivateDnsZoneName


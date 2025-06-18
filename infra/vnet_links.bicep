param hubName string
param blobPrivateDnsZoneName string
param filePrivateDnsZoneName string
param managedVnetId string

//var managedVnetId = resourceId('Microsoft.MachineLearningServices/workspaces/managedVirtualNetworks', hubName, 'default')

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: blobPrivateDnsZoneName
}

resource filePrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: filePrivateDnsZoneName
}

resource blobPrivateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: '${hubName}-blob-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: managedVnetId
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
      id: managedVnetId
    }
  }
}

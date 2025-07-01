param vnetId string

// Private DNS Zone for Storage Account
resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${environment().suffixes.storage}'
  location: 'global'
}

// Link Private DNS Zone to VNet
resource privateDnsZoneVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'storage-dns-link'
  parent: privateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

output privateDnsZoneId string = privateDnsZone.id
output privateDnsZoneName string = privateDnsZone.name

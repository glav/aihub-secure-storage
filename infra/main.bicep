module storage 'storage_account.bicep' = {
  name: 'storage'
  params: {
    location: resourceGroup().location
  }
}

module networking 'storage_networking.bicep' = {
  name: 'networking'
  params: {
    location: resourceGroup().location
    storageAccountId: storage.outputs.storageAccountId
  }
}

module hub 'hub.bicep' = {
  name: 'hub'
  params: {
    location: resourceGroup().location
    storageAccountId: storage.outputs.storageAccountId
  }
}

module storage_access 'storage_account_access.bicep' = {
  name: 'storage_access'
  params: {
    hubResourceId: hub.outputs.hubId
    storageAccountName: storage.outputs.storageAccountName
    location: resourceGroup().location
  }
}

module vnet_links 'vnet_links.bicep' = {
  name: 'vnet_links'
  params: {
    hubName: hub.outputs.hubName
    blobPrivateDnsZoneName: networking.outputs.blobPrivateDnsZoneName
    filePrivateDnsZoneName: networking.outputs.filePrivateDnsZoneName
    managedVnetId: hub.outputs.managedNetworkId
  }
}

output vnetId string = networking.outputs.vnetId
output hubManagedVnetId string = hub.outputs.managedNetworkId
output blobPrivateEndpointId string = networking.outputs.blobPrivateEndpointId
output filePrivateEndpointId string = networking.outputs.filePrivateEndpointId

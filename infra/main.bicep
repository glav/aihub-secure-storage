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
    blobPrivateDnsZoneName: networking.outputs.blobPrivateDnsZoneName
    filePrivateDnsZoneName: networking.outputs.filePrivateDnsZoneName
  }
  dependsOn: [
    networking
  ]
}

module storage_access 'storage_account_access.bicep' = {
  name: 'storage_access'
  params: {
    hubResourceId: hub.outputs.hubId
    storageAccountName: storage.outputs.storageAccountName
    location: resourceGroup().location
  }
}

output managedNetworkId string = hub.outputs.managedNetworkId
output vnetId string = networking.outputs.vnetId
output blobPrivateEndpointId string = networking.outputs.blobPrivateEndpointId
output filePrivateEndpointId string = networking.outputs.filePrivateEndpointId

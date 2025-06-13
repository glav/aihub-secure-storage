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
    workspaces_hub_test_network_name: 'hub-test-network'
  }
}

module hub 'hub.bicep' = {
  name: 'hub'
  params: {
    location: resourceGroup().location
    storageAccountId: storage.outputs.storageAccountId
  }
  dependsOn: [
    networking
  ]
}

output managedNetworkId string = hub.outputs.managedNetworkId
output vnetId string = networking.outputs.vnetId
output blobPrivateEndpointId string = networking.outputs.blobPrivateEndpointId
output filePrivateEndpointId string = networking.outputs.filePrivateEndpointId

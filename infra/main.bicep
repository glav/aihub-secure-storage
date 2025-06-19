param saKind string = 'StorageV2' // Default kind for Azure ML Hub
param saSkuName string = 'Standard_LRS' // Default SKU for Azure ML Hub

module storage 'storage_account.bicep' = {
  name: 'storage'
  params: {
    location: resourceGroup().location
    saKind: saKind
    saSkuName: saSkuName
  }
}

module networking 'storage_networking.bicep' = {
  name: 'networking'
  params: {
    storageAccountName: storage.outputs.storageAccountName
    hubName: hub.outputs.hubName
    location: resourceGroup().location
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
    saKind: saKind
    saSkuName: saSkuName
  }
}


output hubManagedVnetId string = hub.outputs.managedNetworkId

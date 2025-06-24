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

module hub 'hub.bicep' = {
  name: 'hub'
  params: {
    location: resourceGroup().location
    storageAccountId: storage.outputs.storageAccountId
  }
}

// Grant workspace managed identity the Azure AI Enterprise Network Connection Approver role
// This is required for private endpoint connections to activate (new requirement after April 30, 2025)
module workspacePermissions 'workspace_permissions.bicep' = {
  name: 'workspace-permissions'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    hubPrincipalId: hub.outputs.hubPrincipalId
    projectPrincipalId: hub.outputs.projectPrincipalId
  }
}

// Update storage network rules after hub creation and permissions are granted
module storageNetworkUpdate 'storage_network_update.bicep' = {
  name: 'storage-network-update'
  params: {
    storageAccountName: storage.outputs.storageAccountName
    hubResourceId: hub.outputs.hubId
    location: resourceGroup().location
    saKind: saKind
    saSkuName: saSkuName
  }
  dependsOn: [
    workspacePermissions
  ]
}

// Note: After deployment, manually provision the managed VNet to activate private endpoints:
// az ml workspace provision-network -g <resource-group> -n <workspace-name>

//output managedVnetId string = networking.outputs.managedVnetId

param saKind string = 'StorageV2' // Default kind for Azure ML Hub
param saSkuName string = 'Standard_LRS' // Default SKU for Azure ML Hub

// Create a storage account for the AI Hub
module storage 'storage_account.bicep' = {
  name: 'storage'
  params: {
    location: resourceGroup().location
    saKind: saKind
    saSkuName: saSkuName
  }
}

// Create the AI Hub, project and keyvault
module hub 'hub.bicep' = {
  name: 'hub'
  params: {
    location: resourceGroup().location
    storageAccountId: storage.outputs.storageAccountId
  }
}

// Grant storage data contributor, Storage File Data Contributor role, and Reader role at storage account scope permissions to the AI hub
module hubStorageBlobDataContributorRole 'storage_acct_permissions.bicep' = {
  name: 'hub-storage-blob-data-contributor-role'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    principalId: hub.outputs.hubPrincipalId
  }
}

// Grant storage data contributor, Storage File Data Contributor role, and Reader role at storage account scope permissions to the AI hub project
module projectStorageBlobDataContributorRole 'storage_acct_permissions.bicep' = {
  name: 'project-storage-blob-data-contributor-role'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    principalId: hub.outputs.projectPrincipalId
  }
}

// Grant the AI Hub managed identity the Azure AI Enterprise Network Connection Approver role
module hubNetworkApproverRole 'netwwork_approver_acct_permissions.bicep' = {
  name: 'hub-network-approver-role'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    principalId: hub.outputs.hubPrincipalId
  }
}

// Grant the AI Hub project managed identity the Azure AI Enterprise Network Connection Approver role
module projectNetworkApproverRole 'netwwork_approver_acct_permissions.bicep' = {
  name: 'project-network-approver-role'
  params: {
    storageAccountId: storage.outputs.storageAccountId
    principalId: hub.outputs.projectPrincipalId
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
}

// Note: After deployment, manually provision the managed VNet to activate private endpoints:
// az ml workspace provision-network -g <resource-group> -n <workspace-name>

//output managedVnetId string = networking.outputs.managedVnetId

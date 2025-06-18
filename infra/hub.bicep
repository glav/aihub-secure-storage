param hubName string = 'hub-test-network'
param location string = 'australiaeast'
param storageAccountId string

var tenantId = subscription().tenantId

// Role definitions
var role_defn_storage_blob_data_contrib = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // Storage Blob Data Contributor
var role_defn_storage_file_data_contrib = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb' // Storage File Data SMB Share Contributor
var role_defn_reader = 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader role

// Storage role assignments for AI Hub
resource hubStorageBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub.id, role_defn_storage_blob_data_contrib)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_storage_blob_data_contrib)
    principalId: ai_hub.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource hubStorageFileRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub.id, role_defn_storage_file_data_contrib)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_storage_file_data_contrib)
    principalId: ai_hub.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage role assignments for AI Project
resource projectStorageBlobRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub_project.id, role_defn_storage_blob_data_contrib)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_storage_blob_data_contrib)
    principalId: ai_hub_project.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource projectStorageFileRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub_project.id, role_defn_storage_file_data_contrib)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_storage_file_data_contrib)
    principalId: ai_hub_project.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Storage Reader role assignments (required for private endpoint access)
resource hubStorageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub.id, role_defn_reader)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_reader)
    principalId: ai_hub.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource projectStorageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, ai_hub_project.id, role_defn_reader)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', role_defn_reader)
    principalId: ai_hub_project.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource ai_hub 'Microsoft.MachineLearningServices/workspaces@2025-01-01-preview' = {
  name: hubName
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Hub'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'Hub test network'
    storageAccount: storageAccountId
    keyVault: keyVault.id
    hbiWorkspace: false
    managedNetwork: {
      isolationMode: 'AllowOnlyApprovedOutbound'
      status: {
        status: 'Active'
        sparkReady: false
      }
    }
    v1LegacyMode: false
    publicNetworkAccess: 'Enabled'
    enableDataIsolation: true
  }
}

resource ai_hub_project 'Microsoft.MachineLearningServices/workspaces@2025-01-01-preview' = {
  name: 'proj-${hubName}'
  location: location
  sku: {
    name: 'Basic'
    tier: 'Basic'
  }
  kind: 'Project'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    friendlyName: 'AI Project for ${hubName}'
    hubResourceId: ai_hub.id
    publicNetworkAccess: 'Enabled'
  }
}



resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kvaif${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
  }
}

output managedNetworkId string = ai_hub.properties.managedNetwork.networkId
output hubName string = ai_hub.name
output hubId string = ai_hub.id
output keyVaultId string = keyVault.id

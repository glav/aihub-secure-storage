param hubName string = 'hub-test-network'
param location string = 'australiaeast'
param storageAccountId string

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
    allowPublicAccessWhenBehindVnet: true
    managedNetwork: {
      isolationMode: 'AllowOnlyApprovedOutbound'
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
    tenantId: subscription().tenantId
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


output hubName string = ai_hub.name
output hubId string = ai_hub.id
output hubPrincipalId string = ai_hub.identity.principalId
output projectPrincipalId string = ai_hub_project.identity.principalId
output keyVaultId string = keyVault.id

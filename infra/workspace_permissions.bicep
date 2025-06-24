param storageAccountId string
param hubPrincipalId string
param projectPrincipalId string

// Role definition IDs for storage access
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageFileDataContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var azureAIEnterpriseNetworkConnectionApproverRoleId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

// Reference the existing storage account for scoping role assignments
resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: last(split(storageAccountId, '/'))
}

// HUB IDENTITY ROLE ASSIGNMENTS (at storage account scope)
// Grant Storage Blob Data Contributor role at storage account scope
resource hubStorageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, hubPrincipalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: hubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Storage File Data Contributor role at storage account scope
resource hubStorageFileDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, hubPrincipalId, storageFileDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageFileDataContributorRoleId)
    principalId: hubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Reader role at storage account scope
resource hubStorageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, hubPrincipalId, readerRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
    principalId: hubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// PROJECT IDENTITY ROLE ASSIGNMENTS (at storage account scope)
// Grant Storage Blob Data Contributor role at storage account scope
resource projectStorageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, projectPrincipalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Storage File Data Contributor role at storage account scope
resource projectStorageFileDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, projectPrincipalId, storageFileDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageFileDataContributorRoleId)
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Reader role at storage account scope
resource projectStorageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, projectPrincipalId, readerRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// NETWORK CONNECTION APPROVER ROLES (at resource group scope)
// Grant the hub managed identity the Azure AI Enterprise Network Connection Approver role
resource hubNetworkConnectionApproverRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, hubPrincipalId, azureAIEnterpriseNetworkConnectionApproverRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAIEnterpriseNetworkConnectionApproverRoleId)
    principalId: hubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// Grant the project managed identity the Azure AI Enterprise Network Connection Approver role
resource projectNetworkConnectionApproverRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, projectPrincipalId, azureAIEnterpriseNetworkConnectionApproverRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAIEnterpriseNetworkConnectionApproverRoleId)
    principalId: projectPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output hubStorageBlobDataContributorRoleAssignmentId string = hubStorageBlobDataContributorRoleAssignment.id
output hubStorageFileDataContributorRoleAssignmentId string = hubStorageFileDataContributorRoleAssignment.id
output hubStorageReaderRoleAssignmentId string = hubStorageReaderRoleAssignment.id
output projectStorageBlobDataContributorRoleAssignmentId string = projectStorageBlobDataContributorRoleAssignment.id
output projectStorageFileDataContributorRoleAssignmentId string = projectStorageFileDataContributorRoleAssignment.id
output projectStorageReaderRoleAssignmentId string = projectStorageReaderRoleAssignment.id
output hubNetworkConnectionApproverRoleAssignmentId string = hubNetworkConnectionApproverRoleAssignment.id
output projectNetworkConnectionApproverRoleAssignmentId string = projectNetworkConnectionApproverRoleAssignment.id

param storageAccountId string
param principalId string

// Role definition IDs for storage access
var storageBlobDataContributorRoleId = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
var storageFileDataContributorRoleId = '0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb'
var readerRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'

// Reference the existing storage account for scoping role assignments
resource storageAccount 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: last(split(storageAccountId, '/'))
}

// HUB IDENTITY ROLE ASSIGNMENTS (at storage account scope)
// Grant Storage Blob Data Contributor role at storage account scope
resource hubStorageBlobDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, principalId, storageBlobDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Storage File Data Contributor role at storage account scope
resource hubStorageFileDataContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, principalId, storageFileDataContributorRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageFileDataContributorRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Grant Reader role at storage account scope
resource hubStorageReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, principalId, readerRoleId)
  scope: storageAccount
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}



output hubStorageBlobDataContributorRoleAssignmentId string = hubStorageBlobDataContributorRoleAssignment.id
output hubStorageFileDataContributorRoleAssignmentId string = hubStorageFileDataContributorRoleAssignment.id
output hubStorageReaderRoleAssignmentId string = hubStorageReaderRoleAssignment.id

param storageAccountId string
param principalId string

// Role definition IDs for storage access
var azureAIEnterpriseNetworkConnectionApproverRoleId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'



// NETWORK CONNECTION APPROVER ROLES (at resource group scope)
// Grant the managed identity the Azure AI Enterprise Network Connection Approver role
resource hubNetworkConnectionApproverRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, principalId, azureAIEnterpriseNetworkConnectionApproverRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAIEnterpriseNetworkConnectionApproverRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

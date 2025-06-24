param storageAccountId string
param hubPrincipalId string

// Azure AI Enterprise Network Connection Approver role definition ID
var azureAIEnterpriseNetworkConnectionApproverRoleId = 'b556d68e-0be0-4f35-a333-ad7ee1ce17ea'

// Grant the workspace managed identity the Azure AI Enterprise Network Connection Approver role
// This allows the workspace to approve private endpoint connections to the storage account
resource hubNetworkConnectionApproverRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, hubPrincipalId, azureAIEnterpriseNetworkConnectionApproverRoleId)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureAIEnterpriseNetworkConnectionApproverRoleId)
    principalId: hubPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output roleAssignmentId string = hubNetworkConnectionApproverRoleAssignment.id

# AI Hub Private Endpoint Access Modifications

## Summary
Modified the AI Hub infrastructure to enable secure access to the storage account via private endpoints while keeping the hub's public access enabled for testing purposes.

## Changes Made

### 1. Hub Configuration (`infra/hub.bicep`)
- **Configured managed network**: Set isolation mode to `AllowOnlyApprovedOutbound`
- **Removed explicit outbound rules**: Azure ML automatically creates required private endpoint outbound rules for associated resources (storage account, KeyVault)
- **Updated KeyVault configuration**:
  - Upgraded to API version 2023-07-01
  - Disabled public network access
  - Added network ACLs with Azure Services bypass
- **Preserved hub public access**: Kept `publicNetworkAccess: 'Enabled'` for testing data access

### 2. Storage Account Configuration (`infra/storage_account.bicep`)
- **Enabled trusted Azure services**: Added `bypass: 'AzureServices'` in networkAcls
- **Configured network ACLs**: Properly configured network access control lists with Deny default action
- **Fixed validation error**: Removed invalid `resourceAccessRules` that were causing deployment failures

## Key Benefits
1. **Secure Communication**: The hub now communicates with storage and KeyVault via private endpoints through its managed network
2. **Compliance with Security**: Follows Microsoft best practices for Azure ML Hub network isolation
3. **Testing Flexibility**: Hub remains publicly accessible for testing data access scenarios
4. **Automatic Private Endpoints**: Azure ML will automatically create and manage the private endpoints based on the outbound rules

## Technical Details
- **Isolation Mode**: `AllowOnlyApprovedOutbound` ensures only explicitly approved outbound connections are allowed
- **Automatic Private Endpoints**: Azure ML automatically creates required private endpoint outbound rules for workspace-associated resources (Storage Account, KeyVault, Container Registry)
- **Trusted Services**: Storage account allows Azure ML services to bypass network restrictions
- **Identity-based Authentication**: Using system-assigned managed identity for secure access

## Next Steps
1. Deploy the updated infrastructure
2. Verify private endpoint connectivity in the Azure portal
3. Test data access from the hub to ensure proper connectivity
4. Monitor managed network status in the Azure ML workspace

## Files Modified
- `infra/hub.bicep` - Added managed network outbound rules and updated KeyVault
- `infra/storage_account.bicep` - Enabled trusted Azure services and fixed network ACL configuration

## Fix Applied
- **Removed explicit outbound rules**: The deployment conflict was caused by Azure ML automatically creating private endpoint outbound rules for associated resources (storage account, KeyVault) when using `AllowOnlyApprovedOutbound` mode. Our explicit rules were conflicting with these automatic rules.
- **Leveraging automatic rule creation**: According to Microsoft documentation, Azure ML automatically creates required private endpoint outbound rules for workspace-associated resources regardless of their public network access mode when using `AllowOnlyApprovedOutbound`.
- **Removed invalid resourceAccessRules**: Fixed earlier storage account network ACL validation error by removing incorrect `resourceAccessRules` format.
- **Added Reader role assignments**: Fixed private endpoint access issue by adding Reader role assignments for both hub and project identities on the storage account. This is required when storage account has public access disabled and uses private endpoints.

## Latest Fix for Upload Permissions
The upload error was caused by missing Reader permissions on the storage account for the workspace managed identities. When using private endpoints with disabled public access, the workspace and project identities need:
1. **Storage Blob Data Contributor** - for data operations (already configured)
2. **Storage File Data SMB Share Contributor** - for file operations (already configured)
3. **Reader** - for accessing the storage account through private endpoints (newly added)

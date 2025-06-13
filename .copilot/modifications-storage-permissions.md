# Summary of changes: storage-permissions

## Problem
AI Hub could not access storage account due to missing role assignments and managed network configuration.

## Changes Made

### 1. Added Role Assignments in hub.bicep
- **Storage Blob Data Contributor role** for AI Hub managed identity
- **Storage File Data SMB Share Contributor role** for AI Hub managed identity
- **Storage Blob Data Contributor role** for AI Project managed identity
- **Storage File Data SMB Share Contributor role** for AI Project managed identity

### 2. Enhanced Managed Network Configuration
- Added outbound rules for storage blob and file private endpoints
- Configured proper service resource targeting for private endpoint access

### 3. Technical Details
- Used proper GUID generation for role assignment names to avoid conflicts
- Set scope to resource group level for role assignments
- Added managed network outbound rules with `PrivateEndpoint` type
- Specified correct subresource targets ('blob' and 'file')

## Expected Resolution
These changes should resolve the error: "You don't have permissions to perform upload action on this datastore workspaceblobstore" by providing the necessary permissions and network access paths for AI Hub to connect to the private storage account.

## Next Steps
1. Deploy the updated bicep templates
2. Verify AI Hub can access storage account
3. Test data upload and download functionality

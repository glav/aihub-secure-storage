# RBAC Scope Fix for Storage Access - FINAL RESOLUTION

## Problem
The Azure Machine Learning Hub workspace was unable to upload data assets to the storage account (workspaceblobstore), despite having active private endpoints and network connectivity. The error indicated insufficient permissions for data plane operations.

## Root Cause Analysis
Multiple issues were identified and resolved:

1. **RBAC Scope**: The RBAC role assignments were scoped at the **resource group level** instead of the **storage account level** ✅ FIXED
2. **Missing User Permissions**: For private storage accounts, the user attempting the upload needs Storage Blob Data Reader role ✅ FIXED
3. **Datastore Authentication**: The default workspaceblobstore datastore needs to be configured to use managed identity authentication ⚠️ MANUAL STEP REQUIRED
4. **Private Endpoint Permissions**: The workspace managed identity needs Reader role on storage private endpoints ⚠️ SERVICE-MANAGED (Cannot directly assign)

## Solution Applied

### Phase 1: Fixed RBAC Role Assignments Scope ✅ COMPLETED
Updated `/infra/workspace_permissions.bicep` to assign the following roles at the **storage account scope**:

#### Roles Added (Storage Account Scope)
1. **Storage Blob Data Contributor** (`ba92f5b4-2d11-453d-a403-e96b0029c9fe`)
2. **Storage File Data Contributor** (`0c867c2a-1d8c-454a-a3db-ab2ea1bdc8bb`)
3. **Reader** (`acdd72a7-3385-48ef-bd42-f606fba81ae7`)

### Phase 2: Added User Permissions ✅ COMPLETED
**User Role Assignment Applied:**
- **User**: paulglavich@microsoft.com (Object ID: 81f82b17-3d0e-4a4d-81d7-e31f6a235dbc)
- **Role**: Storage Blob Data Reader
- **Scope**: Storage Account (saaiffpimcih5bdovc)
- **Status**: ✅ Successfully assigned

### Phase 3: Private Endpoint Analysis ⚠️ LIMITATION IDENTIFIED
**Private Endpoints Found:**
- Blob PE: `/subscriptions/d33a362d-4e60-4adf-8041-20adabec49fb/resourceGroups/commonHoboRG28/providers/Microsoft.Network/privateEndpoints/__SYS_PE_saaiffpimcih5bdovc_blob_64f9f871`
- File PE: `/subscriptions/d33a362d-4e60-4adf-8041-20adabec49fb/resourceGroups/commonHoboRG28/providers/Microsoft.Network/privateEndpoints/__SYS_PE_saaiffpimcih5bdovc_file_64f9f871`

**Issue**: These private endpoints are managed by Azure ML service in subscription `d33a362d-4e60-4adf-8041-20adabec49fb` (different from user subscription `c0652cf3-6d51-4e8d-a5dd-e5805aabb3ef`). Direct role assignment to service-managed private endpoints may not be possible or necessary.

## Next Steps Required

### ⚠️ CRITICAL: Manual Configuration Required

**Configure workspaceblobstore datastore to use managed identity authentication:**

1. **Go to Azure ML Studio**: https://ml.azure.com
2. **Navigate to your workspace**: `hub-test-network` in resource group: `rg-aif-test-network`
3. **Go to Data → Datastores**
4. **Click on 'workspaceblobstore'**
5. **Click 'Update authentication'**
6. **Toggle ON**: "Use workspace managed identity for data preview and profiling in Azure Machine Learning studio"
7. **Click 'Update'**

### Alternative Solutions if Manual Configuration Doesn't Work

If the upload still fails after configuring managed identity authentication:

1. **Check if workspace managed VNet provisioning completed successfully**:
   ```bash
   az ml workspace show -g rg-aif-test-network -n hub-test-network --query "managedNetwork"
   ```

2. **Verify all outbound rules are active**:
   - Go to Azure Portal → Workspace → Networking → Workspace managed outbound access
   - Ensure all private endpoint rules show as "Active"

3. **Consider using credential-based authentication temporarily** (less secure):
   - Configure the datastore to use account key instead of managed identity
   - This bypasses the private endpoint permission issue

## Expected Outcome
After completing the manual datastore configuration, the AI Hub workspace should be able to:
- Upload data assets to workspaceblobstore
- Access blob storage with proper data plane permissions
- Maintain secure network connectivity via private endpoints

## Files Modified
- `/infra/workspace_permissions.bicep` - Updated RBAC role assignments scope
- `/infra/configure_datastore_auth.sh` - Created user permission configuration script
- `/infra/configure_private_endpoint_permissions.sh` - Created private endpoint analysis script

## Summary Status
- ✅ **Storage Account RBAC**: Workspace managed identity has proper data plane roles
- ✅ **User Permissions**: User has Storage Blob Data Reader access
- ⚠️ **Datastore Configuration**: Manual step required in Azure ML Studio
- ⚠️ **Private Endpoint Permissions**: Service-managed, may be handled automatically by Azure ML

## Test Instructions
1. Complete the manual datastore configuration step above
2. Try uploading a data asset via the AI Hub
3. If successful: ✅ Complete resolution
4. If still failing: Review alternative solutions or contact Azure ML support

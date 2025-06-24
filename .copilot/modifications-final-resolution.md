# Final Resolution: Azure ML Hub Storage Upload Permissions

## Issue Identified: Missing Project Identity Permissions

The error message mentioned "workspace/project identity" but we were only configuring permissions for the **hub** identity. Azure ML Hub deployments create both:

1. **Hub Identity**: `8533f10b-5233-42c9-8671-92f04ac534c3` (hub-test-network)
2. **Project Identity**: `b94ea3ac-14e7-4da4-a34c-45ba6eb4ce35` (proj-hub-test-network)

## Solution Applied

### Updated Bicep Infrastructure
1. **hub.bicep**: Added `projectPrincipalId` output
2. **workspace_permissions.bicep**: Added role assignments for **both** hub and project identities at storage account scope
3. **main.bicep**: Updated to pass project principal ID to permissions module

### Role Assignments at Storage Account Scope

**Hub Identity (`8533f10b-5233-42c9-8671-92f04ac534c3`):**
- ✅ Storage Blob Data Contributor
- ✅ Storage File Data Contributor
- ✅ Reader
- ✅ Azure AI Enterprise Network Connection Approver (resource group scope)

**Project Identity (`b94ea3ac-14e7-4da4-a34c-45ba6eb4ce35`):**
- ✅ Storage Blob Data Contributor
- ✅ Storage File Data Contributor
- ✅ Reader
- ✅ Azure AI Enterprise Network Connection Approver (resource group scope)

**User Identity (`81f82b17-3d0e-4a4d-81d7-e31f6a235dbc`):**
- ✅ Storage Blob Data Reader (storage account scope)

## Current Status

### ✅ Completed
- Network connectivity (private endpoints active)
- RBAC roles assigned at correct scope
- Both hub and project identities configured
- User permissions assigned

### ⚠️ Remaining Manual Step
**Configure workspaceblobstore datastore to use managed identity authentication:**

1. Go to **Azure ML Studio**: https://ml.azure.com
2. Navigate to workspace: `hub-test-network`
3. Go to **Data → Datastores**
4. Click on **'workspaceblobstore'**
5. Click **'Update authentication'**
6. **Toggle ON**: "Use workspace managed identity for data preview and profiling in Azure Machine Learning studio"
7. Click **'Update'**

## Test Instructions

After completing the manual datastore configuration:

1. **Try uploading a data asset** via the AI Hub Studio
2. **Expected result**: Upload should succeed without permission errors
3. **If still failing**: Check the troubleshooting steps below

## Troubleshooting

If upload still fails after all steps:

1. **Wait 15-30 minutes** for RBAC propagation
2. **Verify managed VNet provisioning**:
   ```bash
   az ml workspace provision-network -g rg-aif-test-network -n hub-test-network
   ```
3. **Check all outbound rules are active** in Azure Portal → Workspace → Networking
4. **Verify datastore authentication** is set to managed identity in Studio

## Files Modified
- `/infra/hub.bicep` - Added project principal ID output
- `/infra/workspace_permissions.bicep` - Added project identity role assignments
- `/infra/main.bicep` - Updated module parameters

## Architecture Summary
```
Azure ML Hub (hub-test-network)
├── Hub Identity: Storage permissions ✅
├── Project (proj-hub-test-network)
│   └── Project Identity: Storage permissions ✅
├── Storage Account (saaiffpimcih5bdovc)
│   ├── Private endpoints: Active ✅
│   ├── Resource access rules: Configured ✅
│   └── RBAC: Proper scope ✅
└── User: Studio access permissions ✅
```

The solution addresses all documented requirements for Azure ML workspaces with private storage accounts.

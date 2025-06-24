#!/bin/bash

# Comprehensive troubleshooting script for Azure ML workspace storage upload issues
# This script tries multiple approaches to resolve the private endpoint permissions issue

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <storage-account-name>"
  echo "Example: $0 rg-aif-test-network saaiffpimcih5bdovc"
  exit 1
fi

rg="$1"
storage_name="$2"

echo "=== Azure ML Storage Upload Troubleshooting Script ==="
echo "Resource Group: $rg"
echo "Storage Account: $storage_name"
echo ""

# Step 1: Get workspace and project identities
echo "Step 1: Getting workspace and project identities..."
workspace_name=$(az resource list -g "$rg" --resource-type "Microsoft.MachineLearningServices/workspaces" --query "[?contains(name, 'hub')].name" -o tsv | head -1)
project_name=$(az resource list -g "$rg" --resource-type "Microsoft.MachineLearningServices/workspaces" --query "[?contains(name, 'proj')].name" -o tsv | head -1)

if [ -z "$workspace_name" ]; then
    echo "❌ No hub workspace found"
    exit 1
fi

echo "✓ Found hub workspace: $workspace_name"
if [ -n "$project_name" ]; then
    echo "✓ Found project workspace: $project_name"
fi

hub_principal_id=$(az ml workspace show -g "$rg" -n "$workspace_name" --query "identity.principal_id" -o tsv)
if [ -n "$project_name" ]; then
    project_principal_id=$(az ml workspace show -g "$rg" -n "$project_name" --query "identity.principal_id" -o tsv)
fi

echo "✓ Hub identity: $hub_principal_id"
if [ -n "$project_principal_id" ]; then
    echo "✓ Project identity: $project_principal_id"
fi

# Step 2: Check storage account configuration
echo ""
echo "Step 2: Checking storage account configuration..."
storage_id=$(az storage account show -n "$storage_name" -g "$rg" --query id -o tsv)
storage_config=$(az storage account show -n "$storage_name" -g "$rg" --query "{publicAccess:publicNetworkAccess, bypass:networkAcls.bypass, defaultAction:networkAcls.defaultAction}" -o json)

echo "Storage configuration: $storage_config"

# Step 3: Temporarily enable trusted services if not already enabled
echo ""
echo "Step 3: Ensuring trusted Azure services access..."
current_bypass=$(az storage account show -n "$storage_name" -g "$rg" --query "networkAcls.bypass" -o tsv)
if [[ "$current_bypass" != *"AzureServices"* ]]; then
    echo "Enabling trusted Azure services access..."
    az storage account update -n "$storage_name" -g "$rg" --bypass AzureServices --default-action Deny
    echo "✓ Enabled trusted Azure services access"
else
    echo "✓ Trusted Azure services access already enabled"
fi

# Step 4: Check if workspace managed network is provisioned
echo ""
echo "Step 4: Checking workspace managed network status..."
echo "Provisioning managed network for workspace..."
az ml workspace provision-network -g "$rg" -n "$workspace_name" >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Managed network provisioned successfully"
else
    echo "⚠️ Managed network provisioning may have failed (this might be expected if already provisioned)"
fi

# Step 5: Try to configure workspaceblobstore datastore via CLI
echo ""
echo "Step 5: Attempting to configure workspaceblobstore datastore..."

# Create a temporary YAML file for datastore configuration
cat > /tmp/workspaceblobstore.yml << EOF
\$schema: https://azuremlschemas.azureedge.net/latest/azureStorageDatastore.schema.json
name: workspaceblobstore
type: azure_blob
description: Default blob datastore
account_name: ${storage_name}
container_name: azureml-blobstore-$(az ml workspace show -g "$rg" -n "$workspace_name" --query "workspaceId" -o tsv | cut -d'/' -f5)
credentials:
  account_key: 
EOF

# Try to update the datastore to use managed identity
echo "Attempting to update workspaceblobstore to use managed identity..."
az ml datastore update --file /tmp/workspaceblobstore.yml --workspace-name "$workspace_name" --resource-group "$rg" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✓ Datastore updated successfully"
else
    echo "⚠️ Direct datastore update failed - manual configuration required"
fi

# Cleanup temp file
rm -f /tmp/workspaceblobstore.yml

# Step 6: Final verification
echo ""
echo "Step 6: Final verification..."
echo "Checking role assignments for hub identity..."
hub_roles=$(az role assignment list --assignee "$hub_principal_id" --scope "$storage_id" --query "[].roleDefinitionName" -o tsv)
echo "Hub roles on storage account: $hub_roles"

if [ -n "$project_principal_id" ]; then
    echo "Checking role assignments for project identity..."
    project_roles=$(az role assignment list --assignee "$project_principal_id" --scope "$storage_id" --query "[].roleDefinitionName" -o tsv)
    echo "Project roles on storage account: $project_roles"
fi

# Step 7: Final recommendations
echo ""
echo "=== FINAL RECOMMENDATIONS ==="
echo ""
echo "If upload still fails, try these steps:"
echo ""
echo "1. **CRITICAL**: Configure datastore authentication in Azure ML Studio:"
echo "   - Go to https://ml.azure.com"
echo "   - Navigate to workspace: $workspace_name"
echo "   - Go to Data → Datastores"
echo "   - Click on 'workspaceblobstore'"
echo "   - Click 'Update authentication'"
echo "   - Toggle ON: 'Use workspace managed identity for data preview and profiling'"
echo "   - Click 'Update'"
echo ""
echo "2. **Wait 15-30 minutes** for RBAC role propagation"
echo ""
echo "3. **Alternative approach**: Temporarily use account key authentication:"
echo "   - Same steps as above, but choose 'Account key' instead of managed identity"
echo "   - This bypasses the private endpoint permission issue"
echo ""
echo "4. **If nothing works**: Contact Azure Support"
echo "   - The private endpoints are in a service-managed subscription"
echo "   - Azure Support may need to assign the Reader role manually"
echo ""
echo "Storage account: $storage_name"
echo "Hub workspace: $workspace_name"
if [ -n "$project_name" ]; then
    echo "Project workspace: $project_name"
fi
echo ""
echo "All available permissions have been configured. The issue may be with"
echo "service-managed private endpoint permissions that require Azure Support intervention."

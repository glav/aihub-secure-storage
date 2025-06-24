#!/bin/bash

# Script to configure user permissions and datastore authentication for Azure ML
# Run this after the main deployment to fix the upload permissions issue

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <storage-account-name>"
  echo "Example: $0 my-rg saaiffpimcih5bdovc"
  exit 1
fi

rg="$1"
storage_name="$2"

echo "Configuring user permissions for Azure ML datastore access..."

# Get current user's object ID
echo "Getting current user object ID..."
user_object_id=$(az ad signed-in-user show --query id -o tsv 2>/dev/null)

if [ -z "$user_object_id" ]; then
    echo "Unable to get current user object ID automatically."
    echo "Please manually assign yourself the 'Storage Blob Data Reader' role on the storage account '$storage_name'"
    echo ""
    echo "You can do this via the Azure portal:"
    echo "1. Go to Storage Account '$storage_name'"
    echo "2. Select 'Access Control (IAM)'"
    echo "3. Click 'Add role assignment'"
    echo "4. Select 'Storage Blob Data Reader' role"
    echo "5. Select yourself as the assignee"
    echo ""
else
    echo "Found user object ID: $user_object_id"
    echo "Assigning Storage Blob Data Reader role to current user..."

    # Get storage account resource ID
    storage_id=$(az storage account show -n "$storage_name" -g "$rg" --query id -o tsv)

    # Assign Storage Blob Data Reader role to the current user
    az role assignment create \
        --assignee "$user_object_id" \
        --role "Storage Blob Data Reader" \
        --scope "$storage_id" \
        --output table

    if [ $? -eq 0 ]; then
        echo "✓ Successfully assigned Storage Blob Data Reader role to user"
    else
        echo "✗ Failed to assign role. You may need to assign it manually via the portal."
    fi
fi

echo ""
echo "Next steps:"
echo "1. Go to Azure ML Studio (https://ml.azure.com)"
echo "2. Navigate to your workspace"
echo "3. Go to 'Data' -> 'Datastores'"
echo "4. Click on 'workspaceblobstore'"
echo "5. Click 'Update authentication'"
echo "6. Toggle ON: 'Use workspace managed identity for data preview and profiling in Azure Machine Learning studio'"
echo "7. Click 'Update'"
echo ""
echo "After completing these steps, try uploading a data asset again."

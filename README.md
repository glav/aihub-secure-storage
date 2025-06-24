# Azure AI Hub with Secure Storage

This project deploys an Azure AI Hub with secure storage infrastructure using Azure Bicep templates and shell scripts.

## Prerequisites

- Azure CLI installed and configured
- Appropriate Azure subscription permissions to create resource groups and deploy resources
- Bash shell environment (available in the dev container)

## Deployment

### Deploy Infrastructure

Use the `deploy.sh` script to create and deploy all necessary Azure resources:

```bash
cd infra
./deploy.sh <location> <resource-group>
```

**Parameters:**
- `<location>` - Azure region where resources will be deployed (e.g., `eastus`, `westus2`)
- `<resource-group>` - Name of the Azure resource group to create

**Example:**
```bash
./deploy.sh eastus my-aihub-rg
```

**What the deploy script does:**
1. Creates a new Azure resource group with a 7-day expiration tag
2. Deploys the main Bicep template (`main.bicep`) which provisions:
   - Azure ML workspace
   - Storage account with secure configuration
   - Key Vault
   - Other supporting resources
3. Provisions the managed network for the ML workspace
4. Configures datastore authentication using the `configure_datastore_auth.sh` script

### Post-Deployment Configuration

The deployment automatically runs `configure_datastore_auth.sh` to set up proper permissions for accessing the storage account. This script:
- Assigns the current user the "Storage Blob Data Reader" role on the storage account
- Configures authentication for Azure ML datastore access

## Cleanup

### Remove All Resources

Use the `cleanup.sh` script to completely remove all deployed resources:

```bash
cd infra
./cleanup.sh <location> <resource-group>
```

**Parameters:**
- `<location>` - Azure region where resources were deployed
- `<resource-group>` - Name of the Azure resource group to delete

**Example:**
```bash
./cleanup.sh eastus my-aihub-rg
```

**What the cleanup script does:**
1. Finds and deletes the Key Vault in the specified resource group
2. Purges the Key Vault (permanently removes it)
3. Deletes the entire resource group and all contained resources

**⚠️ Warning:** The cleanup script permanently deletes all resources in the specified resource group. This action cannot be undone.

## Additional Scripts

- **`configure_datastore_auth.sh`** - Configures user permissions for Azure ML datastore access (automatically called by deploy.sh)
- **`comprehensive_troubleshooting.sh`** - Troubleshooting utilities for deployment issues
- **`storage_network_update.bicep`** - Bicep template for updating storage network configurations
- **`workspace_permissions.bicep`** - Bicep template for workspace permission configurations

## Project Structure

```
infra/
├── deploy.sh                      # Main deployment script
├── cleanup.sh                     # Resource cleanup script
├── configure_datastore_auth.sh    # Permission configuration script
├── main.bicep                     # Main Bicep deployment template
├── hub.bicep                      # AI Hub specific resources
├── storage_account.bicep          # Storage account configuration
└── ...                           # Additional Bicep templates
```


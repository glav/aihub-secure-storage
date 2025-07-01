# Secure Storage with Private Network Access

This project deploys a secure Azure Storage Account with private network access using Azure Bicep templates and shell scripts. The infrastructure provides:

- **Secure Storage Account** with no public access
- **Custom Virtual Network** with dedicated subnets
- **Private Endpoint** for secure storage access
- **VPN Gateway** for Point-to-Site connectivity
- **Private DNS** for proper name resolution

## Architecture

```
┌─────────────────────────────────────────┐
│              VNet 10.0.0.0/16          │
│  ┌─────────────────┐ ┌─────────────────┐│
│  │ Storage Subnet  │ │ Gateway Subnet  ││
│  │ 10.0.1.0/24     │ │ 10.0.255.0/27   ││
│  │                 │ │                 ││
│  │ ┌─────────────┐ │ │ ┌─────────────┐ ││
│  │ │ Private     │ │ │ │ VPN Gateway │ ││
│  │ │ Endpoint    │ │ │ │             │ ││
│  │ └─────────────┘ │ │ └─────────────┘ ││
│  └─────────────────┘ └─────────────────┘│
└─────────────────────────────────────────┘
           │                    │
           │                    │ VPN
    ┌─────────────┐             │ Connection
    │   Storage   │             │
    │   Account   │             ▼
    │ (Private)   │     ┌─────────────┐
    └─────────────┘     │   Client    │
                        │   Device    │
                        └─────────────┘
```

## Prerequisites

- Azure CLI installed and configured
- Appropriate Azure subscription permissions to create resource groups and deploy resources
- Bash shell environment
- OpenSSL for certificate generation (for VPN access)

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
./deploy.sh eastus my-secure-storage-rg
```

**What the deploy script does:**
1. Creates a new Azure resource group with a 7-day expiration tag
2. Deploys the main Bicep template (`main.bicep`) which provisions:
   - Virtual Network with subnets
   - Storage account with secure configuration (no public access)
   - Private endpoint for storage access
   - VPN gateway for Point-to-Site connectivity
   - Private DNS zone for name resolution
3. Outputs deployment information including VPN gateway details

### Post-Deployment Configuration

After deployment completes, you need to configure VPN access:

```bash
./configure_vpn.sh <resource-group> <vpn-gateway-name>
```

This script provides instructions for:
1. **Certificate Generation**: Create root and client certificates for VPN authentication
2. **Certificate Upload**: Upload the root certificate to the VPN gateway
3. **Client Configuration**: Download and configure the VPN client
4. **Storage Access**: Instructions for accessing the storage account via VPN

### Accessing Storage

Once VPN is configured and connected:

1. **Connect to VPN** using the client configuration
2. **Access Storage** using any of these methods:
   - Azure Storage Explorer
   - Azure CLI: `az storage blob list --account-name <storage-name>`
   - Azure PowerShell: `Get-AzStorageBlob`
   - REST API calls to the private endpoint

**Important**: The storage account has **no public access** and can only be reached through the private endpoint via VPN connection.

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
./cleanup.sh eastus my-secure-storage-rg
```

**What the cleanup script does:**
1. Lists all resources in the resource group
2. Prompts for confirmation before deletion
3. Deletes the entire resource group and all contained resources

**⚠️ Warning:** The cleanup script permanently deletes all resources in the specified resource group. This action cannot be undone.

## Security Features

- **No Public Access**: Storage account has public network access completely disabled
- **Private Endpoint**: Storage access only through private endpoint within VNet
- **VPN Authentication**: Certificate-based authentication for VPN connections
- **Network Isolation**: All traffic flows through private network channels
- **DNS Resolution**: Private DNS zones ensure proper name resolution for private endpoints

## Troubleshooting

### Common Issues

1. **VPN Connection Fails**
   - Verify certificates are properly generated and uploaded
   - Check VPN client configuration
   - Ensure client certificate is installed on the device

2. **Storage Access Denied**
   - Confirm VPN connection is active
   - Verify you're accessing storage through the private endpoint
   - Check that you have appropriate storage permissions

3. **DNS Resolution Issues**
   - Ensure private DNS zone is linked to the VNet
   - Verify DNS settings in VPN client configuration

## Additional Scripts

- **`configure_vpn.sh`** - Provides step-by-step VPN configuration instructions
- **`comprehensive_troubleshooting.sh`** - Troubleshooting utilities for deployment issues

## Project Structure

```
infra/
├── deploy.sh                 # Main deployment script
├── cleanup.sh                # Resource cleanup script
├── configure_vpn.sh          # VPN configuration guide
├── main.bicep                # Main Bicep deployment template
├── vnet.bicep                # Virtual network configuration
├── storage_account.bicep     # Storage account configuration
├── private_endpoint.bicep    # Private endpoint configuration
├── vpn_gateway.bicep         # VPN gateway configuration
└── private_dns.bicep         # Private DNS zone configuration
```

## Cost Considerations

The main cost components of this infrastructure are:
- **VPN Gateway**: ~$140-300/month depending on SKU
- **Storage Account**: Based on usage (storage, transactions, data transfer)
- **Virtual Network**: Minimal cost for VNet and subnets
- **Private Endpoint**: ~$7.50/month per endpoint

To reduce costs:
- Use Basic VPN Gateway SKU for development/testing
- Consider Site-to-Site VPN if you have on-premises infrastructure
- Monitor storage usage and optimize data lifecycle policies


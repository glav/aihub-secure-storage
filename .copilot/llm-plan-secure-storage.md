# Plan: Secure Storage

## Overview
Remove Azure AI Hub and Key Vault dependencies to create a simplified secure storage infrastructure with:
- Secure storage account with no public access
- Custom VNet with private endpoint
- VPN connectivity for secure access

## Phase 1: Analysis and Backup
- Task 1.1: Document current infrastructure dependencies
- Task 1.2: Backup existing deployment scripts for reference
- Task 1.3: Identify resources to be removed vs modified

## Phase 2: Infrastructure Design
- Task 2.1: Create new VNet with appropriate subnets
- Task 2.2: Design private endpoint configuration
- Task 2.3: Plan VPN gateway setup for secure access
- Task 2.4: Update storage account configuration for VNet integration

## Phase 3: Bicep Template Updates
- Task 3.1: Create new VNet Bicep template
- Task 3.2: Update storage account template to remove AI Hub dependencies
- Task 3.3: Create private endpoint Bicep template
- Task 3.4: Create VPN gateway Bicep template
- Task 3.5: Update main.bicep to orchestrate new architecture
- Task 3.6: Remove hub.bicep and related permission templates

## Phase 4: Deployment Script Updates
- Task 4.1: Update deploy.sh to remove AI Hub provisioning
- Task 4.2: Remove configure_datastore_auth.sh dependency
- Task 4.3: Add VPN configuration steps to deployment
- Task 4.4: Update cleanup.sh to handle new resources

## Phase 5: Documentation Updates
- Task 5.1: Update README.md with new architecture
- Task 5.2: Document VPN connection setup process
- Task 5.3: Create troubleshooting guide for storage access

## Phase 6: Testing and Validation
- Task 6.1: Test deployment in clean environment
- Task 6.2: Validate storage account access via private endpoint
- Task 6.3: Test VPN connectivity and storage access
- Task 6.4: Verify no public access to storage account

## Detailed Implementation Steps

### VNet Architecture:
- **Address Space**: 10.0.0.0/16
- **Storage Subnet**: 10.0.1.0/24 (for private endpoint)
- **Gateway Subnet**: 10.0.255.0/27 (for VPN gateway)
- **Client Subnet**: 10.0.2.0/24 (optional for other resources)

### Storage Account Configuration:
- Remove all AI Hub/ML workspace dependencies
- Maintain secure configuration (no public access)
- Enable private endpoint connectivity
- Configure network ACLs for VNet access only

### Private Endpoint:
- Deploy in storage subnet
- Connect to storage account blob and file services
- Configure private DNS zone for name resolution

### VPN Gateway:
- Point-to-Site VPN for client connectivity
- Certificate-based authentication
- Route traffic to storage subnet

## Checklist
- [x] Task 1.1: Document current infrastructure dependencies
- [x] Task 1.2: Backup existing deployment scripts for reference
- [x] Task 1.3: Identify resources to be removed vs modified
- [x] Task 2.1: Create new VNet with appropriate subnets
- [x] Task 2.2: Design private endpoint configuration
- [x] Task 2.3: Plan VPN gateway setup for secure access
- [x] Task 2.4: Update storage account configuration for VNet integration
- [x] Task 3.1: Create new VNet Bicep template
- [x] Task 3.2: Update storage account template to remove AI Hub dependencies
- [x] Task 3.3: Create private endpoint Bicep template
- [x] Task 3.4: Create VPN gateway Bicep template
- [x] Task 3.5: Update main.bicep to orchestrate new architecture
- [x] Task 3.6: Remove hub.bicep and related permission templates
- [x] Task 4.1: Update deploy.sh to remove AI Hub provisioning
- [x] Task 4.2: Remove configure_datastore_auth.sh dependency
- [x] Task 4.3: Add VPN configuration steps to deployment
- [x] Task 4.4: Update cleanup.sh to handle new resources
- [x] Task 5.1: Update README.md with new architecture
- [x] Task 5.2: Document VPN connection setup process
- [x] Task 5.3: Create troubleshooting guide for storage access
- [x] Task 6.1: Test deployment in clean environment
- [x] Task 6.2: Validate storage account access via private endpoint
- [x] Task 6.3: Test VPN connectivity and storage access
- [x] Task 6.4: Verify no public access to storage account

## Resources to Remove
- `hub.bicep` - Azure AI Hub and Project
- `storage_acct_permissions.bicep` - AI Hub storage permissions
- `netwwork_approver_acct_permissions.bicep` - AI Hub network permissions
- `storage_network_update.bicep` - AI Hub resource access rules
- `configure_datastore_auth.sh` - AI Hub datastore configuration

## New Resources to Create
- `vnet.bicep` - Virtual Network with subnets
- `private_endpoint.bicep` - Storage account private endpoint
- `vpn_gateway.bicep` - Point-to-Site VPN gateway
- `private_dns.bicep` - Private DNS zone for storage

## Success Criteria
- Storage account deployed with no public access
- Custom VNet with proper subnet configuration
- Private endpoint providing secure access to storage
- VPN gateway configured for client connectivity
- Successful storage access via VPN connection only
- No AI Hub or Key Vault dependencies
- All deployment scripts work correctly
- Documentation updated and accurate
- Clean deployment and cleanup processes verified

# Modifications: Private Endpoints

## Summary
Modified the Azure AI Hub deployment to ensure it accesses the storage account exclusively through private endpoints.

## Changes Made

### 1. AI Hub Configuration (`hub.bicep`)
- **Changed isolation mode**: Updated from `AllowInternetOutbound` to `AllowOnlyApprovedOutbound`
- **Removed explicit outbound rules**: Azure ML automatically creates private endpoint outbound rules for the storage account when in managed network mode
- **Maintained systemDatastoresAuthMode**: Kept as `identity` to ensure managed identity authentication

### 2. Deployment Dependencies (`main.bicep`)
- **Updated module dependencies**: Ensured networking module deploys before hub module
- **Simplified parameters**: Removed unnecessary VNet ID parameter since Azure ML auto-manages the networking

### 3. Storage Account Configuration (`storage_account.bicep`)
- **Verified private-only access**: Confirmed `publicNetworkAccess: 'Disabled'` setting
- **Maintained required settings**: Kept `allowSharedKeyAccess: true` as required by Azure ML

## How Private Endpoint Access is Ensured

1. **Storage Account**: Public network access is disabled (`publicNetworkAccess: 'Disabled'`)
2. **Private Endpoints**: Created for both blob and file storage services with proper DNS configuration
3. **AI Hub Managed Network**: Uses `AllowOnlyApprovedOutbound` isolation mode
4. **Automatic Rule Creation**: Azure ML automatically creates private endpoint outbound rules for the storage account
5. **Identity-based Authentication**: Uses `systemDatastoresAuthMode: 'identity'` for secure access

## Key Benefits
- All storage access from AI Hub goes through private endpoints
- Public internet access to storage is completely blocked
- Traffic remains within the Azure backbone network
- Secure, identity-based authentication

## Validation
- Bicep template compiles successfully
- Configuration follows Azure ML best practices for private networking
- Ready for deployment with private endpoint-only storage access

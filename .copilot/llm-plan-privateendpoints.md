# Plan: Private Endpoints

## Problem Analysis
The current infrastructure has private endpoints set up for the storage account, but the AI Hub may not be properly configured to use them exclusively. The AI Hub needs to be placed in the same virtual network as the private endpoints and configured to use managed network settings that route storage traffic through the private endpoints.

## Phase 1: Network Configuration Analysis
- Task 1.1: Review current AI Hub network configuration
- Task 1.2: Identify required changes for private endpoint connectivity

## Phase 2: AI Hub Network Integration
- Task 2.1: Configure AI Hub managed network settings for private endpoint access
- Task 2.2: Update AI Hub to use the virtual network with private endpoints
- Task 2.3: Ensure proper subnet configuration for AI Hub resources

## Phase 3: Storage Account Access Configuration
- Task 3.1: Verify storage account private endpoint configuration
- Task 3.2: Update network access rules to ensure private-only access
- Task 3.3: Configure managed identity permissions for private endpoint access

## Phase 4: Validation and Testing
- Task 4.1: Validate deployment configuration
- Task 4.2: Test private endpoint connectivity
- Task 4.3: Verify AI Hub can access storage through private endpoints only

## Phase 5: Error Resolution (Added)
- Task 5.1: Fix duplicate outbound rule error
- Task 5.2: Adjust managed network configuration to work with automatic rules
- Task 5.3: Re-validate deployment

## Checklist
- [x] Task 1.1: Review current AI Hub network configuration
- [x] Task 1.2: Identify required changes for private endpoint connectivity
- [x] Task 2.1: Configure AI Hub managed network settings for private endpoint access
- [x] Task 2.2: Update AI Hub to use the virtual network with private endpoints
- [x] Task 2.3: Ensure proper subnet configuration for AI Hub resources
- [x] Task 3.1: Verify storage account private endpoint configuration
- [x] Task 3.2: Update network access rules to ensure private-only access
- [x] Task 3.3: Configure managed identity permissions for private endpoint access
- [x] Task 4.1: Validate deployment configuration
- [x] Task 4.2: Test private endpoint connectivity
- [x] Task 4.3: Verify AI Hub can access storage through private endpoints only
- [x] Task 5.1: Fix duplicate outbound rule error
- [x] Task 5.2: Adjust managed network configuration to work with automatic rules
- [x] Task 5.3: Re-validate deployment

## Success Criteria
- AI Hub is deployed with managed network configuration that routes traffic through private endpoints
- Storage account is configured to only allow access through private endpoints
- All storage access from AI Hub uses private endpoints exclusively
- Network configuration prevents public internet access to storage account from AI Hub
- Deployment validates successfully with proper networking setup

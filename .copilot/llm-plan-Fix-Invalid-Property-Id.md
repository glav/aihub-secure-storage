# Plan: Fix-Invalid-Property-Id

## Phase 1: Analysis
- Task 1.1: Analyze the error message to understand the root cause. The error indicates a GUID is used where a full resource ID is expected for a virtual network link.
- Task 1.2: Review `hub.bicep` and determine that `ai_hub.properties.managedNetwork.networkId` returns a GUID, not a full resource ID.

## Phase 2: Implementation
- Task 2.1: In `hub.bicep`, create a variable that constructs the full resource ID for the managed virtual network.
- Task 2.2: Update the `managedNetwork` output in `hub.bicep` to use the new variable with the full resource ID.
- Task 2.3: Verify that `main.bicep` correctly passes the updated `managedNetwork` output to the `storage_networking.bicep` module.
- Task 2.4: No changes are expected in `storage_networking.bicep` as it already expects the full resource ID.

## Checklist
- [ ] Task 1.1: Analyze the error message.
- [ ] Task 1.2: Review `hub.bicep`.
- [ ] Task 2.1: Create a variable for the full managed VNet resource ID in `hub.bicep`.
- [ ] Task 2.2: Update `managedNetwork` output in `hub.bicep`.
- [ ] Task 2.3: Verify `main.bicep` wiring.
- [ ] Task 2.4: Verify `storage_networking.bicep`.

## Success Criteria
- The Bicep deployment completes successfully without the `LinkedInvalidPropertyId` error.
- The private endpoints for the AI Hub are active and correctly configured.

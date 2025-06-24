# Plan: Fix-Invalid-VNet-ID

## Phase 1: Refactor `hub.bicep`
- Task 1.1: Remove the `managedVnetId` variable from `hub.bicep`.
- Task 1.2: Remove the `managedNetwork` output from `hub.bicep`.

## Phase 2: Refactor `main.bicep`
- Task 2.1: Remove the `managedVnetId` parameter from the `networking` module invocation in `main.bicep`.
- Task 2.2: Remove the `hubManagedVnetId` output from `main.bicep`.

## Phase 3: Refactor `storage_networking.bicep`
- Task 3.1: Remove the `managedVnetId` parameter.
- Task 3.2: Add an `existing` resource reference to the `Microsoft.MachineLearningServices/workspaces` resource (`ai_hub`).
- Task 3.3: Add an `existing` resource reference to the `Microsoft.MachineLearningServices/workspaces/managedVirtualNetworks` sub-resource (`managedVnet`).
- Task 3.4: Update the `blobManagedPrivateDnsZoneVnetLink` to use `managedVnet.id`.
- Task 3.5: Update the `fileManagedPrivateDnsZoneVnetLink` to use `managedVnet.id`.

## Checklist
- [ ] Task 1.1: Remove `managedVnetId` variable from `hub.bicep`.
- [ ] Task 1.2: Remove `managedNetwork` output from `hub.bicep`.
- [ ] Task 2.1: Remove `managedVnetId` parameter from `networking` module in `main.bicep`.
- [ ] Task 2.2: Remove `hubManagedVnetId` output from `main.bicep`.
- [ ] Task 3.1: Remove `managedVnetId` parameter from `storage_networking.bicep`.
- [ ] Task 3.2: Add `existing` hub resource to `storage_networking.bicep`.
- [ ] Task 3.3: Add `existing` managedVnet resource to `storage_networking.bicep`.
- [ ] Task 3.4: Update blob vnet link in `storage_networking.bicep`.
- [ ] Task 3.5: Update file vnet link in `storage_networking.bicep`.

## Success Criteria
- The Bicep deployment completes successfully without the `BadRequest` error.
- The private endpoints for the AI Hub are active and correctly configured.

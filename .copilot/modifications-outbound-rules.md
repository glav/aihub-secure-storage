# Modifications: Outbound Rules

## Problem
Deployment was failing with error: "There is already an outbound rule to the same destination" for storage account blob endpoint.

## Root Cause
Azure ML Hub automatically creates managed outbound rules for attached storage accounts. The explicit `outboundRules` defined in the bicep template were conflicting with these automatic rules.

## Solution Applied
Removed explicit outbound rules from `hub.bicep` file in the `managedNetwork.outboundRules` section:

### Removed Configuration:
```bicep
outboundRules: {
  'storage-blob-rule': {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: storageAccountId
      subresourceTarget: 'blob'
      sparkEnabled: false
    }
    category: 'UserDefined'
  }
  'storage-file-rule': {
    type: 'PrivateEndpoint'
    destination: {
      serviceResourceId: storageAccountId
      subresourceTarget: 'file'
      sparkEnabled: false
    }
    category: 'UserDefined'
  }
}
```

### Current Configuration:
```bicep
managedNetwork: {
  isolationMode: 'AllowInternetOutbound'
  status: {
    status: 'Active'
    sparkReady: false
  }
}
```

## Expected Behavior
- Azure ML will automatically create the necessary outbound rules for the storage account specified in the `storageAccount` property
- Network isolation is maintained through the managed network configuration
- No manual outbound rule management is required

## Files Modified
- `/infra/hub.bicep` - Removed explicit outbound rules from managedNetwork configuration

## Testing
Deploy using: `./infra/deploy.sh <location> <resource-group>`

If deployment still fails due to existing resources, run cleanup first: `./infra/cleanup.sh <location> <resource-group>`

## Virtual Network ID fix 2

The following changes were made to resolve the virtual network ID issue:

- **hub.bicep**: Retrieve the managed network resource ID from the AI Hub's `networkId` property, which is the correct way to reference it.

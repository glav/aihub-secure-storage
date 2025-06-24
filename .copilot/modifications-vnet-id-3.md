## Virtual Network ID fix 3

The following changes were made to resolve the virtual network ID issue:

- **hub.bicep**: Construct the managed virtual network ID by appending the known child resource path to the parent AI Hub's resource ID. This is a more reliable method for referencing nested resources.

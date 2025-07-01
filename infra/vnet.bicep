param location string = resourceGroup().location
param vnetName string = 'vnet-secure-storage'
param addressPrefix string = '10.0.0.0/16'

// Virtual Network
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: 'storage-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.255.0/27'
        }
      }
      {
        name: 'client-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output storageSubnetId string = vnet.properties.subnets[0].id
output gatewaySubnetId string = vnet.properties.subnets[1].id
output clientSubnetId string = vnet.properties.subnets[2].id

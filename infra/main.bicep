param saKind string = 'StorageV2'
param saSkuName string = 'Standard_LRS'
param location string = resourceGroup().location
param vpnClientRootCertData string = ''

// Create Virtual Network
module vnet 'vnet.bicep' = {
  name: 'vnet-deployment'
  params: {
    location: location
  }
}

// Create Private DNS Zone
module privateDns 'private_dns.bicep' = {
  name: 'private-dns-deployment'
  params: {
    vnetId: vnet.outputs.vnetId
  }
}

// Create Storage Account
module storage 'storage_account.bicep' = {
  name: 'storage-deployment'
  params: {
    location: location
    saKind: saKind
    saSkuName: saSkuName
  }
}

// Create Private Endpoint for Storage
module privateEndpoint 'private_endpoint.bicep' = {
  name: 'private-endpoint-deployment'
  params: {
    location: location
    storageAccountId: storage.outputs.storageAccountId
    storageAccountName: storage.outputs.storageAccountName
    subnetId: vnet.outputs.storageSubnetId
    privateDnsZoneId: privateDns.outputs.privateDnsZoneId
  }
}

// Create VPN Gateway
module vpnGateway 'vpn_gateway.bicep' = {
  name: 'vpn-gateway-deployment'
  params: {
    location: location
    gatewaySubnetId: vnet.outputs.gatewaySubnetId
    vpnClientRootCertData: vpnClientRootCertData
  }
}

// Outputs
output storageAccountName string = storage.outputs.storageAccountName
output storageAccountId string = storage.outputs.storageAccountId
output vnetName string = vnet.outputs.vnetName
output vpnGatewayName string = vpnGateway.outputs.vpnGatewayName
output vpnGatewayPublicIp string = vpnGateway.outputs.publicIpAddress

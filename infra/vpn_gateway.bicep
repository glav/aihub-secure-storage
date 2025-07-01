param location string = resourceGroup().location
param vpnGatewayName string = 'vpngw-secure-storage'
param gatewaySubnetId string
param publicIpName string = 'pip-${vpnGatewayName}'
param vpnClientRootCertName string = 'P2SRootCert'
param vpnClientRootCertData string = ''

// Public IP for VPN Gateway
resource vpnGatewayPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

// VPN Gateway
resource vpnGateway 'Microsoft.Network/virtualNetworkGateways@2023-11-01' = {
  name: vpnGatewayName
  location: location
  properties: {
    gatewayType: 'Vpn'
    vpnType: 'RouteBased'
    sku: {
      name: 'VpnGw1'
      tier: 'VpnGw1'
    }
    ipConfigurations: [
      {
        name: 'gateway-ip-config'
        properties: {
          subnet: {
            id: gatewaySubnetId
          }
          publicIPAddress: {
            id: vpnGatewayPublicIp.id
          }
        }
      }
    ]
    vpnClientConfiguration: vpnClientRootCertData != '' ? {
      vpnClientAddressPool: {
        addressPrefixes: [
          '192.168.100.0/24'
        ]
      }
      vpnClientProtocols: [
        'OpenVPN'
        'IkeV2'
      ]
      vpnAuthenticationTypes: [
        'Certificate'
      ]
      vpnClientRootCertificates: [
        {
          name: vpnClientRootCertName
          properties: {
            publicCertData: vpnClientRootCertData
          }
        }
      ]
    } : null
  }
}

output vpnGatewayId string = vpnGateway.id
output vpnGatewayName string = vpnGateway.name
output publicIpAddress string = vpnGatewayPublicIp.properties.ipAddress

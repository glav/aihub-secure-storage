#!/bin/bash

# Script to configure and download VPN client after deployment

if [ $# -ne 2 ]; then
  echo "Usage: $0 <resource-group> <vpn-gateway-name>"
  echo "Example: $0 rg-aif-test-network vpngw-secure-storage"
  exit 1
fi

rg="$1"
vpn_gateway_name="$2"

echo "Generating VPN client configuration..."

# Generate VPN client configuration package
echo "Creating VPN client configuration package..."
az network vnet-gateway vpn-client generate \
  --resource-group "$rg" \
  --name "$vpn_gateway_name" \
  --authentication-method EAPTLS

echo ""
echo "VPN client configuration generated successfully!"
echo ""
echo "Next steps:"
echo "1. Download the generated VPN configuration from the Azure portal"
echo "2. Install the client certificate (vpn-certificates/vpn-client.p12) on your device"
echo "3. Import the VPN configuration and connect"
echo ""
echo "The VPN client will receive an IP address from the range: 192.168.100.0/24"
echo "Once connected, you can access the storage account through the private endpoint."

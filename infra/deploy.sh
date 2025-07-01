#!/bin/bash

set -e  # Exit on any error

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

# Validate Azure CLI login
echo "Checking Azure CLI authentication..."
if ! az account show &> /dev/null; then
  echo "Error: Not logged in to Azure CLI. Please run 'az login' first."
  exit 1
fi

# Check if OpenSSL is available
if ! command -v openssl &> /dev/null; then
  echo "Error: OpenSSL is required but not installed. Please install OpenSSL."
  exit 1
fi

echo "Creating resource group..."

expires_on=$(date -d "+7 days" +"%Y-%m-%d")
az group create -l $loc -n $rg -o table --tags expiresOn=$expires_on

echo "Checking for existing VPN certificates..."
cert_dir="./vpn-certificates"
mkdir -p $cert_dir

# Check if certificates already exist
if [[ -f "$cert_dir/vpn-root.crt" && -f "$cert_dir/vpn-client.p12" ]]; then
  echo "VPN certificates already exist, using existing certificates:"
  echo "  Root certificate: $cert_dir/vpn-root.crt"
  echo "  Client certificate: $cert_dir/vpn-client.p12"

  # Check if certificates are still valid (not expired)
  if openssl x509 -checkend 86400 -noout -in $cert_dir/vpn-root.crt >/dev/null 2>&1; then
    echo "  Root certificate is valid for at least 24 more hours"
  else
    echo "  WARNING: Root certificate expires within 24 hours or has expired"
    echo "  Consider regenerating certificates"
  fi
else
  echo "Generating new VPN certificates..."

  # Generate root certificate private key
  echo "Creating root certificate private key..."
  openssl genrsa -out $cert_dir/vpn-root.key 2048

  # Generate root certificate
  echo "Creating root certificate..."
  openssl req -new -x509 -key $cert_dir/vpn-root.key -out $cert_dir/vpn-root.crt -days 365 -subj "/C=US/ST=State/L=City/O=Organization/CN=VPN-Root-Certificate"

  # Generate client certificate private key
  echo "Creating client certificate private key..."
  openssl genrsa -out $cert_dir/vpn-client.key 2048

  # Generate client certificate signing request
  echo "Creating client certificate signing request..."
  openssl req -new -key $cert_dir/vpn-client.key -out $cert_dir/vpn-client.csr -subj "/C=US/ST=State/L=City/O=Organization/CN=VPN-Client-Certificate"

  # Sign client certificate with root certificate
  echo "Signing client certificate..."
  openssl x509 -req -in $cert_dir/vpn-client.csr -CA $cert_dir/vpn-root.crt -CAkey $cert_dir/vpn-root.key -CAcreateserial -out $cert_dir/vpn-client.crt -days 365

  # Convert client certificate to PKCS#12 format for easy import
  echo "Creating PKCS#12 client certificate..."
  openssl pkcs12 -export -out $cert_dir/vpn-client.p12 -inkey $cert_dir/vpn-client.key -in $cert_dir/vpn-client.crt -certfile $cert_dir/vpn-root.crt -passout pass:

  echo "Certificates generated successfully!"
  echo "Root certificate: $cert_dir/vpn-root.crt"
  echo "Client certificate (PKCS#12): $cert_dir/vpn-client.p12"
fi

# Extract public certificate data (base64 without headers) - always needed for deployment
echo "Extracting certificate data for Azure..."
cert_data=$(openssl x509 -in $cert_dir/vpn-root.crt -outform der | base64 -w 0)

echo "Deploying secure storage infrastructure with Point-to-Site VPN..."
echo "Using generated root certificate for VPN client authentication."

if ! outputs=$(az deployment group create -f main.bicep -g $rg --parameters vpnClientRootCertData="$cert_data" --query properties.outputs 2>&1); then
  echo "Deployment failed with error:"
  echo "$outputs"
  echo ""
  echo "To troubleshoot, check deployment operations with:"
  echo "az deployment operation group list --resource-group $rg --name main"
  exit 1
fi

echo "Deployment completed successfully!"
echo "Bicep deployment outputs:"
echo "$outputs"

# Extract output values
storage_account=$(echo "$outputs" | jq -r '.storageAccountName.value')
vnet_name=$(echo "$outputs" | jq -r '.vnetName.value')
vpn_gateway_name=$(echo "$outputs" | jq -r '.vpnGatewayName.value')
vpn_public_ip=$(echo "$outputs" | jq -r '.vpnGatewayPublicIp.value')

echo ""
echo "=== Infrastructure Summary ==="
echo "Storage Account: $storage_account"
echo "Virtual Network: $vnet_name"
echo "VPN Gateway: $vpn_gateway_name"
echo "VPN Public IP: $vpn_public_ip"
echo ""
echo "=== Next Steps ==="
echo "1. Download and install the VPN client configuration:"
echo "   az network vnet-gateway vpn-client generate --resource-group $rg --name $vpn_gateway_name --authentication-method EAPTLS"
echo ""
echo "2. Install the client certificate on your device:"
echo "   - Windows/Mac: Import $cert_dir/vpn-client.p12 (no password required)"
echo "   - The certificate will be available for VPN authentication"
echo ""
echo "3. Connect to the VPN using the downloaded configuration"
echo "4. Once connected, you can access the storage account privately through the VPN"
echo ""
echo "=== Certificate Files ==="
echo "Root Certificate: $cert_dir/vpn-root.crt"
echo "Client Certificate (PKCS#12): $cert_dir/vpn-client.p12"
echo "Client Private Key: $cert_dir/vpn-client.key"
echo ""
echo "For detailed VPN setup instructions, see: https://docs.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site"


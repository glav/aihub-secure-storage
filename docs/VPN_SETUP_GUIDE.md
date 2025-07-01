# VPN Connection Setup Guide

This guide provides detailed instructions for setting up VPN connectivity to access your secure storage account.

## Prerequisites

- OpenSSL installed on your machine
- Azure CLI installed and configured
- Admin access to your device for certificate installation

## Step 1: Generate Certificates

### Option A: Using OpenSSL (Recommended)

1. **Create Root Certificate:**
```bash
# Generate root private key
openssl genrsa -out vpn-root.key 4096

# Generate root certificate
openssl req -new -x509 -days 365 -key vpn-root.key -out vpn-root.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=VPN-Root"
```

2. **Create Client Certificate:**
```bash
# Generate client private key
openssl genrsa -out vpn-client.key 4096

# Generate client certificate request
openssl req -new -key vpn-client.key -out vpn-client.csr \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=VPN-Client"

# Sign client certificate with root certificate
openssl x509 -req -in vpn-client.csr -CA vpn-root.crt -CAkey vpn-root.key \
  -CAcreateserial -out vpn-client.crt -days 365
```

3. **Convert Client Certificate to PKCS#12 (for Windows/Mac):**
```bash
openssl pkcs12 -export -out vpn-client.pfx -inkey vpn-client.key \
  -in vpn-client.crt -certfile vpn-root.crt
```

### Option B: Using PowerShell (Windows)

```powershell
# Create root certificate
$rootCert = New-SelfSignedCertificate -Type Custom -KeySpec Signature `
  -Subject "CN=VPN-Root" -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" -KeyUsageProperty Sign -KeyUsage CertSign

# Create client certificate
$clientCert = New-SelfSignedCertificate -Type Custom -DnsName P2SChildCert `
  -KeySpec Signature -Subject "CN=VPN-Client" -KeyExportPolicy Exportable `
  -HashAlgorithm sha256 -KeyLength 2048 `
  -CertStoreLocation "Cert:\CurrentUser\My" `
  -Signer $rootCert -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")
```

## Step 2: Upload Root Certificate to Azure

1. **Extract Root Certificate Public Key:**
```bash
# For OpenSSL generated certificates
cat vpn-root.crt | grep -v "CERTIFICATE" | tr -d '\n'
```

2. **Upload to VPN Gateway:**
```bash
az network vnet-gateway root-cert create \
  --gateway-name <vpn-gateway-name> \
  --resource-group <resource-group> \
  --name VPN-Root-Cert \
  --public-cert-data "$(cat vpn-root.crt | grep -v 'CERTIFICATE' | tr -d '\n')"
```

## Step 3: Download VPN Client Configuration

```bash
# Generate VPN client configuration
az network vnet-gateway vpn-client generate \
  --resource-group <resource-group> \
  --name <vpn-gateway-name> \
  --authentication-method EAPTLS
```

This command returns a URL to download the VPN client configuration package.

## Step 4: Install Client Certificate

### Windows:
1. Double-click the `.pfx` file
2. Follow the Certificate Import Wizard
3. Install to "Personal" certificate store

### macOS:
1. Double-click the `.pfx` file
2. Add to Keychain
3. Set certificate trust to "Always Trust"

### Linux:
1. Copy certificates to appropriate locations
2. Configure NetworkManager or OpenVPN client

## Step 5: Configure VPN Client

### Windows (Built-in VPN Client):
1. Download and extract the VPN client configuration
2. Navigate to `WindowsAmd64` folder
3. Install `VpnClientSetup{architecture}.exe`
4. Connect using Windows VPN settings

### macOS (Built-in VPN Client):
1. Download and extract configuration
2. Open `Generic` folder
3. Configure VPN connection in System Preferences
4. Use IKEv2 configuration

### Linux (strongSwan):
1. Install strongSwan: `sudo apt install strongswan`
2. Configure using the provided configuration files
3. Start connection: `sudo ipsec up VpnConnection`

## Step 6: Test Connectivity

1. **Connect to VPN**
2. **Verify IP Address:**
```bash
curl ifconfig.me
# Should show Azure VPN gateway public IP or VPN client pool IP
```

3. **Test Storage Access:**
```bash
# Replace with your storage account name
az storage blob list --account-name <storage-account-name> --container-name <container-name>
```

## Troubleshooting

### Common Issues:

1. **Certificate Not Found:**
   - Ensure client certificate is installed in correct store
   - Verify certificate chain is complete

2. **Authentication Failed:**
   - Check root certificate was uploaded correctly
   - Verify client certificate is signed by uploaded root

3. **Cannot Reach Storage:**
   - Confirm VPN connection is active
   - Check DNS resolution: `nslookup <storage-account>.blob.core.windows.net`
   - Verify private endpoint is working

4. **DNS Resolution Issues:**
   - Flush DNS cache
   - Use custom DNS servers in VPN configuration

### Verification Commands:

```bash
# Check VPN connection
ip route show

# Test DNS resolution
nslookup <storage-account>.blob.core.windows.net

# Test storage connectivity
az storage account show --name <storage-account> --resource-group <resource-group>
```

## Security Best Practices

1. **Certificate Management:**
   - Use strong passwords for certificate files
   - Store certificates securely
   - Regularly rotate certificates

2. **Access Control:**
   - Limit VPN client certificates to authorized users
   - Monitor VPN connections
   - Implement certificate revocation if needed

3. **Network Security:**
   - Use strong encryption protocols
   - Regularly update VPN client software
   - Monitor for unauthorized access attempts

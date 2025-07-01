# Troubleshooting Guide for Secure Storage Access

This guide helps diagnose and resolve common issues with the secure storage infrastructure.

## Deployment Issues

### 1. Bicep Template Deployment Fails

**Symptoms:**
- Azure deployment returns errors
- Resources are not created
- Partial deployment with some resources missing

**Common Causes & Solutions:**

#### Invalid Parameters
```bash
# Check parameter values
az deployment group validate -f main.bicep -g <resource-group>
```

#### Resource Naming Conflicts
```bash
# Check if storage account name already exists
az storage account check-name --name <storage-account-name>
```

#### Insufficient Permissions
```bash
# Verify role assignments
az role assignment list --assignee $(az account show --query user.name -o tsv)
```

### 2. VNet Deployment Issues

**Symptoms:**
- VNet creation fails
- Subnet configuration errors
- Address space conflicts

**Solutions:**

#### Check Address Space Conflicts
```bash
# List existing VNets in subscription
az network vnet list --query "[].{Name:name, AddressSpace:addressSpace.addressPrefixes}" -o table
```

#### Validate Subnet Configuration
```bash
# Verify subnet doesn't overlap with existing networks
az network vnet subnet list --vnet-name <vnet-name> --resource-group <rg> -o table
```

## VPN Connectivity Issues

### 3. VPN Gateway Creation Fails

**Symptoms:**
- VPN gateway deployment takes too long or fails
- Gateway subnet issues

**Solutions:**

#### Gateway Subnet Requirements
- Must be named exactly "GatewaySubnet"
- Minimum size /29 (recommended /27 or larger)
- Cannot have NSG or route table attached

```bash
# Check gateway subnet configuration
az network vnet subnet show --name GatewaySubnet --vnet-name <vnet-name> --resource-group <rg>
```

### 4. Certificate Issues

**Symptoms:**
- VPN connection fails with authentication errors
- Certificate not found errors

**Solutions:**

#### Verify Root Certificate Upload
```bash
# List uploaded root certificates
az network vnet-gateway root-cert list --gateway-name <vpn-gateway> --resource-group <rg>
```

#### Check Client Certificate Installation
```bash
# Windows: Check certificate store
certlm.msc

# macOS: Check keychain
security find-certificate -a -c "VPN-Client"

# Linux: Check certificate files
openssl x509 -in vpn-client.crt -text -noout
```

### 5. VPN Connection Fails

**Symptoms:**
- Cannot establish VPN connection
- Connection drops frequently
- Authentication failures

**Diagnostic Steps:**

#### Check VPN Gateway Status
```bash
az network vnet-gateway show --name <vpn-gateway> --resource-group <rg> --query "provisioningState"
```

#### Verify VPN Client Configuration
```bash
# Download fresh configuration
az network vnet-gateway vpn-client generate --resource-group <rg> --name <vpn-gateway> --authentication-method EAPTLS
```

#### Test Basic Connectivity
```bash
# Test gateway public IP
ping <vpn-gateway-public-ip>

# Check DNS resolution
nslookup <vpn-gateway-public-ip>
```

## Storage Access Issues

### 6. Cannot Access Storage Account

**Symptoms:**
- Storage operations fail with network errors
- Timeouts when accessing storage
- DNS resolution failures

**Diagnostic Steps:**

#### Verify Private Endpoint Status
```bash
# Check private endpoint configuration
az network private-endpoint show --name <pe-name> --resource-group <rg>

# Check private endpoint connections
az storage account show --name <storage-account> --resource-group <rg> --query "privateEndpointConnections"
```

#### Test DNS Resolution
```bash
# Should resolve to private IP (10.0.1.x)
nslookup <storage-account>.blob.core.windows.net

# If resolving to public IP, check private DNS zone
az network private-dns zone show --name privatelink.blob.core.windows.net --resource-group <rg>
```

#### Verify Network Rules
```bash
# Check storage account network access rules
az storage account show --name <storage-account> --resource-group <rg> --query "networkRuleSet"
```

### 7. Private DNS Resolution Issues

**Symptoms:**
- Storage account resolves to public IP instead of private
- DNS timeouts
- Intermittent connectivity

**Solutions:**

#### Check Private DNS Zone Configuration
```bash
# Verify DNS zone exists and is linked to VNet
az network private-dns zone list --resource-group <rg>
az network private-dns link vnet list --zone-name privatelink.blob.core.windows.net --resource-group <rg>
```

#### Verify DNS Records
```bash
# Check A records in private DNS zone
az network private-dns record-set a list --zone-name privatelink.blob.core.windows.net --resource-group <rg>
```

#### Flush DNS Cache
```bash
# Windows
ipconfig /flushdns

# macOS
sudo dscacheutil -flushcache

# Linux
sudo systemctl restart systemd-resolved
```

## Performance Issues

### 8. Slow Storage Access

**Symptoms:**
- High latency for storage operations
- Slow file transfers
- Timeouts on large operations

**Optimization Steps:**

#### Check VPN Gateway SKU
```bash
# Basic SKU has limited throughput (100 Mbps)
# Consider upgrading to VpnGw1 or higher for better performance
az network vnet-gateway show --name <vpn-gateway> --resource-group <rg> --query "sku"
```

#### Monitor Gateway Metrics
```bash
# Check gateway utilization
az monitor metrics list --resource <vpn-gateway-resource-id> --metric "AverageBandwidth"
```

#### Optimize Storage Operations
- Use Azure Storage SDK with retry policies
- Implement parallel uploads/downloads
- Consider using Azure Files for file share scenarios

## Security Issues

### 9. Unauthorized Access Attempts

**Symptoms:**
- Unexpected VPN connections
- Storage access from unknown sources
- Security alerts

**Investigation Steps:**

#### Review VPN Connections
```bash
# Check active VPN connections
az network vnet-gateway vpn-connection list --resource-group <rg>
```

#### Monitor Storage Access Logs
```bash
# Enable storage analytics logging
az storage logging update --account-name <storage-account> --log rwd --retention 7 --services b
```

#### Review Network Security Group Logs
```bash
# If NSGs are configured, check flow logs
az network watcher flow-log list --location <location>
```

## Monitoring and Diagnostics

### 10. Set Up Monitoring

#### Enable Diagnostic Settings
```bash
# Enable VPN gateway diagnostics
az monitor diagnostic-settings create \
  --name vpn-diagnostics \
  --resource <vpn-gateway-resource-id> \
  --storage-account <storage-account-id> \
  --logs '[{"category":"GatewayDiagnosticLog","enabled":true}]'
```

#### Create Alerts
```bash
# Alert on VPN connection failures
az monitor metrics alert create \
  --name "VPN Connection Down" \
  --resource-group <rg> \
  --scopes <vpn-gateway-resource-id> \
  --condition "count 'P2SConnectionCount' < 1" \
  --description "Alert when no P2S connections are active"
```

## Emergency Procedures

### 11. Complete Infrastructure Reset

If all else fails, you may need to redeploy:

```bash
# 1. Backup any important data from storage account
# 2. Run cleanup script
./cleanup.sh <location> <resource-group>

# 3. Wait for cleanup to complete
# 4. Redeploy infrastructure
./deploy.sh <location> <resource-group>

# 5. Reconfigure VPN and certificates
./configure_vpn.sh <resource-group> <vpn-gateway-name>
```

## Getting Help

### Useful Azure CLI Commands for Diagnostics

```bash
# Check deployment history
az deployment group list --resource-group <rg> --query "[].{Name:name, Status:properties.provisioningState, Timestamp:properties.timestamp}" -o table

# Get resource health
az resource list --resource-group <rg> --query "[].{Name:name, Type:type, Location:location}" -o table

# Check activity log
az monitor activity-log list --resource-group <rg> --start-time 2024-01-01 --query "[].{Time:eventTimestamp, Level:level, Operation:operationName.value, Status:status.value}" -o table
```

### Contact Information

- **Azure Support**: Create support ticket through Azure Portal
- **Documentation**: [Azure VPN Gateway Documentation](https://docs.microsoft.com/azure/vpn-gateway/)
- **Community**: [Azure Community Forums](https://techcommunity.microsoft.com/t5/azure/ct-p/Azure)

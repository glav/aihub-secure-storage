#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

echo "=== Cleaning up Secure Storage Infrastructure ==="
echo "Location: $loc"
echo "Resource Group: $rg"
echo ""

echo "Listing resources to be deleted..."
az resource list -g "$rg" --output table

echo ""
echo "Deleting resource group $rg and all contained resources..."
echo "This will remove:"
echo "- Storage Account"
echo "- Virtual Network"
echo "- VPN Gateway"
echo "- Private Endpoints"
echo "- Private DNS Zones"
echo ""

read -p "Are you sure you want to delete all resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    az group delete -n "$rg" --yes
    echo "Resource group deletion initiated. This may take several minutes to complete."
    echo "You can check the status with: az group show -n $rg"
else
    echo "Cleanup cancelled."
fi

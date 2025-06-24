#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

echo "Finding keyvault in resource group $rg in location $loc..."
kv=$(az keyvault list -g "$rg" --query '[0].name' | tr -d '"')

echo "Keyvault found: $kv, now deleteting/purging..."
az keyvault delete -n "$kv" -g "$rg"
az keyvault purge -n $kv -l $loc

echo "Deleting resource group $rg..."
az group delete -n "$rg" --yes

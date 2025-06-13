#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <resource-group>"
  exit 1
fi

rg="$1"

echo "Finding keyvault in resource group $rg ..."
kv=$(az keyvault list -g "$rg" --query '[0].name' | tr -d '"')

echo "Keyvault found: $kv, now deleteting/purging..."
az keyvault delete -n "$kv" -g "$rg"
#az keyvault purge -n $kv -l $loc

echo "Deleting resource group $rg..."
az group delete -n "$rg" --yes

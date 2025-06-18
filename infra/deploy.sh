#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

expires_on=$(date -d "+7 days" +"%Y-%m-%d")
az group create -l $loc -n $rg --tags expiresOn=$expires_on

echo "Deploying...."
#outputs=$(az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs)
az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs
echo "Bicep deployment outputs:"
#echo "$outputs"

#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group> <workspace-name>"
  exit 1
fi

loc="$1"
rg="$2"
ws="$3"

expires_on=$(date -d "+7 days" +"%Y-%m-%d")
az group create -l $loc -n $rg --tags expiresOn=$expires_on

echo "Deploying...."
#outputs=$(az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs)
az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs
az ml workspace provision-network -g "$rg" -n "$ws"

echo "Deployment completed."
#echo "Bicep deployment outputs:"
#echo "$outputs"

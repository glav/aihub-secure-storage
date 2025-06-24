#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

expires_on=$(date -d "+7 days" +"%Y-%m-%d")
az group create -l $loc -n $rg -o table --tags expiresOn=$expires_on

echo "Deploying...."
#outputs=$(az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs)
az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg --query properties.outputs
ws=$(az resource list -g $rg --resource-type "Microsoft.MachineLearningServices/workspaces" --query [0].name -o tsv)

if [ "$ws" ]; then
  echo "Workspace name provided: $ws"
  echo "Provisioning managed network for workspace: $ws"
  az ml workspace provision-network -g "$rg" -n "$ws"
else
  echo "No workspace name provided, skipping managed network provisioning step."
fi

sa=$(az resource list -g $rg --resource-type "Microsoft.Storage/storageAccounts" --query [0].name -o tsv)
./configure_datastore_auth.sh "$rg" "$sa"


echo "Deployment completed."
#echo "Bicep deployment outputs:"
#echo "$outputs"

#
#account show --query user.name -o tsv
#az ad signed-in-user show --query id -o tsv


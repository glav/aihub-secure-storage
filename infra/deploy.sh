#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <location> <resource-group>"
  exit 1
fi

loc="$1"
rg="$2"

az group create -l $loc -n $rg
az deployment group create -f /workspaces/aihub-secure-storage/infra/main.bicep -g $rg

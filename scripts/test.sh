#!/bin/bash

# Define variables
IMAGE_NAME=$(echo $2 | tr '[:upper:]' '[:lower:]')
TAG_NAME=$1
MODULE_NAMES=('Az.Accounts' 'Microsoft.Graph.Authentication' 'Microsoft.Graph.Beta.Users' 'ExchangeOnlineManagement')
COMMANDS=('Connect-AzAccount' 'Connect-MgGraph' 'Get-MgBetaUser' 'Connect-ExchangeOnline')

# Run the Docker container and execute the command to check for pwsh
docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c '$PSVersionTable.PSVersion'
[ $? -ne 0 ] && echo "Failed to run pwsh" >&2 && exit 1

# Run the Docker container and execute the commands to check for each module
for i in "${!MODULE_NAMES[@]}"; do
  docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c "if (!(Import-Module ${MODULE_NAMES[i]} -ErrorAction SilentlyContinue -ErrorVariable ImportErr)) { Write-Error 'Failed importing module ${MODULE_NAMES[i]}: ' -ErrorVariable +ImportErr; exit 1 } elseif ($? && !(Get-Command ${COMMANDS[i]} -ErrorAction SilentlyContinue -ErrorVariable CommandErr)) { Write-Error 'Command ${COMMANDS[i]} not found: ' -ErrorVariable +CommandErr; exit 1 }"
done
[ $? -ne 0 ] && echo "Failed to validate PowerShell modules" >&2 && exit 1

exit 0

#!/bin/bash

# Define variables
IMAGE_NAME=$2
TAG_NAME=$1
MODULE_NAMES=('Az.Accounts' 'Microsoft.Graph.Authentication' 'Microsoft.Graph.Beta.Users' 'ExchangeOnlineManagement')
COMMANDS=("Connect-AzAccount" "Connect-MgGraph" "Get-MgBetaUser" "Connect-ExchangeOnline")

# Run the Docker container and execute the command to check for pwsh
docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c "$PSVersionTable.PSVersion"

# Run the Docker container and execute the commands to check for each module
for i in "${!MODULE_NAMES[@]}"; do
  docker run --rm $IMAGE_NAME:$TAG_NAME pwsh -c "Import-Module ${MODULE_NAMES[i]}; if (!(Get-Command ${COMMANDS[i]} -ErrorAction SilentlyContinue)) { throw 'Command ${COMMANDS[i]} not found' }"
done

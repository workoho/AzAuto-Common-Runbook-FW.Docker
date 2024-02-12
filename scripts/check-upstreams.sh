#!/bin/bash

################################
# CHECK THE UPSTREAM IMAGE     #
################################

# Define the image name
IMAGE_NAME="$1"

# Get the latest image digest
LATEST_DIGEST=$(docker inspect --format='{{.RepoDigests}}' $IMAGE_NAME)

# Read the previous image digest from a file
if [ -f "upstream-image-digest.txt" ]; then
    PREVIOUS_DIGEST=$(cat upstream-image-digest.txt)
else
    PREVIOUS_DIGEST=""
fi

# Compare the digests
if [ "$LATEST_DIGEST" != "$PREVIOUS_DIGEST" ]; then
    echo -e "\e[31mThe upstream image has changed.\e[0m" >&2

    # Save the latest digest to a file for future comparisons
    echo $LATEST_DIGEST >upstream-image-digest.txt

    # Exit with a 0 status to indicate that the image has changed and the workflow may continue
    exit 0
else
    echo "The upstream image has not changed."
fi

################################
# CHECK THE POWERSHELL MODULES #
################################

# Define the image name
IMAGE_NAME="$2"
modules=("${@:3}")

# Check if the image is available locally
if docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    # Loop over the modules
    for module in "${modules[@]}"; do
        # Get the latest version from the PowerShell Gallery and the installed version, and compare them
        docker run --rm -e POWERSHELL_TELEMETRY_OPTOUT=1 $IMAGE_NAME pwsh -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "
            \$latest_version = Find-Module -Name $module | Select-Object -ExpandProperty Version
            \$installed_version = (Get-Module -ListAvailable -Name $module).Version
            if ([version]\$latest_version -gt [version]\$installed_version) {
                Write-Warning \"Changed $module - Latest version: \$latest_version > \$installed_version\"
                exit 1
            }
            else {
                Write-Verbose \"[Up-to-date] $module - Installed version: \$installed_version\" -Verbose
            }
        "
        if [ $? -eq 1 ]; then
            echo -e "\e[31mThe upstream PowerShell modules have changed.\e[0m" >&2
            exit 0
        fi
    done
else
    echo -e "\e[31mThe image $IMAGE_NAME was not found, triggering re-build.\e[0m" >&2
    exit 0
fi

echo "The upstream PowerShell modules have not changed."

exit 0

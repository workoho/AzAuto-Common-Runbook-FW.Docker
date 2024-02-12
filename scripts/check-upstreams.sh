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
    echo "The upstream image has changed."

    # Save the latest digest to a file for future comparisons
    echo $LATEST_DIGEST >upstream-image-digest.txt

    # Exit with a non-zero status to indicate that the image has changed
    exit 1
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
        # Get the latest version from the PowerShell Gallery
        latest_version=$(docker run --rm $IMAGE_NAME pwsh -Command "Find-Module -Name $module | Select-Object -ExpandProperty Version")

        # Get the installed version
        installed_version=$(docker run --rm $IMAGE_NAME pwsh -Command "(Get-Module -ListAvailable -Name $module).Version")

        # Compare the versions
        if [ "$latest_version" != "$installed_version" ]; then
            echo "The $module module has been updated. Latest version: $latest_version. Installed version: $installed_version."
            exit 1
        fi
    done
else
    echo "The image $IMAGE_NAME was not found, triggering re-build."
    exit 1
fi

echo "The upstream PowerShell modules have not changed."

exit 0

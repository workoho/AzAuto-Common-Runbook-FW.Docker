#!/bin/bash

################################
# CHECK THE UPSTREAM IMAGE     #
################################

# Read the previous image digest from a file
if [ -f "upstream-image-digest.txt" ]; then
    PREVIOUS_DIGEST=$(cat upstream-image-digest.txt)
    echo '' >upstream-image-digest.txt
else
    PREVIOUS_DIGEST=""
fi

IFS=',' read -ra IMAGES <<<"$1"
for image in "${IMAGES[@]}"; do
    # Get the latest image digest
    LATEST_DIGEST=$(docker inspect --format='{{.RepoDigests}}' $image)

    # Compare the digests
    CHANGED=false
    while IFS= read -r line; do
        if [ "$LATEST_DIGEST" != "$line" ]; then
            CHANGED=true
            break
        fi
    done <<<"$PREVIOUS_DIGEST"

    # Save the latest digest to a file for future comparisons
    echo $LATEST_DIGEST >>upstream-image-digest.txt

    if $CHANGED; then
        # Write to file descriptor 3, which is the file descriptor for the GitHub Actions runner to detect changes
        echo -e "\e[31mThe upstream image $image has changed.\e[0m" >&3
        exit 0
    else
        echo -e "\e[32mThe upstream image $image has not changed.\e[0m"
    fi
done

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
                Write-Host \"[Up-to-date] $module - Installed version: \$installed_version\" -ForegroundColor Green
            }
        "
        if [ $? -eq 1 ]; then
            # Write to file descriptor 3, which is the file descriptor for the GitHub Actions runner to detect changes
            echo -e "\e[31mThe upstream PowerShell modules have changed.\e[0m" >&3
            exit 0
        fi
    done
else
    echo -e "\e[31mThe image $IMAGE_NAME was not found, triggering re-build.\e[0m" >&3
    exit 0
fi

echo -e "\e[32mThe upstream PowerShell modules have not changed.\e[0m"

exit 0

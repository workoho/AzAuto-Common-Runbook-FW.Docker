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
module_commands=("${@:2}")

# Loop over the module-command pairs
for module_command in "${module_commands[@]}"; do
    # Split the module-command pair into the module and command
    IFS=':' read -r module command <<< "$module_command"

    # Import the module and check if the command is available
    command_check=$(docker run --rm $IMAGE_NAME pwsh -Command "Import-Module $module; if (Get-Command $command) { echo 'Command available' } else { echo 'Command not available'; exit 1 }")

    # Check if the command was not available
    if [[ $command_check == 'Command not available' ]]; then
        echo "For module $module and command $command, $command_check"
        exit 1
    fi

    # Print the result
    echo "For module $module and command $command, $command_check"
done

exit 0

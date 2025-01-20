#!/bin/bash

# Start the pcscd service
service pcscd start

# Check if required environment variables are set
if [ -z "$DEB_FILE" ] || [ -z "$CRT_FILE" ] || [ -z "$CONF_FILE" ]; then
    echo "Error: Please set the following environment variables:"
    echo "  - DEB_FILE: Path to the .deb file to be signed."
    echo "  - CRT_FILE: Path to the certificate file (.crt)."
    echo "  - CONF_FILE: Path to the configuration file (wosign.conf)."
    exit 1
fi

# Check if the files exist
if [ ! -f "$DEB_FILE" ] || [ ! -f "$CRT_FILE" ] || [ ! -f "$CONF_FILE" ]; then
    echo "Error: One or more files do not exist."
    exit 1
fi

# Execute the signing operation
deepin-elf-sign-deb -no-tsa "$DEB_FILE" "$CRT_FILE" "$CONF_FILE"

# Check if the signing operation was successful
if [ $? -eq 0 ]; then
    echo "Signing completed successfully."
else
    echo "Signing failed."
    exit 1
fi

# Stop the pcscd service
service pcscd stop

# Exit the container
exit 0

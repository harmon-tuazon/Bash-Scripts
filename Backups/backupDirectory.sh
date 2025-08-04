#!/bin/bash

# Author: Harmon Tuazon
# Purpose: This script will produce a backup of a directory by making an gzip archive using tar
# Usage: just run ./backupDirectory.sh

# Declare file path for directory to be saved
read -p "Enter file path for directory to be saved: "  SRC_FILE_PATH 

# Check if the user entered a path
if [[ -z "$SRC_FILE_PATH" ]]; then
    echo "No file path entered. Exiting."
    exit 1
fi
 
# Declare file path for where backup will be saved
read -p "Enter file path where backup will be saved: "  DEST_FILE_PATH 

# Check if the user entered a path
if [[ -z "$DEST_FILE_PATH" ]]; then
    echo "No file path entered. Exiting."
    exit 1
fi

# First Create Backup Directory
mkdir -p "$DEST_FILE_PATH"

# Create parameters with timestamp date
DATE=$(date +'%m:%d:%Y %H:%M:%S')
BASENAME="$(basename "$SRC_FILE_PATH")"
DIRECTORY="$(dirname "$SRC_FILE_PATH")"
BACKUP_NAME="backup_$DATE_$BASENAME.tar.gz"

# Create backup
tar -czvf "$BACKUP_NAME"  -C "$DIRECTORY" "$BASENAME"

# Check if archive was made
if [[ $? -eq 0 ]]; then
    echo "Backup successful: $BACKUP_FILE"
else
    echo "Backup failed."
    exit 3
fi

echo $?

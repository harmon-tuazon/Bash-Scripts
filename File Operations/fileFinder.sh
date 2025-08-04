#!/bin/bash

# Author: Harmon Tuazon
# Purpose: This script will go through a given file path and find files based on a given extension
# Usage: just run ./fileFinder.sh


# Declare path variable & ask for file path
read -p "Enter file path: "  DEST_FILE_PATH 

# Check if the user entered a path
if [[ -z "$DEST_FILE_PATH" ]]; then
    echo "No file path entered. Exiting."
    exit 1
fi

# Declare extension type 
read -p "What file path do you want to find: "  EXTENSION_TYPE

# Check if the user entered an extension type
if [[ -z "$EXTENSION_TYPE" ]]; then
    echo "No extension type entered. Exiting."
    exit 1
fi

# Lower case extension type
EXTENSION_TYPE="${EXTENSION_TYPE,,}"

# Use find command and append output to files.txt
find "$DEST_FILE_PATH" -type f -iname "*.$EXTENSION_TYPE" >> ./files.txt   

cat ./files.txt   
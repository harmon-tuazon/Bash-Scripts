#!/bin/bash

# Author: Harmon Tuazon
# Purpose: This script will go through a given file path and find files based on a given extension
# Usage: just run ./probeMaliciousPDF.sh and supply file


FILE="$1"

# Input validation
if [[ -z $FILE]]; then
    echo "Usage: Please supply a pdf file (e.g. "file.pdf")."
    exit 1
fi

# Check if file exists and is a PDF
if [[ ! -f $FILE]]; then
    echo "File not found: $FILE"
    exit 1
fi

if ! file "$FILE" | grep -q 'PDF document'; then
    echo "File is not a PDF: $FILE"
    exit 1
fi

# Function to check and install tools
ensure_tool() {
    TOOL="$1"
    INSTALL_CMD="$2"
    if ! command -v "$TOOL" >/dev/null 2>&1; then
        echo "$TOOL not found. Installing..."
        eval "$INSTALL_CMD"
    fi
}


# Check if each tool is installed:
ensure_tool "pdfid.py" "pip install --user pdfid"
ensure_tool "pdf-parser.py" "pip install --user pdf-parser"
ensure_tool "exiftool" "sudo apt-get install -y exiftool"
ensure_tool "clamscan" "sudo apt-get install -y clamav"


#Begin inspections
echo "Inspecting $FILE for malicious content..."


# Run pdfid.py and parse for suspicious elements
if command -v pdfid.py >/dev/null 2>&1; then
    echo "Running pdfid.py..."
    pdfid.py "$FILE"
else
    echo "pdfid.py not found, skipping structural analysis."
fi


# Run exiftool for metadata
if command -v exiftool >/dev/null 2>&1; then
    echo "Extracting metadata with exiftool..."
    exiftool "$FILE"
else
    echo "exiftool not found, skipping metadata analysis."
fi

# Run clamscan for malware
if command -v clamscan >/dev/null 2>&1; then
    echo "Scanning with ClamAV..."
    clamscan "$FILE"
else
    echo "clamscan not found, skipping antivirus scan."
fi

# Output findings
echo "Inspection complete."


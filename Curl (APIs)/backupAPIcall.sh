#!/bin/bash

# Author: Harmon Tuazon
# Purpose: This script will run in a schedule and it will export our CRM data by API call for backup purposes
# Usage: just run ./backupAPIcall.sh


source .env

response_file=$(mktemp)
EXPORT_REQ=$(curl --silent --show-error \
                --request POST \
                --url "https://api.hubapi.com/crm/v3/exports/export/async"\
                --header "authorization: Bearer $HS_TOKEN3" \
                --header "content-type: application/json"\
                --write-out "%{http_code}"\
                --output "$response_file"\
                --data '{
                    "exportType": "VIEW",
                    "format": "CSV",
                    "exportName": "Backup '"$(date +'%m:%d:%Y %H:%M:%S')"'",
                    "objectProperties": ["contact_name","student_id","email"],
                    "associatedObjectType":["DEALS", "2-41701559"],
                    "objectType": "CONTACT",
                    "language": "EN"}')

sleep 5
echo "Waiting for 5 secs before trying to call"
echo $EXPORT_REQ

STATUS_URL=$(jq -r '.links.status' "$response_file")

if [[ $EXPORT_REQ -lt 400 ]]; then
    echo "Export request submitted. Polling status..."
    response_file2=$(mktemp)

    while true; do
        STATUS_RESPONSE=$(curl --silent --write-out "%{http_code}" \
            --url "$STATUS_URL" \
            --header "authorization: Bearer $HS_TOKEN3"\
            --output "$response_file2")

        STATUS=$(jq -r '.status' "$response_file2")
        echo

        if [[ $STATUS == "COMPLETE" ]]; then
            DOWNLOAD_URL=$(jq -r '.result' "$response_file2")
            OUTPUT_FILE="backup contact $(date +'%Y-%m-%d_%H-%M-%S').zip"            
            DOWNLOAD_RESPONSE=$(curl --silent --write-out "%{http_code}" \
                --url "$DOWNLOAD_URL" \
                --output "$OUTPUT_FILE")

            echo "Export downloaded to $OUTPUT_FILE"

            EXTRACT_DIR="backup contact $(date +'%Y-%m-%d_%H-%M-%S')"
            mkdir -p "$EXTRACT_DIR"
            unzip -q "$OUTPUT_FILE" -d "$EXTRACT_DIR"

            DESKTOP_PATH="$HOME/Desktop/$EXTRACT_DIR"
            mv "$EXTRACT_DIR" "$DESKTOP_PATH"
            rm "$OUTPUT_FILE"
            rm -r "$EXTRACT_DIR"

            break

        elif [[ $STATUS == "CANCELED" ]]; then
            echo "Export was cancelled"
            break

        else
            echo $STATUS
        fi

        echo
        echo "Waiting for 10 secs before trying to call"
        sleep 10s
    done

fi
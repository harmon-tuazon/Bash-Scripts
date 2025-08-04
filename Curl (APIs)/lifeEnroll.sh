#!/bin/bash

# Author: Harmon Tuazon
# Purpose: This script will go through a given file path and find files based on a given extension
# Usage: just run ./lifeEnroll.sh

source .env


URL='https://api.hubapi.com/crm/v3/objects/products?limit=50&archived=false'

# Create a temporary file and ensure it gets cleaned up
response_file=$(mktemp)
trap 'rm -f "$response_file"' EXIT

api_call() {
    local method="${1:-GET}"
    local url="${2:-$URL}"
    local data="$3"
    local attempt="${4:-1}"
    local max_retries=3

    local curl_opts=(
    	-X "$method"
    	-H "Authorization: Bearer $HS_TOKEN3"
    	-H "Content-Type: application/json"
      --silent
      --show-error
      --write-out "%{http_code}"
      --output "$response_file"

     )

  # Add data if provided
  if [[ -n "$data" ]]; then
    curl_opts+=(-d "$data")
  fi

  # Execute the API call
  http_code=$(curl -s "${curl_opts[@]}" "$url" 2>&1)
  exit_code=$?

 
    if [[ $exit_code -ne 0 ]]; then
        echo "Curl failed with exit code: $exit_code" >&2
        cat "$response_file" >&2
        return exit_code=$?
    fi

    if [[ "$http_code" -lt 400 ]]; then
        return 0
    else
        if (( attempt < max_retries )); then
            echo "Attempt $attempt failed: HTTP $http_code" >&2
            echo "Server response:" >&2
            sleep "$attempt"
            api_call "$method" "$url" "$data" $((attempt + 1))
        else
            echo "Final attempt $attempt failed: HTTP $http_code" >&2
            return 1
        fi
    fi
}

api_call 
echo $? 

sleep 3

readarray -t names < <(jq -r '.results[].properties.name' "$response_file")

for name in "${names[@]}"; do
  echo "$name"
done




#!/usr/bin/env bash

# Get location details using ipinfo.io
LOCATION=$(curl -s ipinfo.io/json)
COUNTRY=$(echo "$LOCATION" | jq -r '.country')
REGION=$(echo "$LOCATION" | jq -r '.region')
CITY=$(echo "$LOCATION" | jq -r '.city')

# Print in table format using correct syntax for newlines
printf "%s\n" "$COUNTRY"
printf "%s\n" "$REGION"
printf "%s\n" "$CITY"

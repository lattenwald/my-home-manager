#!/usr/bin/env bash
# Fetch current location from IP and update gammastep config
# Usage: gammastep-update-location

set -euo pipefail

REPO_DIR="${HOME}/my-home-manager"
GUI_NIX="${REPO_DIR}/modules/gui.nix"

if [[ ! -f "$GUI_NIX" ]]; then
  echo "Error: ${GUI_NIX} not found" >&2
  exit 1
fi

# Query IP geolocation (ip-api.com is free, no key needed)
echo "Fetching location from IP..."
response=$(curl -s "http://ip-api.com/json/?fields=lat,lon,city,country,status,message")

status=$(echo "$response" | jq -r '.status')
if [[ "$status" != "success" ]]; then
  message=$(echo "$response" | jq -r '.message // "Unknown error"')
  echo "Error: Geolocation failed - ${message}" >&2
  exit 1
fi

lat=$(echo "$response" | jq -r '.lat')
lon=$(echo "$response" | jq -r '.lon')
city=$(echo "$response" | jq -r '.city')
country=$(echo "$response" | jq -r '.country')

echo "Detected location: ${city}, ${country}"
echo "Coordinates: ${lat}, ${lon}"

# Update gui.nix
sed -i "s/latitude = [0-9.-]*;/latitude = ${lat};/" "$GUI_NIX"
sed -i "s/longitude = [0-9.-]*;/longitude = ${lon};/" "$GUI_NIX"

echo "Updated ${GUI_NIX}"
echo ""
echo "Run 'make update' to apply changes, then restart gammastep:"
echo "  systemctl --user restart gammastep"

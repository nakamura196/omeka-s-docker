#!/bin/bash

# Ensure we're using bash
if [ -z "$BASH_VERSION" ]; then
    echo "This script requires bash. Please run with: bash $0"
    exit 1
fi

echo "=== Omeka S Modules Update Checker ==="

# Function to get latest release version from GitHub
get_latest_version() {
    local repo=$1
    curl -s "https://api.github.com/repos/${repo}/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# Function to check if version is newer
is_newer_version() {
    local current=$1
    local latest=$2
    
    # Remove 'v' prefix if present for comparison
    current_clean=$(echo $current | sed 's/^v//')
    latest_clean=$(echo $latest | sed 's/^v//')
    
    # Use version comparison
    if [ "$(printf '%s\n' "$current_clean" "$latest_clean" | sort -V | head -n1)" != "$latest_clean" ]; then
        return 0  # newer version available
    else
        return 1  # current version is latest or newer
    fi
}

echo "🔍 Checking for updates..."

# Current versions
current_common="3.4.59"
current_default="v1.8.0"
current_iiifserver="3.6.15"
current_imageserver="3.6.15"
current_universalviewer="3.6.11"

# Get latest versions
echo "Fetching latest versions from GitHub..."
latest_common=$(get_latest_version "Daniel-KM/Omeka-S-module-Common")
latest_default=$(get_latest_version "omeka-s-themes/default")
latest_iiifserver=$(get_latest_version "Daniel-KM/Omeka-S-module-IiifServer")
latest_imageserver=$(get_latest_version "Daniel-KM/Omeka-S-module-ImageServer")
latest_universalviewer=$(get_latest_version "Daniel-KM/Omeka-S-module-UniversalViewer")

echo ""
echo "📊 Version comparison:"
echo "┌─────────────────────┬─────────────┬─────────────┬────────────┐"
echo "│ Module/Theme        │ Current     │ Latest      │ Status     │"
echo "├─────────────────────┼─────────────┼─────────────┼────────────┤"

# Check each module/theme
printf "│ %-19s │ %-11s │ %-11s │" "Common" "$current_common" "$latest_common"
if is_newer_version "$current_common" "$latest_common"; then
    echo " 🔄 Update   │"
    updates_available=true
else
    echo " ✅ Latest   │"
fi

printf "│ %-19s │ %-11s │ %-11s │" "Default Theme" "$current_default" "$latest_default"
if is_newer_version "$current_default" "$latest_default"; then
    echo " 🔄 Update   │"
    updates_available=true
else
    echo " ✅ Latest   │"
fi

printf "│ %-19s │ %-11s │ %-11s │" "IiifServer" "$current_iiifserver" "$latest_iiifserver"
if is_newer_version "$current_iiifserver" "$latest_iiifserver"; then
    echo " 🔄 Update   │"
    updates_available=true
else
    echo " ✅ Latest   │"
fi

printf "│ %-19s │ %-11s │ %-11s │" "ImageServer" "$current_imageserver" "$latest_imageserver"
if is_newer_version "$current_imageserver" "$latest_imageserver"; then
    echo " 🔄 Update   │"
    updates_available=true
else
    echo " ✅ Latest   │"
fi

printf "│ %-19s │ %-11s │ %-11s │" "UniversalViewer" "$current_universalviewer" "$latest_universalviewer"
if is_newer_version "$current_universalviewer" "$latest_universalviewer"; then
    echo " 🔄 Update   │"
    updates_available=true
else
    echo " ✅ Latest   │"
fi

echo "└─────────────────────┴─────────────┴─────────────┴────────────┘"

if [ "$updates_available" = true ]; then
    echo ""
    echo "🔄 Updates available! Would you like to update install-modules.sh script?"
    read -p "Update script with latest versions? (y/N): " update_choice
    
    if [[ $update_choice =~ ^[Yy]$ ]]; then
        # Update the install script with latest versions
        sed -i.bak \
            -e "s/version_common=.*/version_common=${latest_common}/" \
            -e "s/version_default=.*/version_default=${latest_default}/" \
            -e "s/version_iiifserver=.*/version_iiifserver=${latest_iiifserver}/" \
            -e "s/version_imageserver=.*/version_imageserver=${latest_imageserver}/" \
            -e "s/version_universalviewer=.*/version_universalviewer=${latest_universalviewer}/" \
            install-modules.sh
        
        echo "✅ install-modules.sh updated with latest versions!"
        echo "📝 Backup saved as install-modules.sh.bak"
        echo ""
        echo "🚀 Run ./install-modules.sh to install/update modules"
    fi
else
    echo ""
    echo "✅ All modules and themes are up to date!"
fi

echo ""
echo "💡 Tip: Run this script periodically to check for updates"
#!/usr/bin/env bash
#
# Update Argo Workflows CRDs from upstream
#
# Usage: ./scripts/update-argo-workflows-crds.sh <version>
# Example: ./scripts/update-argo-workflows-crds.sh v3.7.4
#

set -euo pipefail

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v3.7.4"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRD_DIR="$REPO_ROOT/charts/argo-workflows/files/crds"

UPSTREAM_BASE_URL="https://raw.githubusercontent.com/argoproj/argo-workflows/${VERSION}/manifests/base/crds"

# Function to get CRD file list from GitHub API
get_crd_files() {
    local api_url="https://api.github.com/repos/argoproj/argo-workflows/contents/manifests/base/crds/minimal?ref=${VERSION}"

    curl -sSfL "$api_url" | jq -r '.[] | select(.name | test("^argoproj\\.io_.*\\.yaml$")) | .name'
}

# Function to process a CRD file:
# - Remove the "auto-generated" comment line
# - Add helm.sh/resource-policy annotation
# - Ensure 'name:' comes before 'annotations:' in metadata
process_crd() {
    local file="$1"
    local tmp_file="${file}.tmp"

    # Remove the auto-generated comment line if present
    sed -i '/^# This is an auto-generated file/d' "$file"

    awk '
    BEGIN { in_metadata = 0; name_line = ""; has_annotations = 0 }
    /^metadata:$/ {
        in_metadata = 1
        print
        next
    }
    in_metadata && /^  name:/ {
        name_line = $0
        next
    }
    in_metadata && /^[^ ]/ {
        # End of metadata block
        in_metadata = 0
        # If we still have a name_line, annotations block was not present
        if (name_line != "") {
            print name_line
            print "  annotations:"
            print "    helm.sh/resource-policy: keep"
            name_line = ""
        }
    }
    { print }
    ' "$file" > "$tmp_file" && mv "$tmp_file" "$file"
}

# Function to download and process the minimal CRDs
download_crds() {
    local dest_dir="$CRD_DIR/minimal"

    echo "Downloading minimal CRDs for Argo Workflows $VERSION..."

    mkdir -p "$dest_dir"

    # Clean existing CRD files before downloading in case upstream have deleted a CRD
    rm -f "$dest_dir"/*.yaml

    # Get file list dynamically from GitHub API
    local crd_files
    crd_files=$(get_crd_files)

    if [[ -z "$crd_files" ]]; then
        echo "  Error: Failed to fetch CRD file list"
        return 1
    fi

    while IFS= read -r crd_file; do
        local url="$UPSTREAM_BASE_URL/minimal/$crd_file"
        local dest="$dest_dir/$crd_file"

        echo "  Downloading $crd_file..."
        if ! curl -sSfL "$url" -o "$dest"; then
            echo "    Warning: Failed to download $crd_file"
            rm -f "$dest"
            continue
        fi

        process_crd "$dest"
        echo "    Downloaded and processed $crd_file"
    done <<< "$crd_files"
}

echo "Updating Argo Workflows CRDs to $VERSION"
echo "========================================="

# Only the minimal CRDs are kept in this repo. The full CRDs are installed from
# the upstream argo-workflows-crdinstaller image, which carries its own copy.
download_crds

echo ""
echo "Done! CRDs updated to $VERSION"
echo ""
echo "Files updated in:"
echo "  - $CRD_DIR/minimal/"

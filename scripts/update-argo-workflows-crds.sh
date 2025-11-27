#!/usr/bin/env bash
#
# Update Argo Workflows CRDs from upstream
#
# Usage: ./scripts/update-argo-workflows-crds.sh <version>
# Example: ./scripts/update-argo-workflows-crds.sh v3.7.4
#

set -euo pipefail

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

# List of CRD files to download
CRD_FILES=(
    "argoproj.io_clusterworkflowtemplates.yaml"
    "argoproj.io_cronworkflows.yaml"
    "argoproj.io_workflowartifactgctasks.yaml"
    "argoproj.io_workfloweventbindings.yaml"
    "argoproj.io_workflows.yaml"
    "argoproj.io_workflowtaskresults.yaml"
    "argoproj.io_workflowtasksets.yaml"
    "argoproj.io_workflowtemplates.yaml"
)

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

# Function to download and process CRDs for a specific type (full or minimal)
download_crds() {
    local type="$1"
    local dest_dir="$CRD_DIR/$type"

    echo "Downloading $type CRDs for Argo Workflows $VERSION..."

    mkdir -p "$dest_dir"

    for crd_file in "${CRD_FILES[@]}"; do
        local url="$UPSTREAM_BASE_URL/$type/$crd_file"
        local dest="$dest_dir/$crd_file"

        echo "  Downloading $crd_file..."
        if ! curl -sSfL "$url" -o "$dest"; then
            echo "    Warning: Failed to download $crd_file (may not exist for $type)"
            rm -f "$dest"
            continue
        fi

        process_crd "$dest"
        echo "    Downloaded and processed $crd_file"
    done
}

echo "Updating Argo Workflows CRDs to $VERSION"
echo "========================================="

# Download both full and minimal CRDs
download_crds "full"
download_crds "minimal"

echo ""
echo "Done! CRDs updated to $VERSION"
echo ""
echo "Files updated in:"
echo "  - $CRD_DIR/full/"
echo "  - $CRD_DIR/minimal/"

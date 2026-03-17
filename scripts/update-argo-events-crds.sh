#!/usr/bin/env bash
#
# Update Argo Events CRDs from upstream
#
# Usage: ./scripts/update-argo-events-crds.sh <version>
# Example: ./scripts/update-argo-events-crds.sh v1.9.10
#

set -euo pipefail

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.9.10"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRD_DIR="$REPO_ROOT/charts/argo-events/templates/crds"

UPSTREAM_BASE_URL="https://raw.githubusercontent.com/argoproj/argo-events/${VERSION}/manifests/base/crds"

# Function to get CRD file list from GitHub API
get_crd_files() {
    local api_url="https://api.github.com/repos/argoproj/argo-events/contents/manifests/base/crds?ref=${VERSION}"

    curl -sSfL "$api_url" | jq -r '.[] | select(.name | test("^argoproj\\.io_.*\\.yaml$")) | .name'
}

# Convert upstream filename to local template filename
# e.g., "argoproj.io_eventbus.yaml" -> "eventbus-crd.yml"
to_local_filename() {
    local upstream_name="$1"
    local base="${upstream_name#argoproj.io_}"
    echo "${base%.yaml}-crd.yml"
}

# Process a downloaded CRD into a Helm template:
# - Remove the "auto-generated" comment line
# - Wrap in {{- if .Values.crds.install }} conditional
# - Add helm.sh/resource-policy annotation and custom annotation support
# - Ensure 'name:' comes before 'annotations:' in metadata
process_crd() {
    local src_file="$1"
    local dest_file="$2"

    {
        cat <<'HEADER'
{{- if .Values.crds.install }}
HEADER

        # Remove leading "---" if present, then process the YAML
        sed '/^---$/d' "$src_file" | awk '
        BEGIN { state = "init"; name_line = "" }

        # Skip auto-generated comment
        /^# This is an auto-generated file/ { next }

        state == "init" && /^metadata:$/ {
            state = "meta"
            print
            next
        }

        # In metadata, capture name line
        state == "meta" && /^  name:/ {
            name_line = $0
            next
        }

        # Skip upstream annotations section
        state == "meta" && /^  annotations:$/ { state = "anno"; next }
        state == "anno" && /^    / { next }
        state == "anno" && !/^    / { state = "meta" }

        # Skip upstream labels section
        state == "meta" && /^  labels:$/ { state = "labels"; next }
        state == "labels" && /^    / { next }
        state == "labels" && !/^    / { state = "meta" }

        # End of metadata block - emit name and annotations
        state == "meta" && /^[^ ]/ {
            if (name_line != "") {
                print name_line
            }
            print "  annotations:"
            print "    {{- if .Values.crds.keep }}"
            print "    \"helm.sh/resource-policy\": keep"
            print "    {{- end }}"
            print "    {{- with .Values.crds.annotations }}"
            print "      {{- toYaml . | nindent 4 }}"
            print "    {{- end }}"
            state = "done"
        }

        # Default: print everything else
        { print }
        '

        echo "{{- end }}"
    } > "$dest_file"
}

echo "Updating Argo Events CRDs to $VERSION"
echo "======================================="

mkdir -p "$CRD_DIR"

# Clean existing CRD files before downloading in case upstream have deleted a CRD
rm -f "$CRD_DIR"/*-crd.yml

# Get file list dynamically from GitHub API
crd_files=$(get_crd_files)

if [[ -z "$crd_files" ]]; then
    echo "  Error: Failed to fetch CRD file list"
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

while IFS= read -r crd_file; do
    local_name=$(to_local_filename "$crd_file")
    url="$UPSTREAM_BASE_URL/$crd_file"
    tmp_file="$TMP_DIR/$crd_file"
    dest="$CRD_DIR/$local_name"

    echo "  Downloading $crd_file -> $local_name..."
    if ! curl -sSfL "$url" -o "$tmp_file"; then
        echo "    Warning: Failed to download $crd_file"
        continue
    fi

    process_crd "$tmp_file" "$dest"
    echo "    Downloaded and processed $local_name"
done <<< "$crd_files"

echo ""
echo "Done! CRDs updated to $VERSION"
echo ""
echo "Files updated in:"
echo "  - $CRD_DIR/"

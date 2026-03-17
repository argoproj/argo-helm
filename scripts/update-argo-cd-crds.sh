#!/usr/bin/env bash
#
# Update Argo CD CRDs from upstream
#
# Usage: ./scripts/update-argo-cd-crds.sh <version>
# Example: ./scripts/update-argo-cd-crds.sh v3.3.4
#

set -euo pipefail

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v3.3.4"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRD_DIR="$REPO_ROOT/charts/argo-cd/templates/crds"

UPSTREAM_BASE_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${VERSION}/manifests/crds"

# Function to get CRD file list from GitHub API
get_crd_files() {
    local api_url="https://api.github.com/repos/argoproj/argo-cd/contents/manifests/crds?ref=${VERSION}"

    curl -sSfL "$api_url" | jq -r '.[] | select(.name | test(".*-crd\\.yaml$")) | .name'
}

# Convert upstream filename to local template filename
# e.g., "application-crd.yaml" -> "crd-application.yaml"
to_local_filename() {
    local upstream_name="$1"
    echo "crd-${upstream_name%-crd.yaml}.yaml"
}

# Process a downloaded CRD into a Helm template:
# - Wrap in {{- if .Values.crds.install }} conditional
# - Add argocd.argoproj.io/sync-options and helm.sh/resource-policy annotations
# - Add Helm template directives for custom annotations and labels
process_crd() {
    local src_file="$1"
    local dest_file="$2"

    {
        cat <<'HEADER'
{{- if .Values.crds.install }}
HEADER

        # Remove leading "---" if present, then process the YAML
        sed '/^---$/d' "$src_file" | awk '
        BEGIN { state = "init" }

        state == "init" && /^metadata:$/ {
            state = "meta"
            print "metadata:"
            print "  annotations:"
            print "    argocd.argoproj.io/sync-options: ServerSideApply=true"
            print "    {{- if .Values.crds.keep }}"
            print "    \"helm.sh/resource-policy\": keep"
            print "    {{- end }}"
            print "    {{- with .Values.crds.annotations }}"
            print "      {{- toYaml . | nindent 4 }}"
            print "    {{- end }}"
            next
        }

        # Skip upstream annotations section
        state == "meta" && /^  annotations:$/ { state = "anno"; next }
        state == "anno" && /^    / { next }
        state == "anno" && !/^    / { state = "meta" }

        # Handle labels section - keep upstream labels, add Helm template for extras
        state == "meta" && /^  labels:$/ { state = "labels"; print; next }
        state == "labels" && /^    / { print; next }
        state == "labels" && !/^    / {
            print "    {{- with .Values.crds.additionalLabels }}"
            print "      {{- toYaml . | nindent 4}}"
            print "    {{- end }}"
            state = "done"
        }

        # Handle name line when there are no labels
        state == "meta" && /^  name:/ { state = "done" }

        # Default: print everything else
        { print }
        '

        echo "{{- end }}"
    } > "$dest_file"
}

echo "Updating Argo CD CRDs to $VERSION"
echo "=================================="

mkdir -p "$CRD_DIR"

# Clean existing CRD files before downloading in case upstream have deleted a CRD
rm -f "$CRD_DIR"/crd-*.yaml

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

#!/usr/bin/env bash
#
# Update Argo Rollouts CRDs from upstream
#
# Usage: ./scripts/update-argo-rollouts-crds.sh <version>
# Example: ./scripts/update-argo-rollouts-crds.sh v1.8.4
#

set -euo pipefail

if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.8.4"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRD_DIR="$REPO_ROOT/charts/argo-rollouts/templates/crds"

UPSTREAM_BASE_URL="https://raw.githubusercontent.com/argoproj/argo-rollouts/${VERSION}/manifests/crds"

# Function to get CRD file list from GitHub API
get_crd_files() {
    local api_url="https://api.github.com/repos/argoproj/argo-rollouts/contents/manifests/crds?ref=${VERSION}"

    curl -sSfL "$api_url" | jq -r '.[] | select(.name | test(".*-crd\\.yaml$")) | .name'
}

# Process a downloaded CRD into a Helm template:
# - Wrap in {{- if .Values.installCRDs }} conditional
# - Preserve upstream annotations (e.g. controller-gen.kubebuilder.io/version)
# - Add helm.sh/resource-policy and custom annotation support
# - Add app.kubernetes.io labels
process_crd() {
    local src_file="$1"
    local dest_file="$2"
    local crd_name
    crd_name=$(awk '/^  name:/ { print $2; exit }' "$src_file")

    {
        cat <<'HEADER'
{{- if .Values.installCRDs }}
HEADER

        # Remove leading "---" if present, then process the YAML
        sed '/^---$/d' "$src_file" | awk -v crd_name="$crd_name" '
        BEGIN { state = "init" }

        state == "init" && /^metadata:$/ {
            state = "meta"
            print "metadata:"
            print "  annotations:"
            next
        }

        # Inside upstream annotations block - print them, then append Helm directives
        state == "meta" && /^  annotations:$/ { state = "anno"; next }
        state == "anno" && /^    / { print; next }
        state == "anno" && !/^    / {
            # End of upstream annotations, add Helm annotation directives
            print "    {{- if .Values.keepCRDs }}"
            print "    \"helm.sh/resource-policy\": keep"
            print "    {{- end }}"
            print "    {{- if .Values.crdAnnotations }}"
            print "    {{- toYaml .Values.crdAnnotations | nindent 4 }}"
            print "    {{- end }}"
            print "  labels:"
            print "    app.kubernetes.io/name: argo-rollouts"
            print "    app.kubernetes.io/part-of: argo-rollouts"
            state = "done"
        }

        # Handle labels section if upstream ever adds one - keep upstream labels
        state == "meta" && /^  labels:$/ { state = "labels"; print; next }
        state == "labels" && /^    / { print; next }
        state == "labels" && !/^    / { state = "done" }

        # Handle name line when there are no annotations or labels
        state == "meta" && /^  name:/ {
            print "  annotations:"
            print "    {{- if .Values.keepCRDs }}"
            print "    \"helm.sh/resource-policy\": keep"
            print "    {{- end }}"
            print "    {{- if .Values.crdAnnotations }}"
            print "    {{- toYaml .Values.crdAnnotations | nindent 4 }}"
            print "    {{- end }}"
            print "  labels:"
            print "    app.kubernetes.io/name: argo-rollouts"
            print "    app.kubernetes.io/part-of: argo-rollouts"
            state = "done"
        }

        # Default: print everything else
        { print }
        '

        echo "{{- end }}"
    } > "$dest_file"
}

echo "Updating Argo Rollouts CRDs to $VERSION"
echo "========================================="

mkdir -p "$CRD_DIR"

# Clean existing CRD files before downloading in case upstream have deleted a CRD
rm -f "$CRD_DIR"/*-crd.yaml

# Get file list dynamically from GitHub API
crd_files=$(get_crd_files)

if [[ -z "$crd_files" ]]; then
    echo "  Error: Failed to fetch CRD file list"
    exit 1
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

while IFS= read -r crd_file; do
    url="$UPSTREAM_BASE_URL/$crd_file"
    tmp_file="$TMP_DIR/$crd_file"
    dest="$CRD_DIR/$crd_file"

    echo "  Downloading $crd_file..."
    if ! curl -sSfL "$url" -o "$tmp_file"; then
        echo "    Warning: Failed to download $crd_file"
        continue
    fi

    process_crd "$tmp_file" "$dest"
    echo "    Downloaded and processed $crd_file"
done <<< "$crd_files"

echo ""
echo "Done! CRDs updated to $VERSION"
echo ""
echo "Files updated in:"
echo "  - $CRD_DIR/"

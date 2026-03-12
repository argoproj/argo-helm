#!/usr/bin/env bash
#
# Update Argo CD Image Updater CRDs from upstream
#
# Usage: ./scripts/update-argocd-image-updater-crds.sh <version>
# Example: ./scripts/update-argocd-image-updater-crds.sh v1.1.0
#

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.1.0"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CRD_TEMPLATE="$REPO_ROOT/charts/argocd-image-updater/templates/crd-imageupdaters.yaml"

UPSTREAM_URL="https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/${VERSION}/config/crd/bases/argocd-image-updater.argoproj.io_imageupdaters.yaml"

echo "Updating Argo CD Image Updater CRDs to $VERSION"
echo "================================================="

# Download upstream CRD
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

echo "  Downloading CRD from upstream..."
if ! curl -sSfL "$UPSTREAM_URL" -o "$TMP_FILE"; then
    echo "  Error: Failed to download CRD from $UPSTREAM_URL"
    exit 1
fi

# Build the Helm-wrapped CRD template
# - Add Helm conditional and templated metadata
# - Append the spec section from upstream as-is
# - Close with Helm end tag
echo "  Generating Helm template..."

{
    cat <<'HEADER'
{{- if .Values.crds.install }}
HEADER

    # Remove leading "---" if present, then process the YAML
    sed '/^---$/d' "$TMP_FILE" | awk '
    BEGIN { in_metadata = 0; printed_metadata = 0 }
    /^apiVersion:/ { print; next }
    /^kind:/ { print; next }
    /^metadata:$/ {
        in_metadata = 1
        print "metadata:"
        print "  annotations:"
        next
    }
    in_metadata && /^  annotations:$/ { next }
    in_metadata && /^    / {
        # Print upstream annotations (e.g. controller-gen.kubebuilder.io/version)
        print $0
        next
    }
    in_metadata && /^  name:/ {
        # Insert Helm template annotations/labels after upstream annotations, before name
        print "    {{- if .Values.crds.keep }}"
        print "    \"helm.sh/resource-policy\": keep"
        print "    {{- end }}"
        print "    {{- with .Values.crds.annotations }}"
        print "      {{- toYaml . | nindent 4 }}"
        print "    {{- end }}"
        print "  {{- with .Values.crds.additionalLabels }}"
        print "  labels:"
        print "    {{- toYaml . | nindent 4}}"
        print "  {{- end }}"
        print $0
        in_metadata = 0
        printed_metadata = 1
        next
    }
    { print }
    '

    echo "{{- end }}"
} > "$CRD_TEMPLATE"

echo ""
echo "Done! CRD updated to $VERSION"
echo "  - $CRD_TEMPLATE"

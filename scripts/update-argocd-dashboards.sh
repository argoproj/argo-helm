#!/usr/bin/env bash
#
# Update ArgoCD Grafana dashboard from upstream
#
# Usage: ./scripts/update-argocd-dashboards.sh <version>
# Example: ./scripts/update-argocd-dashboards.sh v3.4.0
#

set -euo pipefail

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v3.4.0"
    exit 1
fi

# Ensure version starts with 'v'
if [[ ! "$VERSION" =~ ^v ]]; then
    VERSION="v${VERSION}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DASHBOARD_DIR="$REPO_ROOT/charts/argo-cd/files/grafana-dashboards"
DASHBOARD_FILE="$DASHBOARD_DIR/argocd.json"

UPSTREAM_URL="https://raw.githubusercontent.com/argoproj/argo-cd/${VERSION}/examples/dashboard.json"

echo "Updating ArgoCD Grafana dashboard to $VERSION"
echo "================================================="

# Create directory if it doesn't exist
mkdir -p "$DASHBOARD_DIR"

# Download upstream dashboard
TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

echo "  Downloading dashboard from upstream..."
if ! curl -sSfL "$UPSTREAM_URL" -o "$TMP_FILE"; then
    echo "  Error: Failed to download dashboard from $UPSTREAM_URL"
    exit 1
fi

# Verify it looks like JSON (starts with `{`)
if [[ ! -s "$TMP_FILE" ]] || [[ "$(head -c 1 "$TMP_FILE")" != "{" ]]; then
    echo "  Error: Downloaded file is not valid JSON"
    exit 1
fi

# Copy to dashboard directory
cp "$TMP_FILE" "$DASHBOARD_FILE"

echo ""
echo "Done! Dashboard updated to $VERSION"
echo "  - $DASHBOARD_FILE"
echo ""
echo "Please run 'helm dependency build' and commit the changes."

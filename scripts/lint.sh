#!/usr/bin/env bash
# This script runs the chart-testing tool locally. It simulates the linting that is also done by the github action. Run this without any errors before pushing.
# Reference: https://github.com/helm/chart-testing
set -eux

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Note: Also update in .github/workflows/lint-and-test.yml
CT_VERSION=v3.14.0
HELM_VERSION=v4.2.3

# The chart-testing image ships its own Helm 3 binary, so install the Helm version used by CI before linting.
echo -e "\n-- Linting all Helm Charts --\n"
docker run \
     -v "$SRCROOT:/workdir" \
     --entrypoint /bin/sh \
     "quay.io/helmpack/chart-testing:${CT_VERSION}" \
     -c "arch=\$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/') \
         && curl -sSfL \"https://get.helm.sh/helm-${HELM_VERSION}-linux-\${arch}.tar.gz\" | tar -xz -C /tmp \
         && rm -f /usr/local/bin/helm \
         && mv \"/tmp/linux-\${arch}/helm\" /usr/local/bin/helm \
         && git config --global --add safe.directory /workdir \
         && cd /workdir \
         && ct lint --config .github/configs/ct-lint.yaml --lint-conf .github/configs/lintconf.yaml --debug"

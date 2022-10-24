#!/bin/bash
# This script runs the chart-testing tool locally. It simulates the linting that is also done by the github action. Run this without any errors before pushing.
# Reference: https://github.com/helm/chart-testing
set -eux

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo -e "\n-- Linting all Helm Charts --\n"
docker run \
     -v "$SRCROOT:/workdir" \
     --entrypoint /bin/sh \
     quay.io/helmpack/chart-testing:v3.7.1 \
     -c cd /workdir \
     ct lint \
     --config .github/configs/ct-lint.yaml \
     --lint-conf .github/configs/lintconf.yaml \
     --debug

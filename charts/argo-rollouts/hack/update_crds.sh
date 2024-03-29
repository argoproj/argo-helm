#!/bin/bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ $(uname -s) = "Darwin" ]]; then
    VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion: //g')"
else
    VERSION="$(grep ^appVersion "${SCRIPT_DIR}/../Chart.yaml" | sed 's/appVersion:\s//g')"
fi

FILES=(
  "analysis-run-crd.yaml              : analysis-run-crd.yaml"
  "analysis-template-crd.yaml         : analysis-template-crd.yaml"
  "cluster-analysis-template-crd.yaml : cluster-analysis-template-crd.yaml"
  "experiment-crd.yaml                : experiment-crd.yaml"
  "rollout-crd.yaml                   : rollout-crd.yaml"
)

for line in "${FILES[@]}"; do
    DESTINATION=$(echo "${line%%:*}" | xargs)
    SOURCE=$(echo "${line##*:}" | xargs)

    URL="https://raw.githubusercontent.com/argoproj/argo-rollouts/$VERSION/manifests/crds/$SOURCE"

    echo -e "Downloading Prometheus Operator CRD with Version ${VERSION}:\n${URL}\n"

    echo "# ${URL}" > "${SCRIPT_DIR}/../templates/crds/${DESTINATION}"

    if ! curl --silent --retry-all-errors --fail --location "${URL}" >> "${SCRIPT_DIR}/../templates/crds/${DESTINATION}"; then
      echo -e "Failed to download ${URL}!"
      exit 1
    fi
done
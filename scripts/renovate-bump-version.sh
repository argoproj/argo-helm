#!/bin/bash
depName="${1}"
if [ -z "${depName}" ]; then
  echo "Missing argument 'depName'" >&2
  echo "Example usage: $0 argoproj/argo-cd" >&2
  exit 1
fi

chartName=$(echo "$depName" | sed -e "s+^argoproj/++" -e "s+^argoproj-labs/++")
echo "Changed chart name is: $chartName"
echo "----------------------------------------"

parentDir="charts/${chartName}"

# Bump the chart version by one patch version
version=$(grep '^version:' "${parentDir}/Chart.yaml" | awk '{print $2}')
major=$(echo "${version}" | cut -d. -f1)
minor=$(echo "${version}" | cut -d. -f2)
patch=$(echo "${version}" | cut -d. -f3)
patch=$((patch + 1))
sed -i "s/^version:.*/version: ${major}.${minor}.${patch}/g" "${parentDir}/Chart.yaml"

# Add a changelog entry
appVersion=$(grep '^appVersion:' "${parentDir}/Chart.yaml" | awk '{print $2}')
sed -i -e '/^  artifacthub.io\/changes: |/,$ d' "${parentDir}/Chart.yaml"
{
  echo "  artifacthub.io/changes: |"
  echo "    - kind: changed"
  echo "      description: Bump ${chartName} to ${appVersion}"
} >> "${parentDir}/Chart.yaml"
cat "${parentDir}/Chart.yaml"

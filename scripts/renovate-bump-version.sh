#!/usr/bin/env bash
while getopts c:d:v: opt; do
  case ${opt} in
    c) chart=${OPTARG} ;;
    d) dependency_name=${OPTARG} ;;
    v) dependency_version=${OPTARG} ;;
    *)
      echo 'Usage:' >&2
      echo '-c: chart       Related Helm chart name' >&2
      echo '-d  dependency  Name of the updated dependency' >&2
      echo '-v  version     New version of the updated dependency' >&2
      exit 1
  esac
done

if [ -z "${dependency_name}" ] || [ -z "${dependency_version}" ] || [ -z "${chart}" ] ; then
  echo 'Missing relevant CLI flag(s).' >&2
  exit 1
fi

chart_yaml_path="charts/${chart}/Chart.yaml"
# Split dependency by '/' and only use last element
# This way we can drop prefixes like "argoproj/..." , "argoproj-labs/..." , "quay.io/foo/..."
dependency_name="${dependency_name##*/}"

# Bump the chart version by one patch version
version=$(grep '^version:' "${chart_yaml_path}" | awk '{print $2}')
major=$(echo "${version}" | cut -d. -f1)
minor=$(echo "${version}" | cut -d. -f2)
patch=$(echo "${version}" | cut -d. -f3)
patch=$((patch + 1))
sed -i "s/^version:.*/version: ${major}.${minor}.${patch}/g" "${chart_yaml_path}"

# Add a changelog entry
sed -i -e '/^  artifacthub.io\/changes: |/,$ d' "${chart_yaml_path}"
{
  echo "  artifacthub.io/changes: |"
  echo "    - kind: changed"
  echo "      description: Bump ${dependency_name} to ${dependency_version}"
} >> "${chart_yaml_path}"
cat "${chart_yaml_path}"

# If the dependency is argo-workflows, also update CRDs
if [[ "$dependency_name" == "argo-workflows" ]]; then
  "$(dirname "$0")/update-argo-workflows-crds.sh" "$dependency_version"
fi

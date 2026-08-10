#!/usr/bin/env bash
while getopts c:d:v:t: opt; do
  case ${opt} in
    c) chart=${OPTARG} ;;
    d) dependency_name=${OPTARG} ;;
    v) dependency_version=${OPTARG} ;;
    t) update_type=${OPTARG} ;;
    *)
      echo 'Usage:' >&2
      echo '-c: chart       Related Helm chart name' >&2
      echo '-d  dependency  Name of the updated dependency' >&2
      echo '-v  version     New version of the updated dependency' >&2
      echo '-t  type        Renovate update type (major, minor, patch)' >&2
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

# Map the upstream update type for the main application of each chart:
# upstream major/minor -> chart minor, upstream patch -> chart patch (per CONTRIBUTING.md).
# Chart major bumps stay manual since they require an Upgrading section in the README.
# Auxiliary images (dex, redis, kubectl, ...) always bump the chart patch version.
main_apps='argo-cd argo-workflows argo-events argo-rollouts argocd-image-updater'
if [[ " ${main_apps} " != *" ${dependency_name} "* ]]; then
  update_type='patch'
fi

# Bump the chart version according to the update type
version=$(grep '^version:' "${chart_yaml_path}" | awk '{print $2}')
major=$(echo "${version}" | cut -d. -f1)
minor=$(echo "${version}" | cut -d. -f2)
patch=$(echo "${version}" | cut -d. -f3)
case "${update_type}" in
  major|minor) minor=$((minor + 1)); patch=0 ;;
  *) patch=$((patch + 1)) ;;
esac
sed -i "s/^version:.*/version: ${major}.${minor}.${patch}/g" "${chart_yaml_path}"

# Add a changelog entry
sed -i -e '/^  artifacthub.io\/changes: |/,$ d' "${chart_yaml_path}"
{
  echo "  artifacthub.io/changes: |"
  echo "    - kind: changed"
  echo "      description: Bump ${dependency_name} to ${dependency_version}"
} >> "${chart_yaml_path}"
cat "${chart_yaml_path}"

# Update CRDs if a matching script exists
crd_script="$(dirname "$0")/update-${dependency_name}-crds.sh"
if [[ -x "$crd_script" ]]; then
  "$crd_script" "$dependency_version"
fi

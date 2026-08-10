#!/usr/bin/env bash
while getopts c:d:o:v: opt; do
  case ${opt} in
    c) chart=${OPTARG} ;;
    d) dependency_name=${OPTARG} ;;
    o) dependency_old_version=${OPTARG} ;;
    v) dependency_version=${OPTARG} ;;
    *)
      echo 'Usage:' >&2
      echo '-c: chart       Related Helm chart name' >&2
      echo '-d  dependency  Name of the updated dependency' >&2
      echo '-o  old version Previous version of the updated dependency (optional)' >&2
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

# Strip a leading "v" as well as pre-release and build metadata,
# e.g. "v3.5.0-rc1" becomes "3.5.0"
normalize_version() {
  local version="${1#v}"
  version="${version%%-*}"
  echo "${version%%+*}"
}

# Determine how much of the chart version has to be bumped.
# The chart's main application propagates its own bump level to the chart, so a
# major or minor application update is not hidden behind a chart patch release.
# Sidecars and other dependencies (Dex, Redis, kubectl, ...) always stay on patch.
bump_level='patch'
if [ "${dependency_name}" = "${chart}" ] && [ -n "${dependency_old_version}" ]; then
  old_version=$(normalize_version "${dependency_old_version}")
  new_version=$(normalize_version "${dependency_version}")
  if [[ "${old_version}" =~ ^([0-9]+)\.([0-9]+) ]]; then
    old_major="${BASH_REMATCH[1]}"
    old_minor="${BASH_REMATCH[2]}"
    if [[ "${new_version}" =~ ^([0-9]+)\.([0-9]+) ]]; then
      new_major="${BASH_REMATCH[1]}"
      new_minor="${BASH_REMATCH[2]}"
      if [ "${new_major}" -gt "${old_major}" ]; then
        bump_level='major'
      elif [ "${new_major}" -eq "${old_major}" ] && [ "${new_minor}" -gt "${old_minor}" ]; then
        bump_level='minor'
      fi
    fi
  fi
fi

# Bump the chart version according to the determined bump level
version=$(grep '^version:' "${chart_yaml_path}" | awk '{print $2}')
major=$(echo "${version}" | cut -d. -f1)
minor=$(echo "${version}" | cut -d. -f2)
patch=$(echo "${version}" | cut -d. -f3)
case "${bump_level}" in
  major)
    major=$((major + 1))
    minor=0
    patch=0
    ;;
  minor)
    minor=$((minor + 1))
    patch=0
    ;;
  *)
    patch=$((patch + 1))
    ;;
esac
echo "Bumping ${chart} chart from ${version} to ${major}.${minor}.${patch} (${bump_level})"
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

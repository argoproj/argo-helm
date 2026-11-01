#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/lint-changelog.sh [base ref, default origin/main]

base="${1:-origin/main}"
rc=0

error() {
  echo "::error file=$1::$2"
  rc=1
}

for chart in $(git diff --name-only "${base}...HEAD" -- charts | cut -d / -f 2 | sort -u); do
  dir="charts/${chart}"
  [[ -f "${dir}/Chart.yaml" ]] || continue

  mapfile -t fragments < <(git diff --name-only --diff-filter=A "${base}...HEAD" -- "${dir}/changes/*.yaml")
  if [[ ${#fragments[@]} -ne 1 ]]; then
    error "${dir}/Chart.yaml" "${chart}: add exactly one change fragment in ${dir}/changes/, found ${#fragments[@]}. See CONTRIBUTING.md#changelog."
  elif ! yq '.' "${fragments[0]}" > /dev/null 2>&1; then
    error "${fragments[0]}" "not valid YAML. Quote the description if it contains ': ' or ' #'."
  else
    fragment="${fragments[0]}"
    yq -e '.bump | test("^(major|minor|patch)$")' "${fragment}" > /dev/null 2>&1 \
      || error "${fragment}" "bump must be major, minor or patch."
    yq -e '.kind | test("^(added|changed|deprecated|removed|fixed|security)$")' "${fragment}" > /dev/null 2>&1 \
      || error "${fragment}" "kind must be added, changed, deprecated, removed, fixed or security."
    yq -e '.description | tag == "!!str" and length > 0' "${fragment}" > /dev/null 2>&1 \
      || error "${fragment}" "description must be a non-empty string."
  fi

  if git diff "${base}...HEAD" -- "${dir}/Chart.yaml" | grep -qE '^[-+](version:|  artifacthub\.io/changes:|    - kind:|      description:)'; then
    error "${dir}/Chart.yaml" "${chart}: leave version and artifacthub.io/changes alone. The publish workflow writes them after merge."
  fi

  if git diff "${base}...HEAD" -- "${dir}/README.md.gotmpl" | grep -qE '^\+### [0-9]+\.[0-9]+\.[0-9]+'; then
    error "${dir}/README.md.gotmpl" "${chart}: title a new Upgrading section '### NEXT'. It gets its version number when the pull request merges."
  fi
done

if [[ "$rc" -eq 0 ]]; then
  echo "Change fragments are valid ✔"
fi

exit $rc

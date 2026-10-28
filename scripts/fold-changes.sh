#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

for changes_dir in charts/*/changes; do
  fragments=("${changes_dir}"/*.yaml)
  [[ ${#fragments[@]} -gt 0 ]] || continue
  chart_dir="${changes_dir%/changes}"
  chart_yaml="${chart_dir}/Chart.yaml"

  bumps=$(yq ea -N '.bump' "${fragments[@]}")
  IFS=. read -r major minor patch <<< "$(yq '.version' "${chart_yaml}")"
  if grep -qx major <<< "${bumps}"; then
    major=$((major + 1)); minor=0; patch=0
  elif grep -qx minor <<< "${bumps}"; then
    minor=$((minor + 1)); patch=0
  else
    patch=$((patch + 1))
  fi
  version="${major}.${minor}.${patch}"

  sed -i "s/^version:.*/version: ${version}/" "${chart_yaml}"
  # The changes annotation is the last key in every Chart.yaml.
  sed -i '/^  artifacthub.io\/changes: |/,$ d' "${chart_yaml}"
  {
    echo "  artifacthub.io/changes: |"
    yq ea '[{"kind": .kind, "description": .description}]' "${fragments[@]}" | sed 's/^/    /'
  } >> "${chart_yaml}"

  # helm-docs copies the heading into README.md verbatim, so both files get the same edit.
  sed -i "s/^### NEXT$/### ${version}/" "${chart_dir}/README.md.gotmpl" "${chart_dir}/README.md"

  rm "${fragments[@]}"
  echo "${chart_dir}: ${version}"
done

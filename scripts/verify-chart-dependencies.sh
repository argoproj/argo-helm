#!/usr/bin/env bash
# Verifies downloaded chart dependency archives against pinned sha256 digests.
#
# Run after `helm dependency build`. Every charts/<chart>/charts/*.tgz must have
# a matching entry in .github/configs/chart-dependencies.sha256; a missing or
# mismatched entry fails the script.
#
# Usage: scripts/verify-chart-dependencies.sh [charts/<chart> ...]
# Without arguments, all charts are checked.
set -euo pipefail

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIGEST_FILE=".github/configs/chart-dependencies.sha256"

cd "${SRCROOT}"

if [[ ! -f "${DIGEST_FILE}" ]]; then
  echo "::error::${DIGEST_FILE} not found"
  exit 1
fi

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d ' ' -f 1
  else
    shasum -a 256 "$1" | cut -d ' ' -f 1
  fi
}

if [[ $# -gt 0 ]]; then
  chart_dirs=("$@")
else
  chart_dirs=(charts/*)
fi

shopt -s nullglob
rc=0
checked=0
for chart_dir in "${chart_dirs[@]}"; do
  chart_dir="${chart_dir%/}"
  for archive in "${chart_dir}"/charts/*.tgz; do
    checked=$((checked + 1))
    expected=$(awk -v path="${archive}" '$1 !~ /^#/ && $2 == path { print $1 }' "${DIGEST_FILE}")
    if [[ -z "${expected}" ]]; then
      echo "::error file=${DIGEST_FILE}::No pinned digest for ${archive}. Add its sha256 to ${DIGEST_FILE}."
      rc=1
      continue
    fi
    if [[ $(wc -l <<< "${expected}") -ne 1 || ! "${expected}" =~ ^[0-9a-f]{64}$ ]]; then
      echo "::error file=${DIGEST_FILE}::Expected exactly one valid sha256 entry for ${archive}."
      rc=1
      continue
    fi
    actual=$(sha256 "${archive}")
    if [[ "${actual}" != "${expected}" ]]; then
      echo "::error file=${DIGEST_FILE}::Digest mismatch for ${archive}: expected ${expected}, got ${actual}."
      rc=1
      continue
    fi
    echo "OK ${archive} sha256:${actual}"
  done
done

echo "Checked ${checked} dependency archive(s)."
exit "${rc}"

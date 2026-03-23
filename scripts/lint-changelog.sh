#!/usr/bin/env bash
set -euo pipefail

# Validates that each Chart.yaml has at most one entry in artifacthub.io/changes.
# Contributors often append a new changelog entry instead of replacing the existing one.
# The annotation should describe only the *current* change; previous entries are captured
# in git history and the ArtifactHub release feed.

rc=0

for chart_yaml in charts/*/Chart.yaml; do
  # Count "- kind:" lines inside the artifacthub.io/changes block.
  # The block is a YAML literal scalar indented under the annotation key,
  # so entries appear as lines matching "    - kind:" (4-space indent).
  count=$(grep -c '^\s*- kind:' <<< "$(sed -n '/artifacthub.io\/changes/,/^  [^ ]/p' "$chart_yaml")" || true)

  if [[ "$count" -gt 1 ]]; then
    echo "::error file=${chart_yaml}::${chart_yaml}: artifacthub.io/changes has ${count} entries (expected 1). Replace the existing entry instead of adding a new one."
    rc=1
  fi
done

if [[ "$rc" -eq 0 ]]; then
  echo "All charts have a single changelog entry ✔"
fi

exit $rc

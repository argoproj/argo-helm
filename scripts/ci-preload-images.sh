#!/usr/bin/env bash
# Pulls the ECR Public images that the argo-cd chart tests use and loads them
# into the kind cluster, so the kubelet never pulls them from ECR Public.
#
# Images come from rendering every charts/argo-cd/ci values file and from
# .github/configs/external-redis.yaml, so image tag bumps need no change here.
# Run after `helm dependency build charts/argo-cd` and after the cluster exists.
#
# Usage: scripts/ci-preload-images.sh [kind-cluster-name]
set -euo pipefail

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"
cluster="${1:-chart-testing}"

cd "${SRCROOT}"

manifests() {
  local values
  for values in charts/argo-cd/ci/*.yaml; do
    helm template charts/argo-cd --values "${values}"
  done
  cat .github/configs/external-redis.yaml
}

refs=()
while IFS= read -r ref; do
  refs+=("${ref}")
done < <(manifests | awk '/^[[:space:]]*-?[[:space:]]*image:[[:space:]]/ {print $NF}' | tr -d '"' | grep '^ecr-public\.aws\.com/' | sort -u || true)

if [[ ${#refs[@]} -eq 0 ]]; then
  echo "::error::No ecr-public.aws.com images found in the argo-cd CI manifests"
  exit 1
fi

platform="$(docker version --format '{{.Server.Os}}/{{.Server.Arch}}')"
archive="$(mktemp)"
trap 'rm -f "${archive}"' EXIT

for ref in "${refs[@]}"; do
  echo "Preloading ${ref}"
  pulled="$(scripts/ci-pull-image.sh "${ref}")"
  if [[ "${pulled}" != "${ref}" ]]; then
    echo "::error::${ref} was pulled as ${pulled}. The cluster can only use it under its original name."
    exit 1
  fi
  # With Docker's containerd image store, `kind load docker-image` exports the
  # whole multi-arch index, but only this platform's content was pulled, so the
  # import into the nodes fails. Save just this platform and load the archive.
  docker save --platform "${platform}" --output "${archive}" "${ref}"
  kind load image-archive "${archive}" --name "${cluster}"
done

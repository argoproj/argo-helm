#!/usr/bin/env bash
# Pulls a CI image from ECR Public and falls back to mirror.gcr.io, Google's
# cache of Docker Hub, when ECR Public rate limits the runner.
#
# Both registries serve the same Docker Hub content, so a digest pin in the
# reference verifies the image on either one. An image without a digest is
# retagged to the original reference, so callers can use it by that name.
#
# Prints the reference that was pulled on stdout.
#
# Usage: scripts/ci-pull-image.sh ecr-public.aws.com/<path>:<tag>[@sha256:<digest>]
set -euo pipefail

ref="${1:?Usage: $0 <ecr-public.aws.com image reference>}"

case "${ref}" in
  ecr-public.aws.com/docker/library/*)
    mirror="mirror.gcr.io/library/${ref#ecr-public.aws.com/docker/library/}"
    ;;
  ecr-public.aws.com/artifacthub/*)
    mirror="mirror.gcr.io/artifacthub/${ref#ecr-public.aws.com/artifacthub/}"
    ;;
  *)
    echo "::error::No mirror.gcr.io mapping for ${ref}. Extend ${0##*/} to add one." >&2
    exit 2
    ;;
esac

if docker pull --quiet "${ref}" > /dev/null; then
  echo "${ref}"
  exit 0
fi

echo "::warning::Pulling ${ref} failed, falling back to ${mirror}" >&2
docker pull --quiet "${mirror}" > /dev/null

if [[ "${ref}" == *@* ]]; then
  echo "${mirror}"
else
  docker tag "${mirror}" "${ref}"
  echo "${ref}"
fi

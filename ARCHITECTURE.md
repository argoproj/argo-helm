# Architecture

This repository holds the community Helm charts for the Argo projects. It has no application code of its own. The charts reference the container images that the upstream projects publish and don't contain them.

## Repository Layout

* `charts/<chart>/`: one directory per chart (`argo-cd`, `argo-events`, `argo-rollouts`, `argo-workflows`, `argocd-apps`, `argocd-image-updater`). Each holds `Chart.yaml`, `values.yaml`, `templates/`, CI values files in `ci/`, and pending change fragments in `changes/`.
* `scripts/`: the scripts CI and maintainers run to lint, test, generate docs, and fold change fragments.
* `.github/workflows/`: pull request checks, the publish pipeline, Renovate, and the OSPS Baseline scan.
* `docs/security/`: the capability and threat catalogs.

## External Interfaces

The charts are the only interface this project publishes:

* **Chart values.** Each chart's `values.yaml` is its configuration interface. The chart's `README.md`, generated from `values.yaml`, documents every value.
* **Rendered resources.** A chart renders the Kubernetes resources of its upstream project. Every chart except argocd-apps includes its upstream custom resource definitions.
* **Distribution.** Charts are published to the Helm repository at `https://argoproj.github.io/argo-helm`, to the OCI registry at `oci://ghcr.io/argoproj/argo-helm`, and as GitHub release assets. Each package has a PGP provenance file. [README.md](README.md#verifying-chart-provenance) explains how to verify it.

The applications themselves, their APIs, and their command line tools belong to the upstream Argo projects and are documented there.

## Change and Release Flow

1. A contributor opens a pull request that changes a chart and adds a change fragment to `changes/`. Renovate opens the same kind of pull request for new upstream versions.
2. CI lints and installs each changed chart on a kind cluster, and checks the workflows and scripts. [CONTRIBUTING.md](CONTRIBUTING.md#when-tests-run) describes the checks.
3. Two reviewers approve the pull request, one of them a code owner, and a maintainer merges it into `main`.
4. The publish workflow (`.github/workflows/publish.yml`) runs on every push to `main` that touches `charts/`:
   1. `fold` turns the change fragments into a version bump and changelog entry in `Chart.yaml`, and pushes that commit to `main`. That push starts the run that releases.
   2. `package` builds chart dependencies, verifies subchart digests, then packages and signs each changed chart.
   3. `release` creates the GitHub releases, updates the Helm repository index on the `gh-pages` branch, and pushes the packages to GHCR.

## Software Bill of Materials

A chart package contains templates and values. The argo-cd package also bundles the third-party `redis-ha` subchart, which the publish workflow fetches from `https://dandydeveloper.github.io/charts/` at packaging time and checks against the digest pinned in `.github/configs/chart-dependencies.sha256`. No package contains compiled software, and releases do not include an SBOM. The images a chart deploys come from their upstream projects, some of which publish SBOMs for their images. This project publishes no VEX documents.

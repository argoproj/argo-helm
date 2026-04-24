# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a collection of **community maintained** Helm charts for ArgoProj projects (Argo CD, Argo Workflows, Argo Rollouts, Argo Events, and related tools). Each chart is independently versioned and released.

### Chart Structure

The repository contains 6 Helm charts in the `charts/` directory:
- `argo-cd` - Declarative GitOps continuous delivery tool
- `argo-workflows` - Workflow engine for orchestrating parallel jobs
- `argo-rollouts` - Progressive delivery controller
- `argo-events` - Event-based dependency manager
- `argocd-apps` - Declarative setup of Argo CD applications
- `argocd-image-updater` - Automatic container image update tool

Each chart follows the same structure:
- `Chart.yaml` - Chart metadata including version, appVersion, and changelog annotations
- `values.yaml` - Default configuration values
- `templates/` - Kubernetes manifest templates organized by component
- `templates/crds/` - Custom Resource Definitions (moved from `crds/` folder to support upgrades)
- `ci/` - Test value files for CI validation
- `README.md` - Auto-generated documentation (do not edit directly)
- `README.md.gotmpl` - Source template for README generation

## Development Commands

### Documentation

**Generate chart documentation:**
```bash
./scripts/helm-docs.sh
```
This runs helm-docs via Docker to regenerate all chart `README.md` files from their `.gotmpl` templates. Always run this after modifying any `README.md.gotmpl` or `values.yaml` file.

### Linting

**Lint all charts:**
```bash
./scripts/lint.sh
```
This runs chart-testing (ct) via Docker to validate chart structure, values, and metadata against stricter requirements than standard Helm. Configuration is in `.github/configs/ct-lint.yaml`.

### Testing Charts Locally

**For Argo CD:**
```bash
# Add dependencies
helm repo add redis-ha https://dandydeveloper.github.io/charts/
helm dependency update charts/argo-cd

# Install
helm install argocd charts/argo-cd -n argocd --create-namespace

# Port forward and access
kubectl port-forward service/argocd-server -n argocd 8080:443
```

**For Argo Workflows:**
```bash
kubectl create ns argo
helm install argo-workflows charts/argo-workflows -n argo
argo version
```

### Version Management

**Bump chart version and add changelog:**
The `renovate-bump-version.sh` script handles version bumps:
```bash
./scripts/renovate-bump-version.sh -c <chart-name> -d <dependency> -v <version>
```
This automatically:
1. Increments the patch version in Chart.yaml
2. Adds a changelog entry to `artifacthub.io/changes` annotation
3. Updates CRDs for argo-workflows if applicable

## Chart Versioning and Release Process

### Semantic Versioning
- **Major**: Large rewrites, major non-backwards compatible or destructive changes
- **Minor**: New chart functionality, major application updates, or minor breaking changes
- **Patch**: App version updates, backwards compatible optional features

### Version Requirements
- New charts start at `1.0.0` (or prerelease if not stable)
- Each chart release must be immutable - any change requires a version bump
- Every version bump must include a changelog entry in Chart.yaml annotations

### Changelog Format
Add changelog entries to `Chart.yaml` using Artifact Hub annotations:
```yaml
annotations:
  artifacthub.io/changes: |
    - kind: added
      description: Something new
    - kind: changed
      description: Modified behavior
    - kind: fixed
      description: Bug fix
    - kind: security
      description: Security patch
```

Valid kinds: `added`, `changed`, `deprecated`, `removed`, `fixed`, `security`

## Pull Request Guidelines

### PR Requirements
- **One chart per PR** - If changes affect multiple charts, submit separate PRs
- **PR title format**: Must follow Conventional Commits with scope
  - Format: `<type>(<chart-name>): <description>`
  - Example: `fix(argo-cd): Fix typo in values.yaml`
  - The PR title linter enforces this via GitHub Actions

### Making Changes
1. Modify chart templates, values, or other files as needed
2. If you changed `values.yaml` or `README.md.gotmpl`, run `./scripts/helm-docs.sh`
3. Update chart version in `Chart.yaml` and add changelog entry
4. Run `./scripts/lint.sh` to validate changes
5. Test the chart installation locally
6. Submit PR with conventional commit title

## CRD Management

CRDs are located in `<chart>/templates/crds/` (not `<chart>/crds/`) to enable automatic upgrades via Helm. This differs from the Helm best practice of putting CRDs in the `crds/` folder because Helm cannot upgrade CRDs in that location.

Users can disable CRD installation with `--set crds.install=false` and manage CRDs manually:
```bash
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>"
```

## Helm Capabilities Usage

Charts use Helm's built-in `.Capabilities` object:
- `.Capabilities.APIVersions.Has` - Check if ServiceMonitor CRDs exist
- `.Capabilities.KubeVersion.Version` - Handle correct API versions (e.g., policy/v1 vs policy/v1beta1)

When templating without installing, pass `--api-versions`:
```bash
helm template argocd oci://ghcr.io/argoproj/argo-helm/argo-cd \
  --api-versions monitoring.coreos.com/v1 \
  --values my-values.yaml
```

## CI/CD

### Automated Workflows
- **Linting and Testing** (`lint-and-test.yml`) - Runs on all PRs
  - Artifact Hub metadata validation
  - Chart linting with ct
  - Documentation validation (helm-docs)
  - Kind cluster installation tests (skipped if no chart changes)

- **Publishing** (`publish.yml`) - Runs on main branch push
  - Automatically publishes changed charts
  - Signs packages with PGP
  - Pushes to GitHub Pages (index.yaml) and GHCR (OCI registry)

### Renovate Bot
Automated dependency updates via `renovate.json`:
- Monitors upstream releases for all Argo projects
- Automatically bumps appVersion, chart version, and image tags
- Runs post-upgrade tasks (version bump script and helm-docs)
- Creates PRs with conventional commit format

## Important Notes

- **Support Policy**: Only the latest version is officially supported. Older versions do not receive bug fixes or security patches.
- **Redis License**: Redis versions >= 7.4 are not allowed due to license change (enforced in renovate.json)
- **Publishing**: Charts are immutable once published. Any change requires a new version.
- **Dependencies**: argo-cd chart depends on redis-ha (dandydeveloper chart repository)


## remotes

This is a fork of https://github.com/argoproj/argo-helm
and PR are open in https://github.com/argoproj/argo-helm/pulls

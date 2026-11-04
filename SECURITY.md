# Security Policy

## EU Cyber Resilience Act

We do not anticipate this project being used in commercial products. See [LF-Supported Projects and CRA Readiness](https://openssf.org/wp-content/uploads/2026/09/LF-Supported-Projects-and-CRA-Readiness-2026-09-10.pdf) for more information.

## Supported Versions and Upstream Reporting

Each helm chart currently supports the designated application version in the Chart.yaml. There is a chance a security issue you've discovered may not be with the helm chart but with the upstream application. Please visit that application's Security policy document to find out how to report the security issue.

* [Security Policy for Argo Workflows](https://github.com/argoproj/argo-workflows/blob/master/SECURITY.md)
* [Security Policy for Argo Events](https://github.com/argoproj/argo-events/blob/master/SECURITY.md)
* [Security Policy for Argo Rollouts](https://github.com/argoproj/argo-rollouts/blob/master/docs/security/security.md)
* [Security Policy for Argo CD](https://github.com/argoproj/argo-cd/blob/master/SECURITY.md)
* [Security Policy for Argo CD Image Updater](https://github.com/argoproj-labs/argocd-image-updater/blob/master/SECURITY.md)

## Reporting a Vulnerability for Argo Helm Charts

We have enabled the ability to privately report security issues through the  Security tab above.

[Here are the details on how to file](https://docs.github.com/en/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability#privately-reporting-a-security-vulnerability) on how to do that

A repository owner/maintainer will respond as fast as possible to coordinate confirmation of issue and remediation.

Thank you for helping to ensure this code stays secure.

<!-- Adapted from the Coordinated Vulnerability Disclosure Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Response Timeframes

Argo Helm is maintained by volunteers, so these are targets, not guarantees. We aim to acknowledge a report within 10 business days and to share an initial assessment (validity, severity, affected charts) within 10 business days of acknowledgement.

Details stay private until a fix is released or 90 days have passed since confirmation, whichever comes first, unless the reporter and maintainers agree to a different timeline. We publish a GitHub Security Advisory with the affected chart versions and remediation steps, and credit the reporter unless they ask to stay anonymous.

<!-- Adapted from the Software Composition Analysis Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Dependency Security

Renovate tracks upstream application versions and container images. Dependabot tracks GitHub Actions. Chart dependencies (argo-cd's redis-ha) are bumped by hand. Vulnerabilities in the upstream Argo applications follow that application's security policy, linked above.

Renovate opens a pull request when a container image it tracks publishes a new version, and maintainers merge those as review time allows. There are no severity thresholds or remediation windows. Nothing in CI scans dependencies for vulnerabilities, and every merge to `main` publishes a release, so releases are not gated on them. argo-cd's redis and HAProxy images aren't currently bumped by Renovate and can fall behind upstream fixes (see [#4098](https://github.com/argoproj/argo-helm/issues/4098)).

Dependency licenses follow the upstream Argo manifests, which is the upstream project's call. Renovate skips versions whose license is not OSI-approved, such as Redis 7.4.x. A dependency that the upstream manifests do not ship must use an OSI-approved license, and one under a strong copyleft license, such as GPL or AGPL, needs maintainer review before it is added.

<!-- Adapted from the Static Application Security Testing Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Static Analysis

zizmor audits GitHub Actions workflows, and actionlint and shellcheck check workflows and scripts, on every pull request (see `.github/workflows/actions-lint.yaml`). All three are required status checks.

Low, medium, and high severity findings must be fixed, or suppressed in `.github/zizmor.yml` with a documented reason, before the pull request merges.

## Secrets Management

The workflows in this repository keep long-lived credentials to a minimum:

* Each job gets a GitHub token limited to the permissions that job declares.
* Renovate and the PR lifecycle workflow trade the job's OIDC identity for a short-lived token through [octo-sts](https://github.com/octo-sts/app). Their trust policies live in [.github/chainguard](.github/chainguard).
* Publishing OSPS Baseline results authenticates with the job's OIDC identity and stores no credential.
* The workflows use two long-lived credentials: the PGP chart signing key with its passphrase, and the private key of the GitHub App that pushes folded release changes to `main`. They are GitHub Actions secrets, which only repository administrators can change. The publish workflow writes the PGP key to a temporary directory and deletes it when the signing step ends.

Maintainers rotate a credential when someone with access to it leaves the project or when it may have been exposed.

# Security Policy

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

Critical and high severity vulnerabilities (CVSS 7.0 or higher) in dependencies this repository controls must be fixed by upgrading, patching, or replacing the dependency in the first chart release after a fixed version is available. Medium and low severity vulnerabilities are fixed through the regular Renovate and Dependabot updates.

Dependencies must use an OSI-approved license. A dependency with a disallowed license must be replaced or removed. Disallowed licenses are any license that is not OSI-approved, including source-available licenses such as SSPL-1.0, BUSL-1.1, and Elastic-2.0. A new dependency under a strong copyleft license, such as GPL or AGPL, needs maintainer review before it is added.

Every merge that touches `charts/` publishes a release through `publish.yml`. Known critical or high SCA findings and disallowed licenses must be fixed before release, which means before the change merges, unless a maintainer who did not author the change approves a documented exception in the pull request.

<!-- Adapted from the Static Application Security Testing Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Static Analysis

zizmor audits GitHub Actions workflows, and actionlint and shellcheck check workflows and scripts, on every pull request (see `.github/workflows/actions-lint.yaml`). All three are required status checks.

Low, medium, and high severity findings must be fixed, or suppressed in `.github/zizmor.yml` with a documented reason, before the pull request merges.

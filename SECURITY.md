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

<!-- TODO(maintainers): replace every TODO below with a window the maintainers agree to keep, then delete this comment. -->

We acknowledge a report within TODO business days and share an initial assessment (validity, severity, affected charts) within TODO business days of acknowledgement.

Details stay private until a fix is released or TODO days have passed since confirmation, whichever comes first, unless the reporter and maintainers agree to a different timeline. We publish a GitHub Security Advisory with the affected chart versions and remediation steps, and credit the reporter unless they ask to stay anonymous.

<!-- Adapted from the Software Composition Analysis Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Dependency Security

<!-- TODO(maintainers): fill every TODO, then delete this comment. -->

Renovate tracks upstream application versions and container images. Dependabot tracks GitHub Actions. Chart dependencies (argo-cd's redis-ha) are bumped by hand. Vulnerabilities in the upstream Argo applications follow that application's security policy, linked above.

Vulnerabilities in dependencies this repository controls are fixed by upgrading, patching, or replacing the dependency within:

| Severity | CVSS score | Remediation window |
| --- | --- | --- |
| Critical | 9.0 or higher | TODO days |
| High | 7.0 to 8.9 | TODO days |
| Medium | 4.0 to 6.9 | TODO days |
| Low | Below 4.0 | TODO |

Dependencies must use an OSI-approved license. TODO: licenses that need maintainer review, and licenses that are disallowed.

Releases are not gated automatically: `publish.yml` publishes every merge that touches `charts/`. Maintainers do not merge a change to a chart with a known unresolved TODO (for example, critical or high) finding or a disallowed license, unless a maintainer who did not author the change approves a documented exception in the pull request.

<!-- Adapted from the Static Application Security Testing Policy template in the
     OpenSSF OSPS Templates (ORBIT Definitions SIG), CC BY 4.0: https://github.com/eddie-knight/osps-templates -->
## Static Analysis

<!-- TODO(maintainers): fill every TODO, then delete this comment. -->

zizmor audits GitHub Actions workflows, and actionlint and shellcheck check workflows and scripts, on every pull request and push that touches them (see `.github/workflows/actions-lint.yaml`).

Findings are fixed, or suppressed in `.github/zizmor.yml` with a documented reason, within:

| Severity | Remediation window |
| --- | --- |
| High | TODO days |
| Medium | TODO days |
| Low / Informational | TODO |

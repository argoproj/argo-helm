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

## Secrets Management

The workflows in this repository keep long-lived credentials to a minimum:

* Each job gets a GitHub token limited to the permissions that job declares.
* Renovate and the PR lifecycle workflow trade the job's OIDC identity for a short-lived token through [octo-sts](https://github.com/octo-sts/app). Their trust policies live in [.github/chainguard](.github/chainguard).
* Publishing OSPS Baseline results authenticates with the job's OIDC identity and stores no credential.
* The PGP chart signing key and its passphrase are the only long-lived credentials the workflows use. They are GitHub Actions secrets, which only repository administrators can change. The publish workflow writes the key to a temporary directory and deletes it when the signing step ends.

Maintainers rotate a credential when someone with access to it leaves the project or when it may have been exposed.

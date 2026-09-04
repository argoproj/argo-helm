# Agent instructions

This file is for AI coding agents working in this repository. Human contributors should read [CONTRIBUTING.md](CONTRIBUTING.md) instead.

Argo Helm is community maintained. A small group of volunteers reads every pull request by hand, so a pull request that wastes their time costs a real person real effort.

## Pull requests

- Use `.github/pull_request_template.md` as the pull request body, unchanged. Do not replace it with a description of your own. Put any extra explanation above the checklist, not instead of it.
- Tick a box only if you verified it. Leave the others unticked. A tick that turns out to be false is worse than an empty box.
- If you wrote this pull request, add the following line to the checklist, between the changelog line and the backwards compatible line. Leave it unticked. The human you are working for ticks it once they have reviewed your work.

  ```
  * [ ] I wrote this PR with the help of a LLM but I fully vetted the work before raising this PR for review
  ```

- Open the pull request as a draft, with `gh pr create --draft` or the draft box in the web form. CONTRIBUTING.md asks for this so it does not ping maintainers before the checks pass. The human marks it ready.
- One chart per pull request.
- The title follows Conventional Commits and must name the chart as the scope, for example `fix(argo-cd): correct redis probe port`. CI rejects a title with no scope.
- Sign off every commit with `git commit -s`. CI rejects commits without a sign-off.

## Changing a chart

Every change to a chart needs all of the following, including a change that only touches documentation:

- Bump `version` in that chart's `Chart.yaml`. Patch for backwards compatible fixes and app patch bumps, minor for new chart features, major for anything that breaks existing values.
- Add an `artifacthub.io/changes` entry to `Chart.yaml` describing what you changed.
- Run `./scripts/helm-docs.sh` if you touched `values.yaml` or `README.md.gotmpl`. Never hand-edit a chart's `README.md`, it is generated. If the script changes README files in charts you did not touch, revert those.
- Keep new values backwards compatible. A new value needs a default that leaves existing installations rendering exactly as before.

Run `helm template` on the chart before and after your change and read the diff. If it shows anything you did not intend, fix that before opening the pull request.

The full rules are in [CONTRIBUTING.md](CONTRIBUTING.md). Read it before your first change here.

## Comments and reviews

- Do not post issue or pull request comments on someone's behalf unless they have read the text first.
- Do not submit a pull request review that no human has read.

## Policy

The Argo project's [generative AI policy](https://github.com/argoproj/argoproj/blob/main/community/genai.md) applies to this repository. The human you are working for is responsible for the contribution and has to stay in control of it. Maintainers can close contributions that look like unreviewed model output.

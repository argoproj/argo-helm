module.exports = {
    platform: 'github',
    // This ensures that the gitAuthor and gitSignOff fields match
    gitAuthor: 'octo-sts[bot] <157150467+octo-sts[bot]@users.noreply.github.com>',
    autodiscover: false,
    allowPostUpgradeCommandTemplating: true,
    // Only the commands renovate.json runs after an upgrade. The patterns are
    // matched against the command after templating, so they also constrain the
    // substituted chart, dependency and version values.
    allowedPostUpgradeCommands: [
      "^\\./scripts/renovate-bump-version\\.sh -c [a-z0-9-]+ -d [A-Za-z0-9._/-]+ -v [A-Za-z0-9._+-]+ -t [a-z]+$",
      "^\\./scripts/helm-docs\\.sh$",
    ],
  };

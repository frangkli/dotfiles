# Dependencies

Routine bumps belong to Renovate or Dependabot. If the repo has neither, stop and point at `readiness` (SEC-7). This mode does what the bots can't, in this order.

1. **Measure.** Outdated packages by major, minor and patch (`pnpm outdated --format json`, `uv pip list --outdated`, `cargo outdated`), and the open bot PRs with their check status.
2. **Failing bot PRs.** For each one, read the failing step (`gh pr checks <n>`, then `gh run view <run-id> --log-failed`) and find the cause: a breaking change, a type change, a lockfile conflict. Push the fix to that PR's branch and watch its checks. List the green bot PRs for the owner to merge.
3. **Major and toolchain upgrades,** one per PR: a framework or library major, the Node LTS, TypeScript, a pinned runtime. Read the changelog and migration guide first, and use the vendor's codemod or upgrade skill when one exists. Respect the repo's release-age cooldown. Code and its tests change together, and the full check passes before the PR opens.
4. **Measure again** and put both counts in each PR body.

Box-level tools are out of scope; the owner updates them with `devbox-update`.

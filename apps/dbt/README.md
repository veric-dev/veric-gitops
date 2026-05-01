# dbt — Snowflake transformation CronJob

Scaffolded during the Azure→AWS cutover prep. Default-disabled in every
env. Runs `dbt deps && dbt run` (or `dbt build` in prod) on a schedule
defined per env.

## Wiring (deferred)

Same wiring story as `apps/web/` — see that chart's README. Once
`apps-applicationset.yaml` exists, this chart should be one of its
generator entries.

## Open follow-ups

- Snowflake RBAC and per-env profiles still live in `veric-saas/`.
  Confirm `DBT_TARGET=<env>` matches an entry in the bundled
  `profiles.yml`, otherwise the runs fail at `dbt deps`.
- The `command`/`args` defaults assume a debian-style image with
  `/bin/sh -lc`. If we move to a distroless dbt image, switch to a
  direct `dbt` binary invocation.
- No retry / no alerting wired here. Consider:
  - `failedJobsHistoryLimit` is 3 — set up an alert on
    `kube_job_status_failed{job_name=~"dbt-.*"}` once Prometheus is in.
  - Or add OpsGenie/PagerDuty webhook from a sidecar in the failure path.

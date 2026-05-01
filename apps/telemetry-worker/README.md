# telemetry-worker — veric-saas event ingestion worker

Scaffolded during the Azure→AWS cutover prep. Default-disabled in every
env. Mirrors `apps/web/`'s structure minus the ingress, service, HPA.

## Wiring (deferred)

Same wiring story as `apps/web/` — see that chart's README. Once
`apps-applicationset.yaml` exists, this chart should be one of its
generator entries.

## Open follow-ups

- Replace the `livenessProbe.exec: ["/bin/true"]` placeholder with a real
  worker liveness signal (e.g. a `/healthz` HTTP probe on a sidecar port,
  or a file-touch from inside the worker loop). The placeholder always
  passes — fine for the scaffold but useless once enabled.
- Keda or queue-depth autoscaling is out of scope for the initial
  scaffold; flat `replicaCount` per env. Revisit after the cutover when
  there's traffic to size against.
- ESO entries — list `data:` keys in each `values-<env>.yaml` based on
  the worker's runtime env vars (DATABASE_URL, Snowflake creds, etc.)
  before flipping `enabled: true`.

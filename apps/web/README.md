# web — veric-saas Next.js chart

Scaffolded during the Azure→AWS cutover prep. Default-disabled in every
env via `enabled: false`; flip to `true` per-env in `values-<env>.yaml`
when ready.

## Wiring (deferred)

This chart is **not yet wired** into `apps-applicationset.yaml`. To wire:

1. Create `apps-applicationset.yaml` (sibling of `platform/applicationset.yaml`)
   with a list generator over apps × envs (or two generators: matrix of
   `{name: web, telemetry-worker, dbt}` × `{env: pdev, nonprod, prod}`)
   each pointing at the right values file: `values.yaml` + `values-{env}.yaml`.
2. The Application destination should match the env's cluster
   (use cluster decision/list generator with cluster labels).

## Per-env values that still need filling in

- `ingress.certificateArn` — read from the platform tofu env:
  `tofu -chdir=infra/tofu/environments/platform-<env> output -raw platform_certificate_arn`
- `serviceAccount.roleArn` — IRSA role for the web pod's app-side AWS
  access (Secrets Manager → DATABASE_URL composition, S3 if used).
  Add to `infra/tofu/modules/platform/cluster-config/main.tf` as a
  service account/role pair (see ESO IRSA pattern there).
- ESO `externalSecrets.data` — list the keys you need from foundation
  Secrets Manager, e.g.
  ```yaml
  externalSecrets:
    data:
      - secretKey: DATABASE_URL
        remoteKey: /veric/<env>/web/database-url
      - secretKey: STRIPE_SECRET_KEY
        remoteKey: /veric/<env>/web/stripe-secret-key
      - secretKey: GITHUB_WEBHOOK_SECRET
        remoteKey: /veric/<env>/web/github-webhook-secret
      - secretKey: SEED_API_KEY
        remoteKey: /veric/<env>/web/seed-api-key
  ```
  Pre-populate these in foundation SM under `/veric/<env>/web/...`.

## DATABASE_URL composition

Two options — pick one before flipping `enabled: true`:

1. **Pre-composed in SM**: build `DATABASE_URL` in foundation SM at
   `/veric/<env>/web/database-url` and have ESO pull it. Simplest, but
   couples the secret to the RDS endpoint (any rotation that changes the
   endpoint requires re-write).
2. **Runtime-composed**: pull master creds from the platform-tier RDS
   Secrets Manager secret (`/veric/<env>/rds/master`, see `rds.*` block
   in `values.yaml`) and join with the SSM-sourced endpoint+port. The
   web app must read the rendered Secret + SSM at startup.

Default scaffold leans toward (1) for simplicity. Swap the deployment to
include an init-container or app-side resolver if you go with (2).

## Open follow-ups

- Wire to `apps-applicationset.yaml` (above).
- Sync-wave annotation: ensure web syncs **after** platform-services
  (which carry sync-wave -3..0). `apps-applicationset.yaml` should set
  sync-wave 1+ on apps.
- argocd-image-updater annotations (write-back to this repo) on the
  Application (not the chart) once the build pipeline is producing
  immutable tags.

# apps/kernel — hosted ai-kernel-server

Helm chart for the hosted `ai-kernel-server` deployment at `kernel.veric.dev`. Driven by ai-fundamentals Phase-3 demos canonicalization (Stage D5).

## Topology

One Deployment on `platform-prod`, fronted by the existing shared platform-prod ALB. The container runs `ai-kernel-server --provider mock` and exposes `workspace.analyse` over JSON-RPC at `/rpc` (WSS) and `/` (HTTPS for health + REST shims).

## Values files

- `values.yaml` — defaults; `enabled: false` so adding the Application via apps-applicationset.yaml doesn't deploy anything until a per-env file flips it on.
- `values-prod.yaml` — `enabled: true`; pins image tag; sets `kernel.veric.dev` hostname + apex cert ARN; joins the shared `platform-prod` ALB group.

Other envs (pdev, nonprod) are not configured. The kernel is shipped to prod only; preview demos are wired against the same hosted endpoint to give Vercel previews kernel parity with production.

## Driver

- `veric-aws/docs/hosted-kernel-rollout-plan-2026-05-13.md` — rollout plan, cost envelope, rollback levers.
- `veric-aws#44` — foundation ECR repo `ai-kernel-server` + `ai-fundamentals-ecr-push` OIDC role.
- `ai-fundamentals#201` — image build (Dockerfile + `kernel-image-build.yml` workflow).

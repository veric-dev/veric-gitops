# veric-gitops

ArgoCD GitOps repository for the Veric platform on AWS+EKS. Companion to [veric-dev/veric-aws](https://github.com/veric-dev/veric-aws) (Tofu/IaC).

## Layout

```
platform/                    # cluster-services-shared-across-platforms
  applicationset.yaml        # matrix(cluster × service) → Argo Applications
platform-services/           # values + manifests per shared service
  external-secrets/
  external-dns/
  cluster-autoscaler/
  argocd-image-updater/
  buildkit/
applicationsets/             # ApplicationSets that fan out app workloads per platform
apps/
  prod/                      # apps deployed to platform-prod
  nonprod/                   # apps deployed to platform-nonprod
  pdev/                      # apps deployed to platform-dev
```

## Bootstrap chain

Tofu (`veric-aws/infra/tofu/modules/platform/argocd-apps`) creates one `Application` per cluster pointing at this repo's `platform/`. From there:

1. `platform/applicationset.yaml` produces an Application per (cluster, service) pair.
2. `applicationsets/` produces an Application per (platform, app) pair.
3. Each leaf Application syncs its values + chart, applying to the target cluster.

ArgoCD Image Updater watches ECR helm-OCI charts and updates `targetRevision` in this repo (PR-based for prod, auto for nonprod/pdev).

## Cluster identity (cluster-info)

Each cluster has a `cluster-info` ConfigMap in the `argocd` namespace, written by Tofu (not GitOps) at bootstrap. ApplicationSets read from it via the `cluster` generator's secret labels:

- `environment`: `prod` | `nonprod` | `pdev`
- `platform`:    `prod` | `nonprod` (pdev is also nonprod for security boundary purposes)
- `region`:      `us-west-2`
- `account_id`:  AWS member account ID

## Image-promotion model

Per [veric-aws plan §2 #9](https://github.com/veric-dev/veric-aws/blob/main/docs/platform-design.md): no `:latest` to prod. Image Updater pinned to immutable `:sha-<git-sha>` tags. Prod requires a PR (manual gate); nonprod & pdev auto-merge.

## Plan-of-record

[veric-aws/docs/platform-design.md](https://github.com/veric-dev/veric-aws/blob/main/docs/platform-design.md).

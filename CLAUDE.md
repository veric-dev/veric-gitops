# veric-gitops — operating notes for Claude

ArgoCD GitOps repo. Inherits the same single-`main` policy as `veric-infra/` and `veric-aws/`. Commit directly to `main`; no branches without explicit user ask.

## What lives here vs. veric-aws

- **Argo manifests, Helm values, ApplicationSets** — here.
- **Anything Tofu touches** (cluster, ALB controller, IRSA, ECR repo creation, etc.) — `veric-aws`.

If you find yourself wanting to add a `kind: Application` to veric-aws or a `resource "aws_..."` to this repo, you're in the wrong repo.

## Validation

Before pushing:

```bash
# YAML syntax
find . -name '*.yaml' -o -name '*.yml' | xargs -I{} python3 -c "import yaml,sys; yaml.safe_load(open('{}'))"

# kubeconform / kubeval against the manifests, if available
```

For Helm chart authoring, `helm template` locally before pushing.

## Standing authorization

`git commit` and `git push` to `main`. `gh` ops. ArgoCD auto-syncs once it sees the commit; no `argocd app sync` runs from CI here.

## Deployment promotion (Option β, 2026-05-04)

`np` + `pdev` auto-track `main`; **prod is gitops-pinned**.

- `platform/apps-applicationset.yaml` gates the
  `argocd-image-updater.argoproj.io/*` annotations on
  env-short ∈ {pdev, nonprod}. On those envs, every push to
  `veric-saas/main` is auto-promoted within ~2 min (ECR push →
  image-updater poll → Application `helm.parameters` override → sync).
- On **prod**, image-updater is disabled and the live tag is whatever
  `apps/<app>/values-prod.yaml` (or `apps/dbt/values.yaml` for dbt) says.
  Promotion is explicit: bump the `tag:` line and merge to `main`.
- Two paths to bump:
  1. `gh workflow run promote-prod.yml -R veric-dev/veric-gitops -f app=web -f sha=XXXXXXXXXXXX -f reason="..."` — opens a labelled PR.
  2. Hand-edit `apps/<app>/values-prod.yaml` (or `apps/dbt/values.yaml`)
     and open a PR yourself.
- **Rollback** = `git revert` of the bump commit. ArgoCD reconciles
  prod within ~3 min and Argo Rollouts steps the canary
  (25 → 50 → 75 → 100 with 60s pauses).

The `ignoreApplicationDifferences` block on `/spec/source/helm/parameters`
exists for the np/pdev path — image-updater writes there and the
ApplicationSet must not stomp it on each reconcile. After this Option β
flip, prod Applications carry no `helm.parameters` block.

## Plan-of-record

[veric-aws/docs/platform-design.md](https://github.com/veric-dev/veric-aws/blob/main/docs/platform-design.md).

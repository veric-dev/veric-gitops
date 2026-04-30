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

## Plan-of-record

[veric-aws/docs/platform-design.md](https://github.com/veric-dev/veric-aws/blob/main/docs/platform-design.md).

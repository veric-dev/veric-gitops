# buildkit (deferred)

Per the platform design (§ Phase 8b), the in-cluster BuildKit pool is not part
of the initial bootstrap. Until then, container images are built by the
existing veric-infra GitHub Actions runners and pushed to ECR in the
foundation account (`487542879472.dkr.ecr.us-west-2.amazonaws.com`).

When BuildKit lands on EKS it will be added here as a Helm umbrella chart and
referenced from `platform/applicationset.yaml`.

# TinyCloud Infra

## What Is This

This repository contains the infrastructure and deployment orchestration for TinyCloud.

It provisions the Kubernetes base on Civo with Terraform and deploys backend and frontend releases with Helmfile. Application repositories publish versioned artifacts; this repo is responsible for turning those artifacts into running environments.

## How To Run

### Provision the base cluster

```bash
cd terraform/civo
terraform init
terraform plan
terraform apply
```

### Deploy an application version with Helmfile

```bash
cd charts
helmfile --environment dev \
  -l name=tinycloud-backend-dev \
  --state-values-set version=<version> \
  sync --wait
```

Swap the selector to deploy the frontend instead:

```bash
helmfile --environment dev \
  -l name=tinycloud-frontend-dev \
  --state-values-set version=<version> \
  sync --wait
```

Supported environments in this repo: `dev`, `staging`, `prod`.

## Architecture

This repo has two layers:

- `terraform/civo`: infrastructure provisioning for the Civo network, firewall, and Kubernetes cluster
- `charts/helmfile.yaml.gotmpl`: deployment orchestration for application releases stored in ECR

Deployment model:

- Backend chart: `oci://.../tinycloud-backend`
- Frontend chart: `oci://.../tinycloud-frontend`
- Per-environment values in `charts/dev`, `charts/staging`, and `charts/prod`
- Namespace model: `tinycloud-<environment>`

Operational flow:

1. Terraform creates the base cluster and networking.
2. App repos publish versioned images and charts to ECR.
3. Helmfile resolves the requested environment and release.
4. Kubernetes pulls the requested chart version and applies the environment values.

## CI/CD

GitHub Actions workflow: `.github/workflows/pipeline.yaml`

This repo is deployed via `workflow_dispatch`, not on push. The workflow expects:

- `environment`: `dev`, `staging`, or `prod`
- `service`: `backend` or `frontend`
- `version`: the app/chart version to deploy

The pipeline then:

1. Checks out the repo.
2. Configures AWS credentials and logs in to ECR.
3. Writes kubeconfig from GitHub Secrets.
4. Ensures the target Kubernetes namespace exists.
5. Creates or updates the ECR pull secret in that namespace.
6. Runs Helmfile against the selected environment and release.

## Infra / Deploy Flow

Cross-repo deploy flow:

1. `tinycloud-project` or `tinycloud-frontend` ships a new version from its own pipeline.
2. That pipeline calls this repo's GitHub workflow with environment, service, and version.
3. This repo authenticates to AWS and the cluster.
4. Helmfile applies the environment-specific values file for the selected service.
5. Kubernetes updates the release in `tinycloud-dev`, `tinycloud-staging`, or `tinycloud-prod`.

Environment values in this repo also define ingress hostnames, backend/frontend service wiring, image repositories, resource limits, and secret names.

## What Was Learned

- Separating artifact publication from actual deployment makes promotions easier to reason about and easier to rerun.
- Helmfile is a good fit when the same services repeat across environments with mostly values-driven changes.
- Even a small project benefits from a dedicated infra repo because Terraform state, kubeconfig handling, and rollout logic evolve differently from app code.

## Known Limitations

- Terraform in this repo currently represents a single Civo cluster setup rather than a fully parameterized multi-environment foundation.
- Environment bootstrapping beyond app deploys is still manual; observability and add-ons live outside the main Helmfile flow.
- This repo assumes charts and images already exist in ECR before deployment starts.
- Secret management relies on GitHub Secrets and pre-created Kubernetes secrets rather than a dedicated secret manager workflow.

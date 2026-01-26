## Table of Contents
- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Secrets Management](#secrets-management)
- [Infrastructure as Code (Terraform)](#infrastructure-as-code-terraform)
- [CI / CD Workflow](#ci--cd-workflow)



## Project Overview
This repository demonstrates a dbt + Snowflake analytics pipeline with CI/CD implemented using GitHub Actions. Infrastructure components are managed using Terraform.



## Tech Stack
- dbt Core  
- Snowflake (Key Pair Authentication)  
- GitHub Actions  
- Terraform  
- AWS (S3, DynamoDB)  
- Python 3.11  



## Repository Structure
.

├── cicd_demo/ # dbt project

│ ├── models/

│ ├── macros/

│ ├── requirements.txt

│ └── dbt_project.yml

│

├── tf_demo/ # Terraform demo

│ ├── main.tf

│ ├── variables.tf

│ └── .terraform.lock.hcl

│

├── .github/workflows/ # CI/CD workflows

│ ├── cr001_ci.yml

│ └── cr001_cd.yml

│

└── README.md



## Secrets Management

All sensitive credentials are managed using **GitHub Environments and Secrets**. No secrets are committed to source control.

Snowflake authentication is handled using **key pair authentication**. The Snowflake private key is stored securely as a GitHub Secret (`SNOWFLAKE_PRIVATE_KEY`) and injected at runtime.

During CI/CD execution, a `profiles.yml` file is generated dynamically on the GitHub Actions runner using environment secrets.

This approach ensures:
- Credentials are never stored in the repository
- Password-based authentication is avoided
- CI and CD environments can be isolated and audited



## Infrastructure as Code (Terraform)

Terraform is used to define and validate infrastructure configuration.

- Remote state is stored in **AWS S3**
- State locking is handled via **AWS DynamoDB**
- Provider versions are locked using `.terraform.lock.hcl`

Terraform state files are excluded from version control.



## CI / CD Workflow

This project implements a full CI/CD workflow using **GitHub Actions** to validate and deploy dbt models to Snowflake in a controlled and automated manner.



### Branching Strategy

- **main**
  - Stable production branch
  - Always represents a deployable state
  - All deployments (CD) are triggered from this branch

- **cr001**
  - Feature / change request branches
  - All development and testing happens here
  - Changes must pass CI checks before merging into `main`


### Continuous Integration (CI)

The CI workflow is triggered when a pull request is opened or updated targeting the `main` branch.

**Purpose:**
- Validate dbt code changes before merge
- Ensure Snowflake connectivity
- Prevent broken models or tests from entering production
- Verify that changes are compatible with the current `main` branch

**Trigger:**
- `pull_request` events targeting `main`
  - opened
  - synchronize
  - reopened

**CI Steps Include:**

- Checkout pull request code
- Authenticate to AWS via GitHub OIDC
- Run terraform init and terraform plan (no apply)
- Set up Python environment
- Install dependencies
- Generate dbt `profiles.yml` using GitHub Secrets
- Run `dbt debug`
- Run `dbt deps`
- Run `dbt build` (validation only, no production deployment)

CI must pass before the pull request can be approved and merged.


### Continuous Deployment (CD)

The CD workflow is triggered automatically when changes are merged into the `main` branch.

**Purpose:**
- Deploy validated dbt models to Snowflake
- Apply approved changes to production datasets
- Ensure the `main` branch always reflects the production state

**Trigger:**
- `push` events on the `main` branch

**CD Steps Include:**
- Checkout production code
- Authenticate to AWS via GitHub OIDC
- Apply infrastructure changes using Terraform
- Deploy analytics code with dbt build (deploy to prod)

This ensures that only reviewed and validated changes are deployed to the production Snowflake environment.

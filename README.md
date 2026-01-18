## Table of Contents
- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Repository Structure](#repository-structure)
- [Secrets Management](#secrets-management)
- [CI / CD Workflow](#ci--cd-workflow)



## Project Overview
This project demonstrates a dbt + Snowflake analytics pipeline with a full CI/CD workflow implemented using GitHub Actions.

## Tech Stack
- dbt Core
- Snowflake
- GitHub Actions
- Python 3.11

## Repository Structure
.

├── cicd_demo/              # dbt project

│ ├── models/

│ ├── macros/

│├── dbt_project.yml

│

├── .github/workflows/      # CI/CD workflows

│├── cr001_ci.yml

│├── cr001_cd.yml

│

├── requirements.txt

└── README.md


## Secrets Management

All Snowflake credentials are securely managed using **GitHub Environments and Secrets**.

Sensitive information such as Snowflake account, user, password, role, warehouse, and database
are **never committed to the repository**.

During CI/CD execution, a `profiles.yml` file is dynamically generated at runtime using
GitHub Secrets and injected into the GitHub Actions runner.

This approach ensures:
- No credentials are stored in source control
- Different environments (CI / CD) can use different credentials
- Secure, auditable credential management


## CI / CD Workflow

This project implements a full CI/CD workflow using **GitHub Actions** to validate and deploy dbt models to Snowflake in a controlled and automated manner.


### Branching Strategy

- **main**
  - Stable production branch
  - Always represents a deployable state
  - All deployments (CD) are triggered from this branch

- **crXXX (e.g. cr001)**
  - Feature / change request branches
  - All development and testing happens here
  - Changes must pass CI checks before merging into `main`


### Continuous Integration (CI)

The CI workflow is triggered when a pull request is opened or updated
targeting the `main` branch.

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
- Install dependencies
- Generate production dbt `profiles.yml`
- Run `dbt debug`
- Run `dbt deps`
- Run `dbt build --fail-fast`
- Run `dbt test`

This ensures that only reviewed and validated changes are deployed to the production Snowflake environment.

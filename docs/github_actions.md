# GitHub Actions Orchestration

This project uses GitHub Actions to orchestrate dbt runs for both development validation and scheduled production execution.

Two workflows are implemented:

- **Staging workflow** → runs on pull requests and pushes to `main`
- **Production workflow** → runs on a scheduled cadence (daily)

---

## Workflow Files

```text
.github/workflows/dbt_staging.yml
.github/workflows/dbt_prod_scheduled.yml
________________________________________
1. Staging Workflow (PR / Push)
Trigger
•	Pull requests targeting main 
•	Pushes to main 
Purpose
Validates changes before they are merged by running dbt against the staging environment.
Steps
dbt deps
dbt compile --target staging
dbt build --target staging
Notes
•	dbt deps ensures dependencies are installed (standard practice even if no packages are used) 
•	dbt build runs models and tests together 
•	This workflow acts as a CI validation layer 
________________________________________
2. Production Workflow (Scheduled)
Trigger
•	Daily at 08:00 UTC 
•	Manual execution via workflow_dispatch 
Purpose
Builds and validates production models on a regular cadence.
Steps
dbt deps
dbt build --target prod
________________________________________
Environment Configuration
Both workflows rely on environment variables to configure database connections.
A repo-safe profiles.yml is included in dbt_shopify/ and reads all connection values from environment variables.
________________________________________
Required GitHub Secrets
Staging Environment
Secret Name	Description
DBT_STAGING_HOST	Postgres host
DBT_STAGING_USER	Postgres username
DBT_STAGING_PASSWORD	Postgres password
DBT_STAGING_DB	Database name
DBT_STAGING_PORT	Port (e.g. 5432)
________________________________________
Production Environment
Secret Name	Description
DBT_PROD_HOST	Postgres host
DBT_PROD_USER	Postgres username
DBT_PROD_PASSWORD	Postgres password
DBT_PROD_DB	Database name
DBT_PROD_PORT	Port (e.g. 5432)
________________________________________
Local Development (Environment Variables)
For local execution, the same variables must be set in your environment.
Example (Windows CMD):
set DBT_STAGING_HOST=localhost
set DBT_STAGING_USER=airbyte
set DBT_STAGING_PASSWORD=airbyte
set DBT_STAGING_DB=airbyte_db
set DBT_STAGING_PORT=5432
Then run:
cd dbt_shopify
dbt deps
dbt build --target staging
________________________________________
Network Assumption
GitHub-hosted runners cannot access a local Postgres instance running on a developer’s machine.
For this assessment:
•	Workflows are fully implemented and parameterized using secrets 
•	The local Postgres instance (Docker) is not accessible from GitHub Actions 
To run these workflows in a real environment, one of the following would be required:
•	Hosted Postgres instance (e.g. cloud database) 
•	Self-hosted GitHub Actions runner within the same network 
•	Secure tunnel (e.g. ngrok or SSH tunnel) 
•	VPN connectivity 
For review purposes, the equivalent commands can be run locally:
cd dbt_shopify
dbt deps
dbt build --target staging
dbt build --target prod
________________________________________
Design Notes
•	Credentials are not stored in the repository 
•	Environment-specific configuration is handled via secrets 
•	dbt targets (staging, prod) map to separate schemas 
•	CI workflow ensures model correctness before production execution 
This structure reflects a typical production dbt deployment pattern while remaining compatible with a local development setup.

# Data Engineering Assessment

## Overview

This project implements an end-to-end data pipeline for Shopify-style data, covering ingestion, transformation, governance, and orchestration.

The pipeline uses:
- **Airbyte** for ingestion
- **Postgres** for storage and RBAC
- **dbt** for transformation and modeling
- **GitHub Actions** for orchestration

The design emphasizes separation of concerns, reproducibility, and clear data ownership across layers.

---

## Architecture

```text
Airbyte (ingestion)
    ↓
Postgres (raw schema)
    ↓
dbt (staging → intermediate → marts)
    ↓
Analytics-ready tables (marts)
________________________________________
Quick Start
Run dbt (Staging)
cd dbt_shopify
dbt run --target staging
dbt test --target staging
Run dbt (Production)
dbt run --target prod
dbt test --target prod
________________________________________
Data Model
Layers
•	raw
Source-aligned data ingested via Airbyte with minimal transformation. 
•	staging
Cleaned and standardized models: 
o	snake_case naming 
o	type casting 
o	JSON flattening (LINE_ITEMS, VARIANTS) 
•	intermediate
Aggregations (e.g. order-level metrics from line items) 
•	marts
Analytics-ready tables for downstream use 
________________________________________
Mart Models
Fact Table
fct_order_summary
Grain: one row per order_id
Includes:
•	order + customer identifiers 
•	order timestamp 
•	financial and fulfillment status 
•	pricing metrics 
•	aggregated line item metrics 
________________________________________
Dimension Tables (Optional Enhancement)
dim_customers
•	Grain: one row per customer_id 
•	Contains customer attributes and metadata 
dim_products
•	Grain: one row per product_id 
•	Contains product-level descriptive fields 
These follow standard dimensional modeling patterns and provide clean analytical context without altering fact table grain.
________________________________________
Testing
dbt tests validate:
•	Primary keys (unique, not_null) 
•	Referential integrity (relationships) 
•	Core field completeness 
Run:
dbt test --target staging
________________________________________
RBAC (Postgres)
Four roles are implemented:
•	bf_airbyte → ingestion (raw schema only) 
•	bf_dbt → transformation (staging + marts) 
•	bf_developer → development access 
•	bf_bi → read-only analytics access 
Apply roles:
docker exec -i postgres-airbyte psql -U airbyte -d airbyte_db < scripts/create_roles.sql
________________________________________
Orchestration (GitHub Actions)
Two workflows are defined:
1. Staging (PR / push)
•	Trigger: PRs and pushes to main 
•	Runs: 
o	dbt deps 
o	dbt compile 
o	dbt build --target staging 
________________________________________
2. Production (Scheduled)
•	Trigger: daily at 08:00 UTC 
•	Runs: 
o	dbt deps 
o	dbt build --target prod 
________________________________________
Required GitHub Secrets
Staging
•	DBT_STAGING_HOST 
•	DBT_STAGING_USER 
•	DBT_STAGING_PASSWORD 
•	DBT_STAGING_DB 
•	DBT_STAGING_PORT 
Production
•	DBT_PROD_HOST 
•	DBT_PROD_USER 
•	DBT_PROD_PASSWORD 
•	DBT_PROD_DB 
•	DBT_PROD_PORT 
________________________________________
Assumptions
•	Source data is static (no CDC or incremental ingestion required) 
•	Full refresh ingestion is sufficient for this dataset 
•	Local Postgres is not accessible from GitHub-hosted runners 
Workflows are structured correctly but require a network-accessible database to execute in CI.
________________________________________
Documentation
Detailed implementation notes:
•	docs/airbyte.md — ingestion setup 
•	docs/rbac.md — role-based access control 
•	docs/dbt.md — transformation logic and modeling decisions 
•	docs/github_actions.md — CI/CD orchestration 
________________________________________
Design Highlights
•	Clear separation of ingestion, transformation, and analytics layers 
•	Schema-level RBAC enforcing data ownership boundaries 
•	JSON flattening limited to required structures for flexibility 
•	Environment-aware dbt configuration (staging vs production) 
•	Reproducible pipeline with CI/CD orchestration


## Original Assignment Specification

# Data Engineering Assessment

Interview challenge for data engineering candidates at Brainforge. This assessment evaluates **ingestion, transformation, orchestration, and database design** using Shopify-style data (customers, orders, products).

---

## Overview

You will build an end-to-end data pipeline: ingest JSONL into Postgres (via Airbyte), define Postgres roles and RBAC, transform data with dbt (staging + order summary mart), and run dbt via GitHub Actions (on PR and on a schedule). The task mirrors a realistic client scenario and tests your ability to make clear design choices and document them.

**Full instructions:** [CHALLENGE.md](CHALLENGE.md) — read this first.

---

## Repository structure

```
.
├── CHALLENGE.md          # Full task list and deliverables
├── README.md             # This file
└── DATA/
    ├── portable_shopify.customers.sample.jsonl
    ├── portable_shopify.orders.sample.jsonl
    ├── portable_shopify.products.sample.jsonl
    ├── METADATA_customers.md
    ├── METADATA_orders.md
    └── METADATA_products.md
```

- **Raw data:** Three JSONL files in `DATA/` (Shopify-style customers, orders, products).
- **Metadata:** See `DATA/METADATA_*.md` for field descriptions and join keys.

---

## Time expectation

- **Expected effort:** ~5–8 hours (depending on familiarity with Airbyte, dbt, and GitHub Actions).
- The challenge is open-ended; we evaluate clarity of design, documentation, and completeness as much as the implementation.

---

## Submission instructions

1. **Fork** this repository (you'll receive access once selected for the challenge).
2. Create a new branch named after yourself (e.g. `feature/jane-doe-solution`).
3. Implement your solution in your branch (Airbyte, Postgres, dbt, GitHub Actions as per [CHALLENGE.md](CHALLENGE.md)).
4. Submit a **Pull Request** to your fork when finished.
5. In the PR description include:
   - How to run Airbyte and dbt (staging vs production).
   - How to configure GitHub secrets for the workflows.
   - Any assumptions you made.
   - Optional: link to a short Loom (5–10 min) walking through your approach.
6. Share the fork link with the recruiting team.

---

## Evaluation criteria

| Area | Description |
|------|-------------|
| **Data / pipeline design** | How well the solution handles ingestion (Airbyte → Postgres), schema/namespace choices, and transformation (staging → mart). |
| **Code quality** | Structure, readability, maintainability of dbt models and any scripts; adherence to common DE practices. |
| **System design** | RBAC design (four roles), staging vs production targets, and clarity of documentation. |
| **Completeness** | All deliverables in [CHALLENGE.md](CHALLENGE.md) met; run/validation (dbt run, tests, Actions) succeeds; docs cover run steps and secrets. |
| **Presentation** | If you provide a Loom: clarity and professionalism of the walkthrough. |

---

## Contact

For technical questions about this challenge, reach out to your contact at Brainforge. Do **not** open public GitHub issues or discussions about the challenge.

---

*This assessment is used by Brainforge for Data Engineering candidates (Stage 3). Content owner: Awaish.*

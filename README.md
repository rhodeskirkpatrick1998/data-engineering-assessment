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

Airbyte (ingestion)  
↓  
Postgres (raw schema)  
↓  
dbt (staging → intermediate → marts)  
↓  
Analytics-ready tables (marts)

---

## Quick Start

### Run dbt (Staging)

cd dbt_shopify  
dbt run --target staging  
dbt test --target staging

### Run dbt (Production)

dbt run --target prod  
dbt test --target prod

---

## Data Model

### Layers

#### raw

Source-aligned data ingested via Airbyte with minimal transformation.

#### staging

Cleaned and standardized models:

- snake_case naming
- type casting
- JSON flattening (`LINE_ITEMS`, `VARIANTS`)

#### intermediate

Aggregations (for example order-level metrics from line items).

#### marts

Analytics-ready tables for downstream use.

---

## Mart Models

### Fact Table

#### fct_order_summary

**Grain:** one row per `order_id`

Includes:

- order and customer identifiers
- order timestamp
- financial and fulfillment status
- pricing metrics
- aggregated line item metrics

---

### Dimension Tables (Optional Enhancement)

#### dim_customers

- Grain: one row per `customer_id`
- Contains customer attributes and metadata

#### dim_products

- Grain: one row per `product_id`
- Contains product-level descriptive fields

These follow standard dimensional modeling patterns and provide clean analytical context without altering fact table grain.

---

## Testing

dbt tests validate:

- Primary keys (`unique`, `not_null`)
- Referential integrity (`relationships`)
- Core field completeness

Run:

dbt test --target staging

---

## RBAC (Postgres)

Four roles are implemented:

- `bf_airbyte` → ingestion (`raw` schema only)
- `bf_dbt` → transformation (`staging` + `marts`)
- `bf_developer` → development access
- `bf_bi` → read-only analytics access

Apply roles:

docker exec -i postgres-airbyte psql -U airbyte -d airbyte_db < scripts/create_roles.sql

---

## Orchestration (GitHub Actions)

Two workflows are defined:

### 1. Staging (PR / Push)

- Trigger: PRs and pushes to `main`

Runs:

- dbt deps
- dbt compile
- dbt build --target staging

### 2. Production (Scheduled)

- Trigger: daily at 08:00 UTC

Runs:

- dbt deps
- dbt build --target prod

---

## Required GitHub Secrets

### Staging

- DBT_STAGING_HOST
- DBT_STAGING_USER
- DBT_STAGING_PASSWORD
- DBT_STAGING_DB
- DBT_STAGING_PORT

### Production

- DBT_PROD_HOST
- DBT_PROD_USER
- DBT_PROD_PASSWORD
- DBT_PROD_DB
- DBT_PROD_PORT

---

## Assumptions

- Source data is static (no CDC or incremental ingestion required)
- Full refresh ingestion is sufficient for this dataset
- Local Postgres is not accessible from GitHub-hosted runners

Workflows are structured correctly but require a network-accessible database to execute in CI.

---

## Documentation

Detailed implementation notes:

- `docs/airbyte.md` — ingestion setup
- `docs/rbac.md` — role-based access control
- `docs/dbt.md` — transformation logic and modeling decisions
- `docs/github_actions.md` — CI/CD orchestration

---

## Design Highlights

- Clear separation of ingestion, transformation, and analytics layers
- Schema-level RBAC enforcing data ownership boundaries
- JSON flattening limited to required structures for flexibility
- Environment-aware dbt configuration (staging vs production)
- Reproducible pipeline with CI/CD orchestration

---

## Original Assignment Specification

## Overview

You will build an end-to-end data pipeline: ingest JSONL into Postgres (via Airbyte), define Postgres roles and RBAC, transform data with dbt (staging + order summary mart), and run dbt via GitHub Actions (on PR and on a schedule).

The task mirrors a realistic client scenario and tests your ability to make clear design choices and document them.

**Full instructions:** [CHALLENGE.md](CHALLENGE.md)

---

## Repository Structure

.
├── CHALLENGE.md  
├── README.md  
└── DATA/  
  ├── portable_shopify.customers.sample.jsonl  
  ├── portable_shopify.orders.sample.jsonl  
  ├── portable_shopify.products.sample.jsonl  
  ├── METADATA_customers.md  
  ├── METADATA_orders.md  
  └── METADATA_products.md

---

## Time Expectation

- Expected effort: ~5–8 hours
- The challenge is open-ended; clarity of design, documentation, and completeness matter as much as implementation.

---

## Submission Instructions

1. Fork this repository.
2. Create a new branch named after yourself.
3. Implement your solution.
4. Submit a Pull Request to your fork.
5. Include in the PR:
   - How to run Airbyte and dbt
   - How to configure GitHub secrets
   - Any assumptions made
   - Optional Loom walkthrough
6. Share the fork link with the recruiting team.

---

## Evaluation Criteria

| Area | Description |
|---|---|
| Data / pipeline design | Ingestion, schema choices, transformation quality |
| Code quality | Structure, readability, maintainability |
| System design | RBAC, targets, documentation |
| Completeness | Deliverables met and runs succeed |
| Presentation | Walkthrough clarity if provided |

---

## Contact

For technical questions, reach out to your Brainforge contact.

Do **not** open public GitHub issues or discussions about the challenge.

---

*This assessment is used by Brainforge for Data Engineering candidates (Stage 3). Content owner: Awaish.*
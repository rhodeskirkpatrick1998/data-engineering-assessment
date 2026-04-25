# Postgres Roles and RBAC

## Overview

This project implements schema-level role-based access control (RBAC) to clearly separate ingestion, transformation, development, and reporting responsibilities.

Roles are defined as **non-login group roles**. In a production environment, individual users or service accounts would be granted membership in these roles rather than being assigned privileges directly.

### Schemas

| Schema | Purpose |
|--------|--------|
| `raw` | Airbyte-ingested source data (source-aligned, minimally transformed) |
| `staging` | Cleaned and standardized dbt staging models |
| `marts` | Analytics-ready dbt models for reporting and BI |

---

## Roles

### `bf_developer`

Developer role used for local development and validation.

Developers can:
- Read raw source data
- Create and modify objects in the staging schema
- Read analytics outputs

Developers **cannot modify production mart tables directly**, ensuring controlled changes to analytics outputs.

#### Privileges

| Schema | Privileges |
|--------|------------|
| `raw` | SELECT |
| `staging` | SELECT, INSERT, UPDATE, DELETE, CREATE |
| `marts` | SELECT |

---

### `bf_airbyte`

Ingestion role used by Airbyte.

This role is restricted to the `raw` schema and is responsible solely for loading source data into Postgres.

#### Privileges

| Schema | Privileges |
|--------|------------|
| `raw` | SELECT, INSERT, UPDATE, DELETE, CREATE |
| `staging` | none |
| `marts` | none |

---

### `bf_dbt`

Transformation role used by dbt.

This role:
- Reads from raw source data
- Builds and maintains models in `staging` and `marts`

It **does not have permission to modify the raw schema**, preserving source data integrity.

#### Privileges

| Schema | Privileges |
|--------|------------|
| `raw` | SELECT |
| `staging` | SELECT, INSERT, UPDATE, DELETE, CREATE |
| `marts` | SELECT, INSERT, UPDATE, DELETE, CREATE |

---

### `bf_bi`

Read-only role used by BI and reporting tools.

This role is intentionally restricted to analytics-ready data to ensure that reporting is built on governed, validated models.

#### Privileges

| Schema | Privileges |
|--------|------------|
| `raw` | none |
| `staging` | none |
| `marts` | SELECT |

---

## Design Principles

This RBAC design enforces clear separation of concerns:

- **Ingestion isolation** 
Airbyte is restricted to the `raw` schema and cannot modify transformation or analytics layers.

- **Controlled transformations** 
dbt owns the `staging` and `marts` schemas but cannot write back to `raw`, preserving source fidelity.

- **Governed analytics access** 
BI tools are limited to the `marts` schema to prevent direct querying of raw or intermediate data.

- **Safe development workflow** 
Developers can iterate in `staging` while maintaining read-only access to production-ready outputs.

This structure aligns with modern data stack best practices by ensuring data integrity, maintainability, and clear ownership across pipeline stages.

## Future Considerations

In a production environment, this RBAC model could be extended with:
- Separate development and production databases or schemas
- Role inheritance for environment-specific access
- Integration with secrets management for credential rotation

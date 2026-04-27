# Airbyte + Postgres Ingestion Setup

## Overview

This document describes how raw Shopify-style JSONL data was ingested into a Postgres database using Airbyte. The goal of this layer is to create a reliable, reproducible raw ingestion zone that preserves source fidelity and enables downstream transformation via dbt.

This ingestion setup was intentionally kept simple and reproducible to support a fast MVP, with more advanced ingestion patterns such as incremental syncs or CDC deferred as future improvements.

---

## Infrastructure Setup

### 1. Postgres (Docker)

Postgres was run locally using Docker:

docker run -d \
  --name postgres-airbyte \
  -e POSTGRES_USER=airbyte \
  -e POSTGRES_PASSWORD=airbyte \
  -e POSTGRES_DB=airbyte_db \
  -p 5432:5432 \
  postgres:15

#### Connection Details

- Host: localhost
- Port: 5432
- Database: airbyte_db
- User: airbyte
- Password: airbyte

---

### 2. Airbyte (Local via abctl)

Airbyte was installed and run locally using the abctl CLI:

.\abctl.exe local install

This:

- Creates a local Kubernetes cluster (kind)
- Deploys Airbyte services
- Exposes the UI at http://localhost:8000

Credentials retrieved via:

.\abctl.exe local credentials

---

## Source Data

The dataset consists of three Shopify-style JSONL files:

DATA/<br>
├── portable_shopify.orders.sample.jsonl<br>
├── portable_shopify.customers.sample.jsonl<br>
├── portable_shopify.products.sample.jsonl<br>

---

## Ingestion Design

### Source Configuration

The File source was configured using GitHub raw URLs to provide accessible HTTPS endpoints for ingestion.

Orders:
https://raw.githubusercontent.com/rhodeskirkpatrick1998/data-engineering-assessment/main/DATA/portable_shopify.orders.sample.jsonl

Customers:
https://raw.githubusercontent.com/rhodeskirkpatrick1998/data-engineering-assessment/main/DATA/portable_shopify.customers.sample.jsonl

Products:
https://raw.githubusercontent.com/rhodeskirkpatrick1998/data-engineering-assessment/main/DATA/portable_shopify.products.sample.jsonl

Each dataset was configured as an independent Airbyte source.

---

### Destination Configuration

Postgres destination settings:

- Host: 172.18.0.1
- Port: 5432
- Database: airbyte_db
- Schema: raw
- Username: airbyte
- Password: airbyte
- SSL: disabled

The 172.18.0.1 host was used because Airbyte was running inside a Kubernetes (kind) network and needed access through the Docker bridge gateway.

---

### Sync Configuration

Each dataset was ingested through its own connection:

- shopify_orders_to_postgres_raw
- shopify_customers_to_postgres_raw
- shopify_products_to_postgres_raw

#### Sync Mode

- Delivery: Replicate Source
- Sync Mode: Full Refresh | Overwrite

#### Rationale

- Source files are static extracts with no CDC or change tracking
- Full refresh keeps the raw layer aligned to source files
- Deduplication and grain enforcement were deferred to dbt

---

## Raw Table Descriptions

### raw.orders

Raw Shopify order records, including order-level fields and nested structures such as line items, customer, shipping details, and refunds.

### raw.customers

Raw Shopify customer records, including customer attributes and nested address data.

### raw.products

Raw Shopify product records, including product attributes and nested variant information.

---

## Schema Design (Raw Layer)

All data was ingested into schema: raw

Resulting tables:

- raw.orders
- raw.customers
- raw.products

### Data Characteristics

- Mostly flattened fields
- Nested structures preserved as jsonb, for example:
  - orders.shipping_address
  - orders.payment_gateway_names
- Airbyte metadata fields included:
  - _airbyte_extracted_at
  - _PORTABLE_EXTRACTED

---

## Nested Data Handling Strategy

Nested fields such as LINE_ITEMS, VARIANTS, and ADDRESSES were preserved as jsonb in the raw layer rather than flattened during ingestion.

### Rationale

- Keeps ingestion simple and source-aligned
- Avoids premature modeling decisions in the ingestion layer
- Defers flattening and normalization to dbt, where transformations are easier to test and maintain

This keeps the raw layer as a faithful representation of source data while enabling flexible downstream modeling.

---

## Validation

### Row Counts After Ingestion

- raw.orders: 1,000 rows
- raw.customers: 100 rows
- raw.products: 20 rows

### Validation Queries

select count(*) from raw.orders;
select count(*) from raw.customers;
select count(*) from raw.products;

---

## Design Decisions

### 1. Raw Layer Fidelity

The raw layer preserves source structure with minimal transformation:

- No flattening of nested JSON
- No enforced primary keys
- No deduplication

This ensures:

- Traceability to source data
- Flexibility for downstream modeling

---

### 2. Separation of Concerns

- Airbyte = ingestion only
- dbt = transformation, normalization, and business logic

This aligns with standard modern data stack practices.

---

### 3. Connection Strategy

Each dataset uses an independent connection:

- Simplifies debugging
- Improves observability
- Avoids coupling ingestion failures across datasets

---

## Next Steps

The next phase will implement:

- dbt staging models (flattening + type standardization)
- Order summary mart
- Postgres RBAC
- GitHub Actions for orchestration
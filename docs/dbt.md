# dbt Transformation

## Project Structure

models/
staging/
intermediate/
marts/

## Targets

Two environments are defined:

- staging → schema: staging
- prod → schema: marts

Configured via profiles.yml using environment variables.

---

## Running dbt

### Staging

dbt deps
dbt build --target staging

### Production

dbt deps
dbt build --target prod

---

## Staging Models

Staging models:
- standardize column naming (snake_case)
- cast data types
- flatten nested JSON where required

Flattened:
- orders.LINE_ITEMS → stg_order_line_items
- products.VARIANTS → stg_product_variants

Not flattened:
- customers.ADDRESSES (not required downstream)

---

## Intermediate Models

- int_order_line_agg
- aggregates line items to order level
- metrics: line_item_count, total_quantity, calculated_line_item_amount

---

## Mart Models

### fct_order_summary

Primary fact table at the **order grain** (one row per `order_id`).

This model combines order attributes with aggregated line-item metrics and customer context.

**Grain**
- One row per `order_id`

**Key fields**
- `order_id`
- `customer_id`
- `order_created_at`
- `financial_status`
- `fulfillment_status`

**Metrics**
- `total_price`
- `subtotal_price`
- `total_tax`
- `total_discounts`
- `line_item_count`
- `total_quantity`
- `calculated_line_item_amount`

**Joins**
- Orders → Customers (`customer_id`)
- Orders → Line item aggregates (`order_id`)

---

### Dimension Models (Optional)

- `dim_customers` → one row per `customer_id`
- `dim_products` → one row per `product_id`

These provide descriptive context and follow standard dimensional modeling patterns without altering the order-level fact grain.

---

## Testing

dbt tests are used to enforce data quality and model assumptions:

- **Primary keys**
  - `unique` + `not_null` on identifiers (e.g. `order_id`, `customer_id`)
- **Referential integrity**
  - `relationships` test between `fct_order_summary.customer_id` and `stg_customers.customer_id`
- **Completeness**
  - `not_null` on key business fields

Run tests:

```bash
dbt test --target staging

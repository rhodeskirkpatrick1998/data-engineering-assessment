
  create view "airbyte_db"."staging_staging"."stg_orders__dbt_tmp"
    
    
  as (
    select
    "ID" as order_id,
    "NAME" as order_name,
    nullif(trim("CREATED_AT"), '')::timestamp as created_at,
    nullif(trim("EMAIL"), '') as email,
    "CURRENCY" as currency,
    "FINANCIAL_STATUS" as financial_status,
    "FULFILLMENT_STATUS" as fulfillment_status,
    "TOTAL_PRICE"::numeric as total_price,
    "SUBTOTAL_PRICE"::numeric as subtotal_price,
    "TOTAL_TAX"::numeric as total_tax,
    "TOTAL_DISCOUNTS"::numeric as total_discounts,
    nullif(trim("CUSTOMER" ->> 'ID'), '') as customer_id,
    "LINE_ITEMS" as line_items,
    "REFUNDS" as refunds,
    "SHIPPING_ADDRESS" as shipping_address,
    "BILLING_ADDRESS" as billing_address,
    "_PORTABLE_EXTRACTED" as portable_extracted_at,
    _airbyte_extracted_at
from "airbyte_db"."raw"."orders"
  );
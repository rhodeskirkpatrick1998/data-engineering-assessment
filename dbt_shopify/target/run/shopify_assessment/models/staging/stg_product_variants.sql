
  create view "airbyte_db"."staging_staging"."stg_product_variants__dbt_tmp"
    
    
  as (
    select
    p.product_id,
    nullif(trim(v.value ->> 'ID'), '') as variant_id,
    nullif(trim(v.value ->> 'SKU'), '') as sku,
    nullif(trim(v.value ->> 'TITLE'), '') as variant_title,
    nullif(trim(v.value ->> 'OPTION1'), '') as option1,
    nullif(trim(v.value ->> 'OPTION2'), '') as option2,
    nullif(trim(v.value ->> 'PRICE'), '')::numeric as price,
    nullif(trim(v.value ->> 'INVENTORY_QUANTITY'), '')::integer as inventory_quantity,
    to_timestamp(nullif(trim(v.value ->> 'CREATED_AT'), '')::numeric) as created_at,
    to_timestamp(nullif(trim(v.value ->> 'UPDATED_AT'), '')::numeric) as updated_at
from "airbyte_db"."staging_staging"."stg_products" p
cross join lateral jsonb_array_elements(p.variants) as v(value)
  );
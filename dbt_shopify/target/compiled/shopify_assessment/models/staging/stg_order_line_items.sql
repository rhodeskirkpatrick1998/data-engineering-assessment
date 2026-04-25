select
    o.order_id,
    li.value ->> 'ID' as line_item_id,
    li.value ->> 'PRODUCT_ID' as product_id,
    li.value ->> 'VARIANT_ID' as variant_id,
    li.value ->> 'SKU' as sku,
    li.value ->> 'TITLE' as product_title,
    li.value ->> 'VENDOR' as vendor,
    nullif(trim(li.value ->> 'QUANTITY'), '')::integer as quantity,
    nullif(trim(li.value ->> 'PRICE'), '')::numeric as price
from "airbyte_db"."staging_staging"."stg_orders" o
cross join lateral jsonb_array_elements(o.line_items) as li(value)
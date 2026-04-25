select
    order_id,
    count(*) as line_item_count,
    sum(quantity) as total_quantity,
    sum(quantity * price) as calculated_line_item_amount
from "airbyte_db"."staging_staging"."stg_order_line_items"
group by order_id
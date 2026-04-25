select
    o.order_id,
    o.order_name,
    o.customer_id,
    c.admin_graphql_api_id as customer_graphql_api_id,
    o.created_at as order_created_at,
    o.email as order_email,
    o.currency,
    o.financial_status,
    o.fulfillment_status,
    o.total_price,
    o.subtotal_price,
    o.total_tax,
    o.total_discounts,
    coalesce(l.line_item_count, 0) as line_item_count,
    coalesce(l.total_quantity, 0) as total_quantity,
    coalesce(l.calculated_line_item_amount, 0) as calculated_line_item_amount,
    o.portable_extracted_at,
    o._airbyte_extracted_at
from {{ ref('stg_orders') }} o
left join {{ ref('stg_customers') }} c
    on o.customer_id = c.customer_id
left join {{ ref('int_order_line_agg') }} l
    on o.order_id = l.order_id
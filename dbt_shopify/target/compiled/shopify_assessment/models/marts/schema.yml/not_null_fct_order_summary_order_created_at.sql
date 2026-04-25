
    
    



select order_created_at
from "airbyte_db"."staging_marts"."fct_order_summary"
where order_created_at is null



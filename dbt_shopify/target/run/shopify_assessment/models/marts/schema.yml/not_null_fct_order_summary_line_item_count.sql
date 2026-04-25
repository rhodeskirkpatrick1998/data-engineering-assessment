
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select line_item_count
from "airbyte_db"."staging_marts"."fct_order_summary"
where line_item_count is null



  
  
      
    ) dbt_internal_test
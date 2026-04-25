
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select order_created_at
from "airbyte_db"."staging_marts"."fct_order_summary"
where order_created_at is null



  
  
      
    ) dbt_internal_test
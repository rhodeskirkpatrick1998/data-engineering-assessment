
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select total_price
from "airbyte_db"."staging_marts"."fct_order_summary"
where total_price is null



  
  
      
    ) dbt_internal_test
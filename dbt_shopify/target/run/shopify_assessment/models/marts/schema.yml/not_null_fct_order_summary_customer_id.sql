
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select customer_id
from "airbyte_db"."staging_marts"."fct_order_summary"
where customer_id is null



  
  
      
    ) dbt_internal_test
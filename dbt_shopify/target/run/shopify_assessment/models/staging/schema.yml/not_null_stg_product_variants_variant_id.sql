
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select variant_id
from "airbyte_db"."staging_staging"."stg_product_variants"
where variant_id is null



  
  
      
    ) dbt_internal_test
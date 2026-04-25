
  
    

  create  table "airbyte_db"."staging_marts"."dim_products__dbt_tmp"
  
  
    as
  
  (
    select
    product_id,
    admin_graphql_api_id,
    product_title,
    product_type,
    vendor,
    tags,
    options,
    variants,
    portable_extracted_at,
    _airbyte_extracted_at
from "airbyte_db"."staging_staging"."stg_products"
  );
  
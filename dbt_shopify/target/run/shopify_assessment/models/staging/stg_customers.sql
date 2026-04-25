
  create view "airbyte_db"."staging_staging"."stg_customers__dbt_tmp"
    
    
  as (
    select
    "ID" as customer_id,
    "ADMIN_GRAPHQL_API_ID" as admin_graphql_api_id,
    to_timestamp(nullif("CREATED_AT"::text, '')::numeric) as created_at,
    "TAGS" as tags,
    "ADDRESSES" as addresses,
    "_PORTABLE_EXTRACTED" as portable_extracted_at,
    _airbyte_extracted_at
from "airbyte_db"."raw"."customers"
  );
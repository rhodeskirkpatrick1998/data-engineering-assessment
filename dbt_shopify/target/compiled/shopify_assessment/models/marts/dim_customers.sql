select
    customer_id,
    admin_graphql_api_id,
    created_at,
    tags,
    addresses,
    portable_extracted_at,
    _airbyte_extracted_at
from "airbyte_db"."staging_staging"."stg_customers"
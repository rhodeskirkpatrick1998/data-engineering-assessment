select
    "ID" as product_id,
    "ADMIN_GRAPHQL_API_ID" as admin_graphql_api_id,
    nullif(trim("TITLE"), '') as product_title,
    nullif(trim("PRODUCT_TYPE"), '') as product_type,
    nullif(trim("VENDOR"), '') as vendor,
    "TAGS" as tags,
    "OPTIONS" as options,
    "VARIANTS" as variants,
    "_PORTABLE_EXTRACTED" as portable_extracted_at,
    _airbyte_extracted_at
from {{ source('raw_shopify', 'products') }}
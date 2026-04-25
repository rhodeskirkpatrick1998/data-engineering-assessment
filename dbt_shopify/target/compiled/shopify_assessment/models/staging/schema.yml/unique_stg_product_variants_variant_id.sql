
    
    

select
    variant_id as unique_field,
    count(*) as n_records

from "airbyte_db"."staging_staging"."stg_product_variants"
where variant_id is not null
group by variant_id
having count(*) > 1



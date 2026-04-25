
    
    

select
    order_id as unique_field,
    count(*) as n_records

from "airbyte_db"."staging_marts"."fct_order_summary"
where order_id is not null
group by order_id
having count(*) > 1



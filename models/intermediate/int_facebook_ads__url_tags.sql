
with base as (

    select *
    from {{ var('creative_history') }}

), 

required_fields as (

    select
        _fivetran_id,
        creative_id,
        url_tags
    from base
    where url_tags is not null
), 

{{ get_url_tags_query() }} 

select *
from fields
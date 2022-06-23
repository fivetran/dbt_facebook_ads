
with base as (

    select *
    from {{ ref('int_facebook_ads__creative_history') }}
    where first_creative_record = true
), 

required_fields as (

    select
        _fivetran_id,
        creative_id,
        url_tags
    from base
), 

{{ get_url_tags_query() }} 

select *
from fields
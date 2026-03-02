{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select *
    from {{ ref('stg_facebook_ads__creative_history') }}
    where is_most_recent_record = true
), 

required_fields as (

    select
        source_relation,
        _fivetran_id,
        creative_id,
        url_tags
    from base
    where url_tags is not null
), 

{{ get_url_tags_query(
    output_cte_name='fields', 
    url_tags_datatype=get_column_datatype('stg_facebook_ads__creative_history', 'url_tags')
) }} 

select *
from fields
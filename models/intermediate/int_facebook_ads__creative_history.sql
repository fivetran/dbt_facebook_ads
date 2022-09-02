{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

{% set url_field = "coalesce(page_link,template_page_link)" %}

with base as (

    select *
    from {{ var('creative_history') }}
    where is_most_recent_record = true

), 

url_tags as (

    select *
    from {{ ref('facebook_ads__url_tags') }}
), 

url_tags_pivoted as (

    select 
        _fivetran_id,
        creative_id,
        min(case when key = 'utm_source' then value end) as utm_source,
        min(case when key = 'utm_medium' then value end) as utm_medium,
        min(case when key = 'utm_campaign' then value end) as utm_campaign,
        min(case when key = 'utm_content' then value end) as utm_content,
        min(case when key = 'utm_term' then value end) as utm_term
    from url_tags
    group by 1,2

), 

fields as (

    select
        base._fivetran_id,
        base.creative_id,
        base.account_id,
        base.creative_name,
        {{ url_field }} as url,
        {{ dbt_utils.split_part(url_field, "'?'", 1) }} as base_url,
        {{ dbt_utils.get_url_host(url_field) }} as url_host,
        '/' || {{ dbt_utils.get_url_path(url_field) }} as url_path,
        coalesce(url_tags_pivoted.utm_source, {{ dbt_utils.get_url_parameter(url_field, 'utm_source') }}) as utm_source,
        coalesce(url_tags_pivoted.utm_medium, {{ dbt_utils.get_url_parameter(url_field, 'utm_medium') }}) as utm_medium,
        coalesce(url_tags_pivoted.utm_campaign, {{ dbt_utils.get_url_parameter(url_field, 'utm_campaign') }}) as utm_campaign,
        coalesce(url_tags_pivoted.utm_content, {{ dbt_utils.get_url_parameter(url_field, 'utm_content') }}) as utm_content,
        coalesce(url_tags_pivoted.utm_term, {{ dbt_utils.get_url_parameter(url_field, 'utm_term') }}) as utm_term
    from base
    left join url_tags_pivoted
        on base._fivetran_id = url_tags_pivoted._fivetran_id
        and base.creative_id = url_tags_pivoted.creative_id
)

select *
from fields
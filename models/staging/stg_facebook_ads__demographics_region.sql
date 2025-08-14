{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_region', False)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__demographics_region_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__demographics_region_tmp')),
                staging_columns=get_demographics_region_columns()
            )
        }}
        {{ fivetran_utils.source_relation(
            union_schema_variable='facebook_ads_union_schemas', 
            union_database_variable='facebook_ads_union_databases') 
        }}
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_id as region_id,
        region,
        date as date_day,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        impressions,
        coalesce(inline_link_clicks,0) as clicks,
        spend,
        reach,
        frequency

        {{ fivetran_utils.fill_pass_through_columns('facebook_ads__demographics_region_passthrough_metrics') }}

    from fields
)

select *
from final

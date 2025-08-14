{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__basic_ad_action_values_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__basic_ad_action_values_tmp')),
                staging_columns=get_basic_ad_action_values_columns()
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
        lower(action_type) as action_type,
        cast(ad_id as {{ dbt.type_bigint() }}) as ad_id,
        date as date_day,
        cast(coalesce(value, 0) as {{ dbt.type_float() }}) as conversions_value

        {{ facebook_ads_fill_pass_through_columns(var('facebook_ads__basic_ad_action_values_passthrough_metrics')) }}

    from fields
)

select *
from final

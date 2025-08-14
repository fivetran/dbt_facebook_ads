{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_region', False)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__demographics_region_actions_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__demographics_region_actions_tmp')),
                staging_columns=get_demographics_region_actions_columns()
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
        lower(action_type) as action_type,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        date as date_day,
        cast(coalesce(value, 0) as {{ dbt.type_float() }}) as conversions

    {{ fivetran_utils.fill_pass_through_columns('facebook_ads__demographics_region_actions_passthrough_metrics') }}
    
    from fields
)

select *
from final

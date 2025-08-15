{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__account_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__account_history_tmp')),
                staging_columns=get_account_history_columns()
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
        cast(id as {{ dbt.type_bigint() }}) as account_id,
        _fivetran_synced,
        name as account_name,
        account_status,
        business_country_code,
        business_state,
        created_time as created_at,
        currency,
        timezone_name,
        timezone_offset_hours_utc,
        min_daily_budget,
        case when id is null and _fivetran_synced is null 
            then row_number() over (partition by source_relation order by source_relation)
        else row_number() over (partition by source_relation, id order by _fivetran_synced desc) end = 1 as is_most_recent_record
    from fields

)

select * 
from final
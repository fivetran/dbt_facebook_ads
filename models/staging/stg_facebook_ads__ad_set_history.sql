{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__ad_set_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__ad_set_history_tmp')),
                staging_columns=get_ad_set_history_columns()
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
        updated_time as updated_at,
        cast(id as {{ dbt.type_bigint() }}) as ad_set_id,
        name as ad_set_name,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        cast(campaign_id as {{ dbt.type_bigint() }}) as campaign_id,
        start_time as start_at,
        end_time as end_at,
        bid_strategy,
        daily_budget,
        budget_remaining,
        status,
        optimization_goal,
        case when id is null and updated_time is null
            then row_number() over (partition by source_relation order by source_relation)
        else row_number() over (partition by source_relation, id order by updated_time desc) end = 1 as is_most_recent_record
    from fields

)

select * 
from final

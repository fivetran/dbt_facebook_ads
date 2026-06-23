{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__campaign_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__campaign_history_tmp')),
                staging_columns=get_campaign_history_columns()
            )
        }}
        
    
        {{ fivetran_utils.apply_source_relation(package_name='facebook_ads') }}

    from base
),

final as (

    select
        source_relation, 
        updated_time as updated_at,
        created_time as created_at,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        cast(id as {{ dbt.type_bigint() }}) as campaign_id,
        name as campaign_name,
        start_time as start_at,
        stop_time as end_at,
        status,
        daily_budget,
        lifetime_budget,
        budget_remaining,
        case when id is null and updated_time is null 
            then row_number() over ({{ fivetran_utils.partition_by_source_relation(package_name='facebook_ads', has_other_partitions='no') }} order by source_relation)
        else row_number() over (partition by id {{ fivetran_utils.partition_by_source_relation(package_name='facebook_ads') }} order by updated_time desc) end = 1 as is_most_recent_record
    from fields

)

select * 
from final
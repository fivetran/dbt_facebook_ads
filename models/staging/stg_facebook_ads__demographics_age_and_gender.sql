{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_age_and_gender', False)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__demographics_age_and_gender_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__demographics_age_and_gender_tmp')),
                staging_columns=get_demographics_age_and_gender_columns()
            )
        }}
        {{ fivetran_utils.apply_source_relation(package_name='facebook_ads') }}
    from base
),

final as (
    
    select 
        source_relation, 
        _fivetran_id as age_gender_id,
        coalesce(age, 'Unknown') as age,
        -- Facebook age ranges follow the <min>-<max> format, and the oldest range is open-ended, such as 65+, which gets a max_age of 100. Other values, such as Unknown, return null.
        case
            when age like '%-%' then cast(nullif({{ dbt.split_part('age', "'-'", 1) }}, '') as {{ dbt.type_int() }})
            when age like '%+' then cast(nullif({{ dbt.replace('age', "'+'", "''") }}, '') as {{ dbt.type_int() }})
        end as min_age,
        case
            when age like '%-%' then cast(nullif({{ dbt.split_part('age', "'-'", 2) }}, '') as {{ dbt.type_int() }})
            when age like '%+' then 100
        end as max_age,
        coalesce(gender, 'unknown') as gender,
        date as date_day,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        impressions,
        coalesce(inline_link_clicks,0) as clicks,
        spend,
        reach,
        frequency

        {{ fivetran_utils.fill_pass_through_columns('facebook_ads__demographics_age_and_gender_passthrough_metrics') }}

    from fields
)

select *
from final
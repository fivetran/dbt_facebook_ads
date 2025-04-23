{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographic_region', True)) }}

with accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = true

),

demographics_region as (

    select *
    from {{ ref('stg_facebook_ads__demographics_region') }}
),

demographics_region_actions as (

    select *
    from {{ ref('stg_facebook_ads__demographics_region_actions') }}
),

region_conversions as (

    select
        source_relation,
        account_id,
        region_id,
        date_day,
        sum(conversions) as conversions

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_region_actions_passthrough_metrics', transform='sum') }}

    from demographics_region_actions
    {% if var('facebook_ads__conversion_action_types') -%}
    where 
        {# Limit conversions to the chosen action types #}
        {% for action_type in var('facebook_ads__conversion_action_types') -%}
            (
            {%- if action_type.name -%}
                action_type = '{{ action_type.name }}'
            {%- elif action_type.pattern -%}
                action_type like '{{ action_type.pattern }}'
            {%- endif -%}

            {% if action_type.where_sql %}
                and {{ action_type.where_sql }}
            {%- endif -%}
            ) {% if not loop.last %} or {% endif %}
        {%- endfor %}
    {% endif %}
    {{ dbt_utils.group_by(n=4) }}
),

joined as (

    select 
        demographics_region.source_relation,
        demographics_region.date_day,
        demographics_region.region_id,
        demographics_region.region,
        demographics_region.account_id,
        accounts.account_name,
        accounts.business_state as account_business_state,
        accounts.business_country_code as account_business_country_code,
        accounts.timezone_name as account_timezone,
        accounts.timezone_offset_hours_utc as account_timezone_offset_hours_utc,
        accounts.currency as account_currency,
        accounts.min_daily_budget as account_min_daily_budget,

        sum(demographics_region.impressions) as impressions,
        sum(demographics_region.clicks) as clicks,
        sum(demographics_region.spend) as spend,
        sum(demographics_region.reach) as reach,
        sum(demographics_region.frequency) as frequency,
        sum(coalesce(region_conversions.conversions, 0)) as conversions

        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_region_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_region_actions_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
    
    from demographics_region
    left join region_conversions
        on demographics_region.region_id = region_conversions.region_id
        and demographics_region.account_id = region_conversions.account_id
        and demographics_region.date_day = region_conversions.date_day
        and demographics_region.source_relation = region_conversions.source_relation
    left join accounts
        on demographics_region.account_id = accounts.account_id
        and demographics_region.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(n=12) }}
)

select *
from joined
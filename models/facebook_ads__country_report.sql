{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_country', False)) }}

with accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = true

),

demographics_country as (

    select *
    from {{ ref('stg_facebook_ads__demographics_country') }}
),

demographics_country_actions as (

    select *
    from {{ ref('stg_facebook_ads__demographics_country_actions') }}
),

country_conversions as (

    select
        source_relation,
        account_id,
        country_id,
        date_day,
        sum(conversions) as conversions

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_country_actions_passthrough_metrics', transform='sum') }}

    from demographics_country_actions
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
        demographics_country.source_relation,
        demographics_country.date_day,
        demographics_country.country_id,
        demographics_country.country,
        demographics_country.account_id,
        accounts.account_name,
        accounts.business_country_code as account_business_country_code,
        accounts.timezone_name as account_timezone,
        accounts.timezone_offset_hours_utc as account_timezone_offset_hours_utc,
        accounts.currency as account_currency,
        accounts.min_daily_budget as account_min_daily_budget,

        sum(demographics_country.impressions) as impressions,
        sum(demographics_country.clicks) as clicks,
        sum(demographics_country.spend) as spend,
        sum(demographics_country.reach) as reach,
        sum(demographics_country.frequency) as frequency,
        sum(coalesce(country_conversions.conversions, 0)) as conversions

        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_country_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_country_actions_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
    
    from demographics_country
    left join country_conversions
        on demographics_country.country_id = country_conversions.country_id
        and demographics_country.account_id = country_conversions.account_id
        and demographics_country.date_day = country_conversions.date_day
        and demographics_country.source_relation = country_conversions.source_relation
    left join accounts
        on demographics_country.account_id = accounts.account_id
        and demographics_country.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(n=11) }}
)

select *
from joined
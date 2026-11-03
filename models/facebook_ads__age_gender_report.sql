{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_age_and_gender', False)) }}

with accounts as (

    select *
    from {{ ref('stg_facebook_ads__account_history') }}
    where is_most_recent_record = true

),

demographics_age_and_gender as (

    select *
    from {{ ref('stg_facebook_ads__demographics_age_and_gender') }}
),

demographics_age_and_gender_actions as (

    select *
    from {{ ref('stg_facebook_ads__demographics_age_and_gender_actions') }}
),

age_gender_conversions as (

    select
        source_relation,
        account_id,
        age_gender_id,
        date_day,
        sum(conversions) as conversions

        {% for action_type in var('facebook_ads__conversion_action_types') %}
        ,sum(case when 
        {% if action_type.name %}
         action_type  = '{{ action_type.name }}'
        {% elif action_type.pattern %}
         action_type like '{{ action_type.pattern }}'
        {% endif %}

        {% if action_type.where_sql %}
        and {{ action_type.where_sql }}
        {% endif %}
        then conversions else 0 end) 
             as {{ facebook_action_slug(action_type) }}_conversions
        {% endfor %}

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_age_and_gender_actions_passthrough_metrics', transform='sum') }}

    from demographics_age_and_gender_actions
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
        demographics_age_and_gender.source_relation,
        demographics_age_and_gender.date_day,
        demographics_age_and_gender.age_gender_id,
        demographics_age_and_gender.age,
        demographics_age_and_gender.min_age,
        demographics_age_and_gender.max_age,
        demographics_age_and_gender.gender,
        demographics_age_and_gender.account_id,
        accounts.account_name,
        accounts.business_state as account_business_state,
        accounts.business_country_code as account_business_country_code,
        accounts.timezone_name as account_timezone,
        accounts.timezone_offset_hours_utc as account_timezone_offset_hours_utc,
        accounts.currency as account_currency,
        accounts.min_daily_budget as account_min_daily_budget,

        sum(demographics_age_and_gender.impressions) as impressions,
        sum(demographics_age_and_gender.clicks) as clicks,
        sum(demographics_age_and_gender.spend) as spend,
        sum(demographics_age_and_gender.reach) as reach,
        sum(demographics_age_and_gender.frequency) as frequency,
        sum(coalesce(age_gender_conversions.conversions, 0)) as conversions

        {% for action_type in var('facebook_ads__conversion_action_types') %}
        , sum(coalesce(age_gender_conversions.{{ facebook_action_slug(action_type) }}_conversions, 0)) 
        as {{ facebook_action_slug(action_type) }}_conversions
        {% endfor %}

        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_age_and_gender_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__demographics_age_and_gender_actions_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
    
    from demographics_age_and_gender
    left join age_gender_conversions
        on demographics_age_and_gender.age_gender_id = age_gender_conversions.age_gender_id
        and demographics_age_and_gender.account_id = age_gender_conversions.account_id
        and demographics_age_and_gender.date_day = age_gender_conversions.date_day
        and demographics_age_and_gender.source_relation = age_gender_conversions.source_relation
    left join accounts
        on demographics_age_and_gender.account_id = accounts.account_id
        and demographics_age_and_gender.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(n=15) }}
)

select *
from joined
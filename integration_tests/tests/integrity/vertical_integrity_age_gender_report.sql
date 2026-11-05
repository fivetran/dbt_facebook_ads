{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false) and var('facebook_ads__using_demographics_age_and_gender', false)
) }}

with age_gender_source as (

    select 
        account_id,
        age_gender_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency
    from {{ ref('stg_facebook_ads__demographics_age_and_gender') }}
    group by 1,2
),

age_gender_actions_source as (

    select 
        account_id,
        age_gender_id,
        sum(conversions) as conversions
    from {{ ref('stg_facebook_ads__demographics_age_and_gender_actions') }}
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

    group by 1,2
),

model as (

    select 
        account_id,
        age_gender_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency,
        sum(conversions) as conversions

    from {{ ref('facebook_ads__age_gender_report') }}
    group by 1,2
),

final as (

    select
        age_gender_source.account_id,
        age_gender_source.age_gender_id,
        age_gender_source.row_count as source_row_count,
        age_gender_source.impressions as source_impressions,
        age_gender_source.clicks as source_clicks,
        age_gender_source.spend as source_spend,
        age_gender_source.reach as source_reach,
        age_gender_source.frequency as source_frequency,
        age_gender_actions_source.conversions as source_conversions,
        model.row_count as model_row_count,
        model.impressions as model_impressions,
        model.clicks as model_clicks,
        model.spend as model_spend,
        model.reach as model_reach,
        model.frequency as model_frequency,
        model.conversions as model_conversions
        
    from age_gender_source
    left join age_gender_actions_source 
        on age_gender_source.account_id = age_gender_actions_source.account_id
        and age_gender_source.age_gender_id = age_gender_actions_source.age_gender_id
    full outer join model
        on age_gender_source.account_id = model.account_id
        and age_gender_source.age_gender_id = model.age_gender_id
)

select *
from final 
where 
    abs(source_row_count - model_row_count) > 0
    or abs(source_impressions - model_impressions) > 0.0001
    or abs(source_clicks - model_clicks) > 0.0001
    or abs(source_spend - model_spend) > 0.0001
    or abs(source_reach - model_reach) > 0.0001
    or abs(source_frequency - model_frequency) > 0.0001
    or abs(source_conversions - model_conversions) > 0.0001
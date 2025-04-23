{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with country_source as (

    select 
        account_id,
        country_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency
    from {{ ref('stg_facebook_ads__demographics_country') }}
    group by 1,2
),

country_actions_source as (

    select 
        account_id,
        country_id,
        sum(conversions) as conversions
    from {{ ref('stg_facebook_ads__demographics_country_actions') }}
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
        country_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency,
        sum(conversions) as conversions

    from {{ ref('facebook_ads__country_report') }}
    group by 1,2
),

final as (

    select
        country_source.account_id,
        country_source.country_id,
        country_source.row_count as source_row_count,
        country_source.impressions as source_impressions,
        country_source.clicks as source_clicks,
        country_source.spend as source_spend,
        country_source.reach as source_reach,
        country_source.frequency as source_frequency,
        country_actions_source.conversions as source_conversions,
        model.row_count as model_row_count,
        model.impressions as model_impressions,
        model.clicks as model_clicks,
        model.spend as model_spend,
        model.reach as model_reach,
        model.frequency as model_frequency,
        model.conversions as model_conversions
        
    from country_source 
    left join country_actions_source 
        on country_source.account_id = country_actions_source.account_id
        and country_source.country_id = country_actions_source.country_id
    full outer join model
        on country_source.account_id = model.account_id
        and country_source.country_id = model.country_id
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
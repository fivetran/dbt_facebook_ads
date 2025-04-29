{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with region_source as (

    select 
        account_id,
        region_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency
    from {{ ref('stg_facebook_ads__demographics_region') }}
    group by 1,2
),

region_actions_source as (

    select 
        account_id,
        region_id,
        sum(conversions) as conversions
    from {{ ref('stg_facebook_ads__demographics_region_actions') }}
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
        region_id,
        count(*) as row_count,
        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(reach) as reach,
        sum(frequency) as frequency,
        sum(conversions) as conversions

    from {{ ref('facebook_ads__region_report') }}
    group by 1,2
),

final as (

    select
        region_source.account_id,
        region_source.region_id,
        region_source.row_count as source_row_count,
        region_source.impressions as source_impressions,
        region_source.clicks as source_clicks,
        region_source.spend as source_spend,
        region_source.reach as source_reach,
        region_source.frequency as source_frequency,
        region_actions_source.conversions as source_conversions,
        model.row_count as model_row_count,
        model.impressions as model_impressions,
        model.clicks as model_clicks,
        model.spend as model_spend,
        model.reach as model_reach,
        model.frequency as model_frequency,
        model.conversions as model_conversions
        
    from region_source
    left join region_actions_source 
        on region_source.account_id = region_actions_source.account_id
        and region_source.region_id = region_actions_source.region_id
    full outer join model
        on region_source.account_id = model.account_id
        and region_source.region_id = model.region_id
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
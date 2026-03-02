{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with ad_source as (

    select
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('stg_facebook_ads__basic_ad_actions') }}

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
),

ad_source_values as (

    select
        sum(coalesce(conversions_value, 0)) as conversions_value
    from {{ ref('stg_facebook_ads__basic_ad_action_values') }}
),

ad_model as (

    select
        sum(coalesce(conversions, 0)) as conversions,
        sum(coalesce(conversions_value, 0)) as conversions_value
    from {{ ref('facebook_ads__ad_report') }}
)

select
    ad_source.conversions as ad_source_conversions,
    ad_model.conversions as ad_model_conversions,
    ad_source_values.conversions_value as ad_source_conversions_value,
    ad_model.conversions_value as ad_model_conversions_value
from ad_model
left join ad_source on true
left join ad_source_values on true
where ad_model.conversions != ad_source.conversions
or ad_model.conversions_value != ad_source_values.conversions_value
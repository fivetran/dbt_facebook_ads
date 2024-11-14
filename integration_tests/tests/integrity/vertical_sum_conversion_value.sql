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

ad_model as (

    select 
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__ad_report') }}
)


select 
    ad_source.*
from ad_model 
join ad_source on true
where ad_model.conversions != ad_source.conversions
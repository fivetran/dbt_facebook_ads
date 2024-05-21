with report as (

    select *
    from {{ var('basic_ad_actions') }}
),

metrics as (

    select
        source_relation,
        ad_id,
        date_day,
        sum(conversion_value) as conversion_value

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_actions_passthrough_metrics', transform='sum') }}

    from report
    where 
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

    group by 1,2,3
)

select * 
from metrics
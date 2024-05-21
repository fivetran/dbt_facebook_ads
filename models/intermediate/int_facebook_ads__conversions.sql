with report as (

    select *
    from {{ var('basic_ad_actions') }}
),

limit_action_types as (

    select
        source_relation,
        action_type,
        ad_id,
        date_day,
        conversion_value

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_actions_passthrough_metrics') }}

    from report
    where 
    {# {% set name_list = [] %} #}
    {%- for action_type in var('facebook_ads__conversion_action_types') -%}
        (
        {%- if action_type.name -%}
            {# {%- do name_list.append("'" ~ action_type.name ~ "'") -%} #}
            action_type = '{{ action_type.name }}'
        {%- elif action_type.pattern -%}
            action_type like '{{ action_type.pattern }}'
        {%- endif -%}

        {% if action_type.where_sql %}
            and {{ action_type.where_sql }}
        {%- endif -%}
        ) {% if not loop.last %} or {% endif %}
    {%- endfor %}
    
    {# {% if name_list|length > 0 -%}
        and action_type in ({{ name_list|join(", ") }})
    {%- endif -%} #}
)

select * 
from limit_action_types
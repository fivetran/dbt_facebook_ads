{# 
    Adapted from fivetran_utils.fill_pass_through_columns() macro. 
    Ensures that downstream summations work if a connector schema is missing one of your facebook_ads__basic_ad_action_values_passthrough_metrics or facebook_ads__basic_ad_actions_passthrough_metrics
#}

{% macro facebook_ads_fill_pass_through_columns(pass_through_fields) %}

{% if pass_through_fields %}
    {% for field in pass_through_fields %}
        {% if field.transform_sql %}
            , coalesce(cast({{ field.transform_sql }} as {{ dbt.type_float() }}), 0) as {{ field.alias if field.alias else field.name }}
        {% else %}
            , coalesce(cast({{ field.alias if field.alias else field.name }} as {{ dbt.type_float() }}), 0) as {{ field.alias if field.alias else field.name }}
        {% endif %}
    {% endfor %}
{% endif %}

{% endmacro %}
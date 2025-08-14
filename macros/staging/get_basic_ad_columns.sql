{% macro get_basic_ad_columns() %}

{% set columns = [
    {"name": "ad_id", "datatype": dbt.type_string()},
    {"name": "ad_name", "datatype": dbt.type_string()},
    {"name": "adset_name", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "account_id", "datatype": dbt.type_int()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "inline_link_clicks", "datatype": dbt.type_int()},
    {"name": "spend", "datatype": dbt.type_float()},
    {"name": "reach", "datatype": dbt.type_int()},
    {"name": "frequency", "datatype": dbt.type_float()}
] %}

{# 
    Reach and Frequency are not included in downstream models by default, though they are included in the staging model.
    The below ensures that users can add Reach and Frequency to downstream models with the `facebook_ads__basic_ad_passthrough_metrics` variable
    while avoiding duplicate column errors.
 #}
{% set unique_passthrough = [] %}
{% for field in var('facebook_ads__basic_ad_passthrough_metrics') %}
    {% if (field.alias if field.alias else field.name)|lower not in ('reach', 'frequency') %}
        {% do unique_passthrough.append({"name": field.name, "alias": field.alias}) %}
    {% endif %}
{% endfor %}

{{ fivetran_utils.add_pass_through_columns(columns, unique_passthrough) }}

{{ return(columns) }}

{% endmacro %}

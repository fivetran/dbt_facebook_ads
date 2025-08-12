{% macro get_demographics_region_actions_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "action_type", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "value", "datatype": dbt.type_float()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('facebook_ads__demographics_region_actions_passthrough_metrics')) }} 

{{ return(columns) }}

{% endmacro %}

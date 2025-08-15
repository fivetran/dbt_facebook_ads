{% macro get_basic_ad_action_values_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "action_type", "datatype": dbt.type_string()},
    {"name": "ad_id", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "value", "datatype": dbt.type_float()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('facebook_ads__basic_ad_action_values_passthrough_metrics')) }}

{{ return(columns) }}

{% endmacro %}
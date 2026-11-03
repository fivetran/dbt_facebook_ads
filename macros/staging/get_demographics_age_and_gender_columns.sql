{% macro get_demographics_age_and_gender_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "age", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "frequency", "datatype": dbt.type_float()},
    {"name": "gender", "datatype": dbt.type_string()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "inline_link_clicks", "datatype": dbt.type_int()},
    {"name": "reach", "datatype": dbt.type_int()},
    {"name": "spend", "datatype": dbt.type_float()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('facebook_ads__demographics_age_and_gender_passthrough_metrics')) }} 

{{ return(columns) }}

{% endmacro %}

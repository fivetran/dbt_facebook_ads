{% macro get_account_history_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "account_status", "datatype": dbt.type_string()},
    {"name": "business_country_code", "datatype": dbt.type_string()},
    {"name": "created_time", "datatype": dbt.type_timestamp()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "timezone_name", "datatype": dbt.type_string()},
    {"name": "timezone_offset_hours_utc", "datatype": dbt.type_float()},
    {"name": "business_state", "datatype": dbt.type_string()},
    {"name": "min_daily_budget", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_campaign_history_columns() %}

{% set columns = [
    {"name": "updated_time", "datatype": dbt.type_timestamp()},
    {"name": "created_time", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "stop_time", "datatype": dbt.type_timestamp()},    
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "daily_budget", "datatype": dbt.type_int()},
    {"name": "lifetime_budget", "datatype": dbt.type_int()},
    {"name": "budget_remaining", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}

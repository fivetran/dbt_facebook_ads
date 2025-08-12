{% macro get_ad_set_history_columns() %}

{% set columns = [
    {"name": "updated_time", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "account_id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "end_time", "datatype": dbt.type_timestamp()},
    {"name": "bid_strategy", "datatype": dbt.type_string()},
    {"name": "daily_budget", "datatype": dbt.type_int()},
    {"name": "budget_remaining", "datatype": dbt.type_int()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "optimization_goal", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}

{% macro get_ad_history_columns() %}

{% set columns = [
    {"name": "updated_time", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "account_id", "datatype": dbt.type_int()},
    {"name": "ad_set_id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "creative_id", "datatype": dbt.type_int()},
    {"name": "conversion_domain", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}

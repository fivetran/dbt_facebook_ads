{% macro get_column_datatype(table_name, column_name) -%}
    {{ return(adapter.dispatch('get_column_datatype', 'facebook_ads')(table_name, column_name)) }}
{% endmacro %}

{% macro default__get_column_datatype(table_name, column_name) %}
    {%- set columns = adapter.get_columns_in_relation(ref(table_name)) -%}
    {%- for col in columns if col.name == column_name -%}
        {{ return(col.dtype | lower) }}
    {%- endfor -%}
{%- endmacro %}
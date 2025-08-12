{% macro get_creative_history_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "account_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "page_link", "datatype": dbt.type_string()},
    {"name": "template_page_link", "datatype": dbt.type_string()},
    {"name": "url_tags", "datatype": dbt.type_string()},
    {"name": "asset_feed_spec_link_urls", "datatype": dbt.type_string()},
    {"name": "object_story_link_data_child_attachments", "datatype": dbt.type_string()},
    {"name": "object_story_link_data_caption", "datatype": dbt.type_string()},
    {"name": "object_story_link_data_description", "datatype": dbt.type_string()},
    {"name": "object_story_link_data_link", "datatype": dbt.type_string()},
    {"name": "object_story_link_data_message", "datatype": dbt.type_string()},
    {"name": "template_app_link_spec_android", "datatype": dbt.type_string()},
    {"name": "template_app_link_spec_ios", "datatype": dbt.type_string()},
    {"name": "template_app_link_spec_ipad", "datatype": dbt.type_string()},
    {"name": "template_app_link_spec_iphone", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}

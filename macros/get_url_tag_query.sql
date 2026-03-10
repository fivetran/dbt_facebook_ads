{# This macro generates database-specific SQL queries to extract and unnest URL tags into key-value pairs.

Parameters:
- output_cte_name: Name for the output CTE containing the parsed URL tag data
- url_tags_datatype: The detected datatype of the url_tags column (passed from calling macro)

Approach:
- Receives the url_tags datatype as a parameter to determine processing method
- For native JSON types (BigQuery JSON, Snowflake VARIANT, Redshift SUPER, PostgreSQL JSON/JSONB):
    - Uses direct JSON unnesting functions for optimal performance
- For string types containing JSON-like data:
    - Cleans and parses the string to native JSON format first, then unnests
- Returns a CTE with columns: source_relation, _fivetran_id, creative_id, key, value, type

Database-specific implementations:
- BigQuery: json_extract_array() + unnest()
- PostgreSQL: json_array_elements() + cross join lateral
- Redshift: json_parse() + cross join with array elements
- Snowflake: parse_json() + lateral flatten()
- Spark: from_json() + explode() (assumes string input only) #}

{%- macro get_url_tags_query(output_cte_name, url_tags_datatype) %}
    {{ return(adapter.dispatch('get_url_tags_query', 'facebook_ads') (output_cte_name, url_tags_datatype)) }}
{%- endmacro %}

{%- macro default__get_url_tags_query(output_cte_name, url_tags_datatype) %}

    {{ output_cte_name }} as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            cast(null as {{ dbt.type_string() }}) as key,
            cast(null as {{ dbt.type_string() }}) as value,
            cast(null as {{ dbt.type_string() }}) as type
        from unnested
    )
{%- endmacro %}

{%- macro bigquery__get_url_tags_query(output_cte_name, url_tags_datatype) %}

    {%- set is_native_json = url_tags_datatype == 'json' %}

    unnested as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tag_element
        from required_fields,

    {%- if is_native_json %}
        unnest(json_extract_array(url_tags)) as url_tag_element
    {%- else %}
        unnest(json_extract_array(replace(trim(url_tags, '"'),'\\',''))) as url_tag_element
    {%- endif %}

        where url_tags is not null
    ),

    {{ output_cte_name }} as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            json_extract_scalar(url_tag_element, '$.key') as key,
            json_extract_scalar(url_tag_element, '$.value') as value,
            json_extract_scalar(url_tag_element, '$.type') as type
        from unnested
    )
{%- endmacro %}

{%- macro postgres__get_url_tags_query(output_cte_name, url_tags_datatype) %}

    {%- set is_native_json = url_tags_datatype in ('json', 'jsonb') %}

    unnested as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tag_element
        from required_fields

    {%- if is_native_json %}
        cross join lateral {{ url_tags_datatype }}_array_elements(url_tags) as url_tag_element -- use json_array_elements or jsonb_array_elements based on datatype
    {%- else %}
        cross join lateral json_array_elements(replace(trim(url_tags::text, '"'),'\\','')::json) as url_tag_element
    {%- endif %}

        where url_tags is not null
    ),

    {{ output_cte_name }} as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tag_element->>'key' as key,
            url_tag_element->>'value' as value,
            url_tag_element->>'type' as type
        from unnested
    )
{%- endmacro %}

{%- macro redshift__get_url_tags_query(output_cte_name, url_tags_datatype) %}

    {%- set is_native_json = url_tags_datatype == 'super' %}

    url_tags as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            {{ 'url_tags' if is_native_json else 'json_parse(url_tags)' }} as parsed_url_tags
        from required_fields
        where url_tags is not null
    ),

    {{ output_cte_name }} as (
        select
            ut.source_relation,
            ut._fivetran_id,
            ut.creative_id,
            element.key::varchar as key,
            element.value::varchar as value,
            element.type::varchar as type
        from url_tags as ut
        cross join ut.parsed_url_tags as element
    )
{%- endmacro %}

{%- macro snowflake__get_url_tags_query(output_cte_name, url_tags_datatype) %}

    {%- set is_native_json = url_tags_datatype in ('variant', 'object', 'array') %}

    {{ output_cte_name }} as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tags.value:key::string as key,
            url_tags.value:value::string as value,
            url_tags.value:type::string as type
        from required_fields,
        lateral flatten(input => {{ 'url_tags' if is_native_json else 'parse_json(url_tags)' }}) as url_tags
        where url_tags is not null
    )
{%- endmacro %}

{%- macro spark__get_url_tags_query(output_cte_name, url_tags_datatype) %}
    {# JSON datatype not supported by Fivetran so no need to check datatype. #}

    cleaned_fields as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            explode(from_json(url_tags, 'array<struct<key:STRING, value:STRING, type:STRING>>')) as url_tags
        from required_fields
        where url_tags is not null
    ),

    {{ output_cte_name }} as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tags.key as key,
            url_tags.value as value,
            url_tags.type as type
        from cleaned_fields
    )
{%- endmacro %}
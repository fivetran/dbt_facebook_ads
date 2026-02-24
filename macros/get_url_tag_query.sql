{%- macro get_url_tags_query() %}
    {{ return(adapter.dispatch('get_url_tags_query', 'facebook_ads') ()) }}
{%- endmacro %}

{%- macro bigquery__get_url_tags_query() %}

    {%- set is_native_json = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') == 'json' %}

    unnested as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tag_element
        from required_fields,

    {%- if is_native_json %}
        unnest(url_tags) as url_tag_element
    {%- else %}
        unnest(json_extract_array(replace(trim(url_tags, '"'),'\\',''))) as url_tag_element
    {%- endif %}

        where url_tags is not null
    ),

    fields as (
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

{%- macro postgres__get_url_tags_query() %}

    {%- set is_native_json = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') in ('json', 'jsonb') %}

    unnested as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            url_tag_element
        from required_fields

    {%- if is_native_json %}
        left join lateral json_array_elements(url_tags) as url_tag_element on True
    {%- else %}
        left join lateral json_array_elements(replace(trim(url_tags::text, '"'),'\\','')::json) as url_tag_element on True
    {%- endif %}

        where url_tags is not null
    ),

    fields as (
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

{%- macro redshift__get_url_tags_query() %}

    {%- set is_native_json = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') == 'super' %}

    numbers as (
        {{ dbt_utils.generate_series(upper_bound=1000) }}
    ),

    flattened_url_tags as (
        select
            source_relation,
            _fivetran_id,
            creative_id,

        {%- if is_native_json %}
                required_fields.url_tags[numbers.generated_number::int - 1] as element
        {%- else %}
                json_extract_array_element_text(required_fields.url_tags, numbers.generated_number::int - 1, true) as element
        {%- endif %}
            from required_fields
            inner join numbers
                on json_array_length(required_fields.url_tags) >= numbers.generated_number
    ),

    fields as (
        select
            source_relation,
            _fivetran_id,
            creative_id,

        {%- if is_native_json %}
            element.key::varchar as key,
            element.value::varchar as value,
            element.type::varchar as type
        {%- else %}
            json_extract_path_text(element,'key') as key,
            json_extract_path_text(element,'value') as value,
            json_extract_path_text(element,'type') as type
        {%- endif %}

        from flattened_url_tags
    )
{%- endmacro %}

{%- macro snowflake__get_url_tags_query() %}

    {%- set is_native_json = 
        get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') in ('variant', 'object', 'array') %}

    fields as (
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

{%- macro spark__get_url_tags_query() %}
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

    fields as (
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
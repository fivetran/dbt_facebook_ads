{%- macro get_url_tags_query() %}
    {{ return(adapter.dispatch('get_url_tags_query', 'facebook_ads') ()) }}
{%- endmacro %}

{%- macro default__get_url_tags_query() %}

    fields as (
        select
            source_relation,
            _fivetran_id,
            creative_id,
            cast(null as {{ dbt.type_string() }}) as key,
            cast(null as {{ dbt.type_string() }}) as value,
            cast(null as {{ dbt.type_string() }}) as type
        from required_fields
    )

{%- endmacro %}

{%- macro bigquery__get_url_tags_query() %}

    {%- set url_tags_datatype = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') %}
    {%- if url_tags_datatype == 'json' %}

        unnested as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                json_value
            from required_fields,
            unnest(json_extract_array(url_tags)) as json_value
            where url_tags is not null
        ),

        fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                json_extract_scalar(json_value, '$.key') as key,
                json_extract_scalar(json_value, '$.value') as value,
                json_extract_scalar(json_value, '$.type') as type
            from unnested
        )

    {%- else %}

        cleaned_json as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                json_extract_array(replace(trim(url_tags, '"'),'\\','')) as cleaned_url_tags
            from required_fields
        ), 

        unnested as (
            select 
                source_relation,
                _fivetran_id, 
                creative_id, 
                url_tag_element
            from cleaned_json
            left join unnest(cleaned_url_tags) as url_tag_element
            where cleaned_url_tags is not null
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
    {%- endif%}
    {%- endmacro %}


    {%- macro postgres__get_url_tags_query() %}

    {%- set url_tags_datatype = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') %}
    {%- if url_tags_datatype in ('json', 'jsonb') %}

        unnested as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                url_tag_element
            from required_fields
            left join lateral json_array_elements(url_tags) as url_tag_element on True
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

    {%- else %}

        cleaned_json as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                replace(trim(url_tags::text, '"'),'\\','')::json as cleaned_url_tags
            from required_fields
        ),

        unnested as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                url_tag_element
            from cleaned_json
            left join lateral json_array_elements(cleaned_url_tags) as url_tag_element on True
            where cleaned_url_tags is not null
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
    {%- endif %}
    {%- endmacro %}


    {%- macro redshift__get_url_tags_query() %}

    {%- set url_tags_datatype = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') %}
    {%- if url_tags_datatype in ('json', 'super') %}

        numbers as (
            {{ dbt_utils.generate_series(upper_bound=1000) }}
        ),

        flattened_url_tags as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                url_tags[numbers.generated_number::int - 1] as element
            from required_fields
            inner join numbers
                on json_array_length(url_tags) >= numbers.generated_number
        ),

        fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                element.key::varchar as key,
                element.value::varchar as value,
                element.type::varchar as type
            from flattened_url_tags
        )

    {%- else %}

        numbers as (
            {{ dbt_utils.generate_series(upper_bound=1000) }}
        ),

        flattened_url_tags as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                json_extract_array_element_text(required_fields.url_tags, numbers.generated_number::int - 1, true) as element
            from required_fields
            inner join numbers
                on json_array_length(required_fields.url_tags) >= numbers.generated_number
        ),

        fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                json_extract_path_text(element,'key') as key,
                json_extract_path_text(element,'value') as value,
                json_extract_path_text(element,'type') as type
            from flattened_url_tags
        )
    {%- endif %}
    {%- endmacro %}


    {%- macro snowflake__get_url_tags_query() %}

    {%- set url_tags_datatype = get_column_datatype('stg_facebook_ads__creative_history', 'url_tags') %}
    {%- if url_tags_datatype in ('variant', 'object', 'array') %}

        fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                url_tags.value:key::string as key,
                url_tags.value:value::string as value,
                url_tags.value:type::string as type
            from required_fields,
            lateral flatten( input => url_tags ) as url_tags
            where url_tags is not null
        )

    {%- else %}

        cleaned_fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                parse_json(url_tags) as url_tags
            from required_fields
            where url_tags is not null
        ),

        fields as (
            select
                source_relation,
                _fivetran_id,
                creative_id,
                url_tags.value:key::string as key,
                url_tags.value:value::string as value,
                url_tags.value:type::string as type
            from cleaned_fields,
            lateral flatten( input => url_tags ) as url_tags
        )
    {%- endif %}
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
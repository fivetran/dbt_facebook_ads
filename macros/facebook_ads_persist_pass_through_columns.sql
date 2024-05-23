{# Adapted from fivetran_utils.persist_pass_through_columns() macro to include coalesces #}

{% macro facebook_ads_persist_pass_through_columns(pass_through_variable, identifier=none, transform='', coalesce_with=none) %}

{% if var(pass_through_variable, none) %}
    {% for field in var(pass_through_variable) %}
        , {{ transform ~ '(' ~ ('coalesce(' if coalesce_with is not none else '') ~ (identifier ~ '.' if identifier else '') ~ (field.alias if field.alias else field.name) ~ ((', ' ~ coalesce_with ~ ')') if coalesce_with is not none else '') ~ ')' }} as {{ field.alias if field.alias else field.name }}
    {% endfor %}
{% endif %}

{% endmacro %}
{% macro facebook_action_slug(action_type) -%}
    {%- set raw_label = action_type.name if action_type.name else action_type.pattern -%}
    {# replace dots and other separators with underscores before slugifying #}
    {%- set cleaned = raw_label | replace('.', '_') -%}

    {{- dbt_utils.slugify(cleaned) -}}
{%- endmacro %}
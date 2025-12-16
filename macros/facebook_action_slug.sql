{% macro facebook_action_slug(action_type) -%}
    {%- set label = action_type.name if action_type.name else action_type.pattern -%}
    {{- dbt_utils.slugify(label) -}}
{%- endmacro %}
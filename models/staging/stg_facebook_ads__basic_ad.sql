{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with base as (

    select * 
    from {{ ref('stg_facebook_ads__basic_ad_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_facebook_ads__basic_ad_tmp')),
                staging_columns=get_basic_ad_columns()
            )
        }}
        
    
        {{ fivetran_utils.source_relation(
            union_schema_variable='facebook_ads_union_schemas', 
            union_database_variable='facebook_ads_union_databases') 
        }}

    from base
),

final as (

    select
        source_relation, 
        cast(ad_id as {{ dbt.type_bigint() }}) as ad_id,
        ad_name,
        adset_name as ad_set_name,
        date as date_day,
        cast(account_id as {{ dbt.type_bigint() }}) as account_id,
        impressions,
        coalesce(inline_link_clicks,0) as clicks,
        spend

        {# 
            Reach and Frequency are not included in downstream models by default, though they are included in the staging model.
            The below ensures that users can add Reach and Frequency to downstream models with the `facebook_ads__basic_ad_passthrough_metrics` variable
            while avoiding duplicate column errors.
        #}
        {%- set check = [] %}
        {%- for field in var('facebook_ads__basic_ad_passthrough_metrics') -%}
            {%- set field_name = field.alias|default(field.name)|lower %}
            {% if field_name in ['reach', 'frequency'] %}
                {% do check.append(field_name) %}
            {% endif %}
        {%- endfor %}

        {%- for metric in ['reach', 'frequency'] -%}
            {% if metric not in check %}
                , {{ metric }}
            {% endif %}
        {%- endfor %}

        {{ fivetran_utils.fill_pass_through_columns('facebook_ads__basic_ad_passthrough_metrics') }}
    from fields
)

select * 
from final

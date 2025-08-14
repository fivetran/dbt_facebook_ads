{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True) and var('facebook_ads__using_demographics_region', False)) }}


{{
    fivetran_utils.union_data(
        table_identifier='demographics_region_actions', 
        database_variable='facebook_ads_database', 
        schema_variable='facebook_ads_schema', 
        default_database=target.database,
        default_schema='facebook_ads',
        default_variable='demographics_region_actions',
        union_schema_variable='facebook_ads_union_schemas',
        union_database_variable='facebook_ads_union_databases'
    )
}}

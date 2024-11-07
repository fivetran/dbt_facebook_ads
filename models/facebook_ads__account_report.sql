{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with report as (

    select *
    from {{ var('basic_ad') }}

), 

conversion_report as (

    select *
    from {{ ref('int_facebook_ads__conversions') }}

), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = true

),

joined as (

    select 
        report.source_relation,
        report.date_day,
        accounts.account_id,
        accounts.account_name,
        accounts.account_status,
        accounts.business_country_code,
        accounts.created_at,
        accounts.currency,
        accounts.timezone_name,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.spend) as spend,
        sum(coalesce(conversion_report.conversions, 0)) as conversions,
        sum(coalesce(conversion_report.conversions_value, 0)) as conversions_value

        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_passthrough_metrics', transform = 'sum', exclude_fields=['conversions', 'conversions_value']) }}
        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_actions_passthrough_metrics', transform = 'sum', coalesce_with=0) }}
        {{ facebook_ads_persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_action_values_passthrough_metrics', transform = 'sum', coalesce_with=0) }}

    from report 
    left join conversion_report
        on report.date_day = conversion_report.date_day
        and report.ad_id = conversion_report.ad_id
    left join accounts
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(9) }}
)

select *
from joined
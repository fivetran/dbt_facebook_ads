{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with report as (

    select *
    from {{ var('basic_ad') }}

), 

creatives as (

    select *
    from {{ ref('int_facebook_ads__creative_history') }}

), 

accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = true

), 

ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = true

), 

ad_sets as (

    select *
    from {{ var('ad_set_history') }}
    where is_most_recent_record = true

), 

campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = true

), 

joined as (

    select
        report.date_day,
        accounts.account_id,
        accounts.account_name,
        campaigns.campaign_id,
        campaigns.campaign_name,
        ad_sets.ad_set_id,
        ad_sets.ad_set_name,
        ads.ad_id,
        ads.ad_name,
        creatives.creative_id,
        creatives.creative_name,
        creatives.base_url,
        creatives.url_host,
        creatives.url_path,
        creatives.utm_source,
        creatives.utm_medium,
        creatives.utm_campaign,
        creatives.utm_content,
        creatives.utm_term,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.spend) as spend

        {{ fivetran_utils.persist_pass_through_columns(pass_through_variable='facebook_ads__basic_ad_passthrough_metrics', transform = 'sum') }}
    from report
    left join ads 
        on report.ad_id = ads.ad_id
    left join creatives
        on ads.creative_id = creatives.creative_id
    left join ad_sets
        on ads.ad_set_id = ad_sets.ad_set_id
    left join campaigns
        on ads.campaign_id = campaigns.campaign_id
    left join accounts
        on report.account_id = accounts.account_id    
    where creatives.url is not null
    {{ dbt_utils.group_by(19) }}
)

select *
from joined
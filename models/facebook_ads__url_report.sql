{{ config(enabled=var('ad_reporting__facebook_ads_enabled', True)) }}

with report as (

    select *
    from {{ var('basic_ad') }}

), 

conversion_report as (

    select *
    from {{ ref('int_facebook_ads__conversions') }}

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
        report.source_relation,
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
        , sum(coalesce(conversion_report.conversion_value, 0)) as conversion_value

        {# Adapted from fivetran_utils.persist_pass_through_columns() macro to include coalesces, since the conversion_report is on the right side of a left join #}
        {% if var('facebook_ads__basic_ad_actions_passthrough_metrics', none) %}
            {% for field in var('facebook_ads__basic_ad_actions_passthrough_metrics') %}
                , sum( coalesce({{ field.alias if field.alias else field.name }}, 0)) as {{ field.alias if field.alias else field.name }}
            {% endfor %}
        {% endif %}

    from report
    left join conversion_report
        on report.date_day = conversion_report.date_day
        and report.ad_id = conversion_report.ad_id
    left join ads 
        on report.ad_id = ads.ad_id
        and report.source_relation = ads.source_relation
    left join creatives
        on ads.creative_id = creatives.creative_id
        and ads.source_relation = creatives.source_relation
    left join ad_sets
        on ads.ad_set_id = ad_sets.ad_set_id
        and ads.source_relation = ad_sets.source_relation
    left join campaigns
        on ads.campaign_id = campaigns.campaign_id
        and ads.source_relation = campaigns.source_relation
    left join accounts
        on report.account_id = accounts.account_id
        and report.source_relation = accounts.source_relation  

    {% if var('ad_reporting__url_report__using_null_filter', True) %}
        where creatives.url is not null
    {% endif %}
    
    {{ dbt_utils.group_by(20) }}
)

select *
from joined
with report as (

    select *
    from {{ var('basic_ad') }}

), creatives as (

    select *
    from {{ ref('facebook_ads__creative_history_prep') }}

), accounts as (

    select *
    from {{ var('account_history') }}
    where is_most_recent_record = true

), ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = true

), ad_sets as (

    select *
    from {{ var('ad_set_history') }}
    where is_most_recent_record = true

), campaigns as (

    select *
    from {{ var('campaign_history') }}
    where is_most_recent_record = true

), joined as (

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
        report.source_relation,
        sum(report.clicks) as clicks,
        sum(report.impressions) as impressions,
        sum(report.spend) as spend
    from report
    left join ads 
        on cast(report.ad_id as {{ dbt_utils.type_bigint() }}) = cast(ads.ad_id as {{ dbt_utils.type_bigint() }})
        and report.source_relation = ads.source_relation
    left join creatives
        on cast(ads.creative_id as {{ dbt_utils.type_bigint() }}) = cast(creatives.creative_id as {{ dbt_utils.type_bigint() }})
        and ads.source_relation = creatives.source_relation
    left join ad_sets
        on cast(ads.ad_set_id as {{ dbt_utils.type_bigint() }}) = cast(ad_sets.ad_set_id as {{ dbt_utils.type_bigint() }})
        and ads.source_relation = ad_sets.source_relation
    left join campaigns
        on cast(ads.campaign_id as {{ dbt_utils.type_bigint() }}) = cast(campaigns.campaign_id as {{ dbt_utils.type_bigint() }})
        and ads.source_relation = campaigns.source_relation
    left join accounts
        on cast(report.account_id as {{ dbt_utils.type_bigint() }}) = cast(accounts.account_id as {{ dbt_utils.type_bigint() }})
        and report.source_relation = accounts.source_relation
    {{ dbt_utils.group_by(20) }}

)

select *
from joined
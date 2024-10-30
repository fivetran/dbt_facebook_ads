{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        ad_id,
        sum(coalesce(clicks, 0)) as clicks, 
        sum(coalesce(impressions, 0)) as impressions,
        sum(coalesce(spend, 0)) as spend
    from {{ target.schema }}_facebook_ads_prod.facebook_ads__url_report
    group by 1
),

dev as (
    select
        ad_id,
        sum(coalesce(clicks, 0)) as clicks, 
        sum(coalesce(impressions, 0)) as impressions,
        sum(coalesce(spend, 0)) as spend
    from {{ target.schema }}_facebook_ads_dev.facebook_ads__url_report
    group by 1
),

final as (
    select 
        prod.ad_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.spend as prod_spend,
        dev.spend as dev_spend
    from prod
    full outer join dev 
        on dev.ad_id = prod.ad_id
)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_spend - dev_spend) >= .01
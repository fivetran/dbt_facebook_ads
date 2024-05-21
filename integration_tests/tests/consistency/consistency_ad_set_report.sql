{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with prod as (
    select
        ad_set_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend
    from {{ target.schema }}_facebook_ads_prod.facebook_ads__ad_set_report
    group by 1
),

dev as (
    select
        ad_set_id,
        sum(clicks) as clicks, 
        sum(impressions) as impressions,
        sum(spend) as spend
    from {{ target.schema }}_facebook_ads_dev.facebook_ads__ad_set_report
    group by 1
),

final as (
    select 
        prod.ad_set_id,
        prod.clicks as prod_clicks,
        dev.clicks as dev_clicks,
        prod.impressions as prod_impressions,
        dev.impressions as dev_impressions,
        prod.spend as prod_spend,
        dev.spend as dev_spend
    from prod
    full outer join dev 
        on dev.ad_set_id = prod.ad_set_id
)

select *
from final
where
    abs(prod_clicks - dev_clicks) >= .01
    or abs(prod_impressions - dev_impressions) >= .01
    or abs(prod_spend - dev_spend) >= .01
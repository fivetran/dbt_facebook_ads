{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with ad_report as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__ad_report') }}
),

account_report as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__account_report') }}
),

ad_set_report as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__ad_set_report') }}
),

campaign_report as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__campaign_report') }}
),

url_report as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__url_report') }}
),

ad_w_url_report as (

    select 
        sum(coalesce(urls.conversions_value, 0)) as conversions_value,
        sum(coalesce(urls.conversions, 0)) as conversions
    from {{ ref('facebook_ads__ad_report') }} ads
    join {{ ref('facebook_ads__url_report') }} urls
        on ads.ad_id = urls.ad_id
        and ads.date_day = urls.date_day
)

select 
    'ad vs account' as comparison
from ad_report 
join account_report on true
where ad_report.conversions_value != account_report.conversions_value
or ad_report.conversions != account_report.conversions

union all 

select 
    'ad vs ad set' as comparison
from ad_report 
join ad_set_report on true
where ad_report.conversions_value != ad_set_report.conversions_value
or ad_report.conversions != ad_set_report.conversions
union all 

select 
    'ad vs campaign' as comparison
from ad_report 
join campaign_report on true
where ad_report.conversions_value != campaign_report.conversions_value
or ad_report.conversions != campaign_report.conversions
union all 

select 
    'ad vs url' as comparison
from ad_w_url_report 
join url_report on true
where ad_w_url_report.conversions_value != url_report.conversions_value
or ad_w_url_report.conversions != url_report.conversions
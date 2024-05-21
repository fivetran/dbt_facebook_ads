{{ config(
    tags="fivetran_validations",
    enabled=var('fivetran_validation_tests_enabled', false)
) }}

with ad_report as (

    select 
        sum(conversion_value) as total_value
    from {{ ref('facebook_ads__ad_report') }}
),

account_report as (

    select 
        sum(conversion_value) as total_value
    from {{ ref('facebook_ads__account_report') }}
),

ad_set_report as (

    select 
        sum(conversion_value) as total_value
    from {{ ref('facebook_ads__ad_set_report') }}
),

campaign_report as (

    select 
        sum(conversion_value) as total_value
    from {{ ref('facebook_ads__campaign_report') }}
),

url_report as (

    select 
        sum(conversion_value) as total_value
    from {{ ref('facebook_ads__url_report') }}
),

ad_w_url_report as (

    select 
        sum(ads.conversion_value) as total_value
    from {{ ref('facebook_ads__ad_report') }} ads
    join {{ ref('facebook_ads__url_report') }} urls
        on ads.ad_id = urls.ad_id
        and ads.date_day = urls.date_day
)

select 
    'ad vs account' as comparison
from ad_report 
join account_report on true
where ad_report.total_value != account_report.total_value

union all 

select 
    'ad vs ad set' as comparison
from ad_report 
join ad_set_report on true
where ad_report.total_value != ad_set_report.total_value

union all 

select 
    'ad vs campaign' as comparison
from ad_report 
join campaign_report on true
where ad_report.total_value != campaign_report.total_value

union all 

select 
    'ad vs url' as comparison
from ad_w_url_report 
join url_report on true
where ad_w_url_report.total_value != url_report.total_value
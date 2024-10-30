with ad_source as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ source('facebook_ads', 'basic_ad_actions') }}
),

ad_model as (

    select 
        sum(coalesce(conversions_value, 0)) as conversions_value,
        sum(coalesce(conversions, 0)) as conversions
    from {{ ref('facebook_ads__ad_report') }}
)


select 
    ad_source.*
from ad_model 
join ad_source on true
where ad_model.conversions_value != ad_source.conversions_value
    or ad_model.conversions != ad_source.conversions
with ad_source as (

    select 
        sum(coalesce(conversion_value, 0)) as total_value,
        sum(coalesce(conversions, 0)) as conversions,
        sum(coalesce(view_through_conversions, 0)) as view_through_conversions
    from {{ source('facebook_ads', 'basic_ad_actions') }}
),

ad_model as (

    select 
        sum(coalesce(conversion_value, 0)) as total_value,
        sum(coalesce(conversions, 0)) as conversions,
        sum(coalesce(view_through_conversions, 0)) as view_through_conversions
    from {{ ref('facebook_ads__ad_report') }}
)


select 
    ad_source.*
from ad_model 
join ad_source on true
where ad_model.total_value != ad_source.total_value
    or ad_model.total_conversions != ad_source.total_conversions
    or ad_model.view_through_conversions != ad_source.view_through_conversions
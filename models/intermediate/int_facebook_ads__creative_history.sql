with creatives as (

    select *
    from {{ var('creative_history') }}
    where is_most_recent_valid_utm_record = true
), 

ads as (

    select *
    from {{ var('ad_history') }}
    where is_most_recent_record = true
),

joined as (

    select
        creatives._fivetran_id,
        creatives.account_id,
        ads.ad_id,
        creatives.creative_id,
        creatives.creative_name,
        creatives.page_link,
        creatives.template_page_link,
        creatives.url_tags,
        row_number() over (partition by ads.ad_id order by ads.creative_id) = 1 as first_creative_record
    from ads
    join creatives
        on ads.creative_id = creatives.creative_id
)

select *
from joined

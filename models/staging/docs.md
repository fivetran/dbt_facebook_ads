{% docs _fivetran_synced -%}
When the record was last synced by Fivetran.
{%- enddocs %}

{% docs is_most_recent_record %}
Boolean representing whether a record is the most recent version of that record. All records should have this value set to True given we filter on it.
{% enddocs %}

{% docs updated_time %}
The timestamp of the last update of a record.
{% enddocs %}

{% docs source_relation %}
The source of the record if the unioning functionality is being used. If not this field will be empty.
{% enddocs %}

{% docs demographics_country %} Ads report segmented by country. {% enddocs %}

{% docs country_id %} Fivetran-generated unique ID of the country. {% enddocs %}

{% docs region_id %} Fivetran-generated unique ID of the geographic region. {% enddocs %}

{% docs account_id %} The ID of the ad account that this ad belongs to. {% enddocs %}

{% docs cost_per_inline_link_click %} The average cost of each inline link click. Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics). {% enddocs %}

{% docs country %} Country whose ad performance is being reported on. {% enddocs %}

{% docs cpc %} The average cost for each click (all). Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics). {% enddocs %}

{% docs cpm %} The average cost for 1,000 impressions. Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics). {% enddocs %}

{% docs ctr %} The percentage of times people saw your ad and performed a click (all). Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics). {% enddocs %}

{% docs date %} The date of the reported performance. {% enddocs %}

{% docs frequency %} The average number of times each person saw your ads; it is calculated as impressions divided by reach.{% enddocs %}

{% docs impressions %} The number of impressions the ads had on the given day. {% enddocs %}

{% docs inline_link_click_ctr %} The percentage of time people saw your ads and performed an inline link click. Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics). {% enddocs %}

{% docs inline_link_clicks %}
The number of clicks on links to select destinations or experiences, on or off Facebook-owned properties. Inline link clicks use a fixed 1-day-click attribution window.
{% enddocs %}

{% docs reach %} The number of people who saw any content from your Page or about your Page. This metric is estimated. {% enddocs %}

{% docs spend %} Ad spend in a given day for the breakdown. {% enddocs %}

{% docs demographics_country_actions %}
Each record represents daily conversion performance by country. This is the prebuilt `demographics_country` report broken down by `action_type`.
{% enddocs %}

{% docs _1_d_view %}
Conversion metric value using an attribution window of "1 day after viewing the ad". Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics).
{% enddocs %}

{% docs _7_d_click %}
Conversion metric value using an attribution window of "7 days after clicking the ad". Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics).
{% enddocs %}

{% docs index %}
Index reflecting the `action_type` tracked for this ad on this day. Column of not much consequence.
{% enddocs %}

{% docs action_type %}
The kind of actions taken on your ad, Page, app or event after your ad was served to someone, even if they didn't click on it. Action types include Page likes, app installs, conversions, event responses and more.
Actions prepended by `app_custom_event` come from mobile app events and actions prepended by `offsite_conversion` come from the Facebook Pixel.
{% enddocs %}

{% docs conversions %}
Conversion metric value using the default attribution window.
{% enddocs %}

{% docs inline %}
Conversion metric value using the attribution window that occurs on the ad itself. Not included in downstream models by default. To persist this field, refer to the [README](https://github.com/fivetran/dbt_facebook_ads_source?tab=readme-ov-file#passing-through-additional-metrics).
{% enddocs %}

{% docs region %}
Geographic region whose ad performance is being reported on.
{% enddocs %}

{% docs demographics_region %}
Ads report segmented by geographic region.
{% enddocs %}

{% docs demographics_region_actions %}
Each record represents daily conversion performance by geographic region. This is the prebuilt `demographics_region` report broken down by `action_type`.
{% enddocs %}
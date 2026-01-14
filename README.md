<!--section="facebook-ads_transformation_model"-->
# Facebook Ads dbt Package

<p align="left">
    <a alt="License"
        href="https://github.com/fivetran/dbt_facebook_ads/blob/main/LICENSE">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" /></a>
    <a alt="dbt-core">
        <img src="https://img.shields.io/badge/dbt_Core™_version->=1.3.0,_<3.0.0-orange.svg" /></a>
    <a alt="Maintained?">
        <img src="https://img.shields.io/badge/Maintained%3F-yes-green.svg" /></a>
    <a alt="PRs">
        <img src="https://img.shields.io/badge/Contributions-welcome-blueviolet" /></a>
    <a alt="Fivetran Quickstart Compatible"
        href="https://fivetran.com/docs/transformations/data-models/quickstart-management#quickstartmanagement">
        <img src="https://img.shields.io/badge/Fivetran_Quickstart_Compatible%3F-yes-green.svg" /></a>
</p>

This dbt package transforms data from Fivetran's Facebook Ads connector into analytics-ready tables.

## Resources

- Number of materialized models¹: 34
- Connector documentation
  - [Facebook Ads connector documentation](https://fivetran.com/docs/connectors/applications/facebook-ads)
  - [Facebook Ads ERD](https://fivetran.com/docs/connectors/applications/facebook-ads#schemainformation)
- dbt package documentation
  - [GitHub repository](https://github.com/fivetran/dbt_facebook_ads)
  - [dbt Docs](https://fivetran.github.io/dbt_facebook_ads/#!/overview)
  - [DAG](https://fivetran.github.io/dbt_facebook_ads/#!/overview?g_v=1)
  - [Changelog](https://github.com/fivetran/dbt_facebook_ads/blob/main/CHANGELOG.md)

## What does this dbt package do?
This package enables you to better understand the performance of your ads across varying grains and produces modeled tables that leverage Facebook Ads data. It creates enriched models with metrics focused on account, campaign, ad set, ad, and geographic reporting.

> **Note**: If you do not have your Facebook Ads connection [schema change settings](https://fivetran.com/docs/using-fivetran/features/data-blocking-column-hashing/config#configureschemachangesettingsforexistingconnectors) set to `Allow all`, it is very possible that you are missing `basic_ad_actions` or `basic_ad_action_values`. If you would like to surface conversion metrics in your Facebook and/or Ad Reporting models, please ensure these reports are syncing. Otherwise, the `conversions` and `conversions_value` fields will be `null`.

### Output schema
Final output tables are generated in the following target schema:

```
<your_database>.<connector/schema_name>_facebook_ads
```

### Final output tables

By default, this package materializes the following final tables:

| Table | Description |
| :---- | :---- |
| [`facebook_ads__account_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__account_report) | Represents daily performance aggregated at the account level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>How does performance compare across different accounts by account manager?</li><li>Are currency fluctuations affecting results across markets?</li></ul> |
| [`facebook_ads__campaign_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__campaign_report) | Represents daily performance aggregated at the campaign level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which campaigns are most efficient in terms of cost per conversion?</li><li>Are paused or limited-status campaigns still accruing impressions?</li><li>Which campaigns contribute most to overall spend or conversions?</li></ul> |
| [`facebook_ads__ad_set_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__ad_set_report) | Represents daily performance aggregated at the ad set level (equivalent to ad groups in other platforms), including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which ad sets have the strongest engagement relative to their budget?</li><li>Do certain ad sets dominate impressions within a campaign?</li><li>Are new ad sets ramping up as expected after launch?</li></ul> |
| [`facebook_ads__ad_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__ad_report) | Represents daily performance at the individual ad level, including `spend`, `clicks`, `impressions`, and `conversions`.<br><br>**Example Analytics Questions:**<ul><li>Which ad creatives are driving the lowest cost per click?</li><li>Do expanded text ads perform better than responsive search ads?</li><li>How do performance trends change after refreshing ad copy?</li></ul> |
| [`facebook_ads__country_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__country_report) | Represents daily performance aggregated at the account level by country, including `spend`, `clicks`, `impressions`, and `conversions`, enriched with geographic context.<br><br>**Example Analytics Questions:**<ul><li>Which countries are delivering the highest return on ad spend for each account?</li><li>Are there seasonal performance variations by geographic region?</li></ul> |
| [`facebook_ads__region_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__region_report) | Represents daily performance aggregated at the account level by region, including `spend`, `clicks`, `impressions`, and `conversions`, enriched with geographic context.<br><br>**Example Analytics Questions:**<ul><li>Which regions are driving the most efficient account performance?</li><li>How do regional performance trends correlate with local market conditions?</li></ul> |
| [`facebook_ads__url_report`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__url_report) | Represents daily performance at the individual URL level, including `spend`, `clicks`, `impressions`, and `conversions`, enriched with ad context. By default, excludes ads with NULL `url` values.<br><br>**Example Analytics Questions:**<ul><li>Which landing pages are driving the highest conversion rates?</li><li>Are certain URLs performing better with specific ad creative combinations?</li></ul> |
| [`facebook_ads__url_tags`](https://fivetran.github.io/dbt_facebook_ads/#!/model/model.facebook_ads.facebook_ads__url_tags) | Represents unique combinations of creative_id and corresponding URL tag key-value pairs, providing UTM and custom parameter tracking. Excludes creatives without URL tags.<br><br>**Example Analytics Questions:**<ul><li>Which UTM campaigns are driving the most traffic across different creatives?</li><li>How do custom URL parameters correlate with conversion performance?</li></ul> |

¹ Each Quickstart transformation job run materializes these models if all components of this data model are enabled. This count includes all staging, intermediate, and final models materialized as `view`, `table`, or `incremental`.

---

## Visualizations
Many of the above reports are now configurable for [visualization via Streamlit](https://github.com/fivetran/streamlit_facebook-ads). Check out some [sample reports here](https://fivetran-facebook-ads.streamlit.app/).

<p align="center">
  <a href="https://fivetran-ad-reporting.streamlit.app/ad_performance">
    <img src="https://raw.githubusercontent.com/fivetran/dbt_facebook_ads/main/images/streamlit_example.png" alt="Fivetran Ad Reporting Streamlit App" width="100%">
  </a>
</p>

## Prerequisites
To use this dbt package, you must have the following:

- At least one Fivetran Facebook Ads connection syncing data into your destination.
- A **BigQuery**, **Snowflake**, **Redshift**, **PostgreSQL**, or **Databricks** destination.
- You will need to configure your Facebook Ads connection to pull the `basic_ad` pre-built report and its child `basic_ad_actions` and `basic_ad_action_values` pre-built reports. These pre-built reports should be enabled in your connection by default. However, to confirm these reports are actively syncing you may perform the following steps:
    1. Navigate to the connection schema tab in Fivetran.
    2. Search for `basic_ad`, `basic_ad_actions`, and `basic_ad_action_values` and confirm they are all selected/enabled. If you would like country and region-level transformations, do the same for `demographics_country`, `demographics_country_actions`, `demographics_region`, and `demographics_region_actions`.
    3. If not selected, do so and sync. If already selected you are ready to run the models!

## How do I use the dbt package?
You can either add this dbt package in the Fivetran dashboard or import it into your dbt project:

- To add the package in the Fivetran dashboard, follow our [Quickstart guide](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore).
- To add the package to your dbt project, follow the setup instructions in the dbt package's [README file](https://github.com/fivetran/dbt_facebook_ads/blob/main/README.md#how-do-i-use-the-dbt-package) to use this package.

<!--section-end-->

### Install the package (skip if also using the `ad_reporting` combo package)
Include the following facebook_ads package version in your `packages.yml` file:
> TIP: Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.
```yml
packages:
  - package: fivetran/facebook_ads
    version: [">=1.4.0", "<1.5.0"] # we recommend using ranges to capture non-breaking changes automatically
```

> All required sources and staging models are now bundled into this transformation package. Do not include `fivetran/facebook_ads_source` in your `packages.yml` since this package has been deprecated.

#### Databricks Dispatch Configuration
If you are using a Databricks destination with this package you will need to add the below (or a variation of the below) dispatch configuration within your `dbt_project.yml`. This is required in order for the package to accurately search for macros within the `dbt-labs/spark_utils` then the `dbt-labs/dbt_utils` packages respectively.
```yml
dispatch:
  - macro_namespace: dbt_utils
    search_order: ['spark_utils', 'dbt_utils']
```

### Define database and schema variables
By default, this package runs using your destination and the `facebook_ads` schema. If this is not where your Facebook Ads data is (for example, if your Facebook Ads schema is named `facebook_ads_fivetran`), add the following configuration to your root `dbt_project.yml` file:

```yml
vars:
    facebook_ads_database: your_destination_name
    facebook_ads_schema: your_schema_name 
```

### (Optional) Additional configurations
<details open><summary>Expand/Collapse details</summary>

#### Union multiple connections
If you have multiple facebook_ads connections in Fivetran and would like to use this package on all of them simultaneously, we have provided functionality to do so. The package will union all of the data together and pass the unioned table into the transformations. You will be able to see which source it came from in the `source_relation` column of each model. To use this functionality, you will need to set either the `facebook_ads_union_schemas` OR `facebook_ads_union_databases` variables (cannot do both) in your root `dbt_project.yml` file:

```yml
vars:
    facebook_ads_union_schemas: ['facebook_ads_usa','facebook_ads_canada'] # use this if the data is in different schemas/datasets of the same database/project
    facebook_ads_union_databases: ['facebook_ads_usa','facebook_ads_canada'] # use this if the data is in different databases/projects but uses the same schema name
```
> NOTE: The native `source.yml` connection set up in the package will not function when the union schema/database feature is utilized. Although the data will be correctly combined, you will not observe the sources linked to the package models in the Directed Acyclic Graph (DAG). This happens because the package includes only one defined `source.yml`.

To connect your multiple schema/database sources to the package models, follow the steps outlined in the [Union Data Defined Sources Configuration](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source) section of the Fivetran Utils documentation for the union_data macro. This will ensure a proper configuration and correct visualization of connections in the DAG.

#### Enable or Disable Country and Region Reports
This package uses the `demographics_country`, `demographics_country_actions`, `demographics_region`, and `demographics_region_actions` [pre-built](https://fivetran.com/docs/connectors/applications/facebook-ads/prebuilt-reports) reports, but takes into consideration that not every user may use these tables.

If you are running the Facebook Ads package via Fivetran Quickstart, transformations of the above tables will be dynamically enabled or disabled. Otherwise, transformations of these tables are **disabled** by default.

To enable transformations of the above geo-focused reports, add the following variable configurations to your root `dbt_project.yml` file:

```yml
vars:
  facebook_ads__using_demographics_country: True # False by default. Will enable/disable use of the `demographics_country` and `demographics_country_actions` reports
  facebook_ads__using_demographics_region: True # False by default. Will enable/disable use of the `demographics_region` and `demographics_region_actions` reports
```

#### Passing Through Additional Metrics
By default, this package will select `clicks`, `impressions`, `cost`, `conversion`, and conversion `value` (using the [default](https://fivetran.com/docs/connectors/applications/facebook-ads/custom-reports#attributionwindows) attribution window) from the source reporting tables to store into the output models. `reach` and `frequency` are also selected from `DEMOGRAPHICS_COUNTRY` and `DEMOGRAPHICS_REGION` (and passed to the `facebook_ads__country_report` and `facebook_ads__region_report` models) but not from `BASIC_AD`.

If you would like to pass through additional metrics to the output models, add the below configurations to your `dbt_project.yml` file. These variables allow for the pass-through fields to be aliased (`alias`) and transformed (`transform_sql`) if desired, but not required. Only the `name` of each metric field is required. Use the below format for declaring the respective pass-through variables:

> **Note** Please ensure you exercised due diligence when adding metrics to these models. The metrics added by default (taps, impressions, spend, and default-attribution window conversion values) have been vetted by the Fivetran team maintaining this package for accuracy. There are metrics included within the source reports, for example metric averages, which may be inaccurately represented at the grain for reports created in this package. You will want to ensure whichever metrics you pass through are indeed appropriate to aggregate at the respective reporting levels provided in this package.

```yml
vars:
    facebook_ads__basic_ad_passthrough_metrics: # add metrics found in BASIC_AD
      - name: "new_custom_field"
        alias: "custom_field_alias"
        transform_sql: "coalesce(custom_field_alias, 0)" # reference the `alias` here if you are using one (otherwise the `name`)
      - name: "another_one"
        transform_sql: "coalesce(another_one, 0)"
      - name: "cpc"
    facebook_ads__basic_ad_actions_passthrough_metrics: # add conversion metrics found in BASIC_AD_ACTIONS
      - name: "_7_d_click"
        alias: "conversion_value_7d_click"
      - name: "_1_d_view"
    facebook_ads__basic_ad_action_values_passthrough_metrics: # add conversion metrics found in BASIC_AD_ACTION_VALUES
      - name: "_7_d_click"
        alias: "conversion_value_7d_click"
      - name: "_1_d_view"
    facebook_ads__demographics_country_passthrough_metrics: # Add metrics from DEMOGRAPHICS_COUNTRY
      - name: "inline_link_clicks"
    facebook_ads__demographics_country_actions_passthrough_metrics: # Add conversion metrics from DEMOGRAPHICS_COUNTRY_ACTIONS
      - name: "inline"
    facebook_ads__demographics_region_passthrough_metrics: # Add metrics from DEMOGRAPHICS_REGION
      - name: "cost_per_inline_link_click"
    facebook_ads__demographics_region_actions_passthrough_metrics: # Add conversion metrics from DEMOGRAPHICS_REGION_ACTIONS
      - name: "inline"
```

### Configuring Conversion Action Types
By default, this package considers the following kinds of custom, purchase, and lead `action_types` to be conversions from the `basic_ad_actions`, `basic_ad_action_values`, `demographics_country_actions`, and `demographics_region_actions` source reports:

| Action Type    | Action Description ([Meta docs](https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/)) |
| -------- | ------- |
| `offsite_conversion.fb_pixel_custom`  |  Custom pixel events defined by the advertiser. This will group together individual `offsite_conversion.custom%` custom conversion events.  |
| `offsite_conversion.fb_pixel_lead`  | The number of "lead" events tracked by the pixel or Conversions API on your website and attributed to your ads. Off-Facebook leads, in short.  |
| `onsite_conversion.lead_grouped`  | The number of leads submitted on Meta technologies (including forms and Messenger) and attributed to your ads. On-Facebook leads, in short.   |
| `offsite_conversion.fb_pixel_purchase`  | The number of "purchase" events tracked by the pixel or Conversions API on your website and attributed to your ads. Off-Facebook purchases, in short.   |
| `onsite_conversion.purchase`  | The number of purchases made within Meta technologies (such as Pages or Messenger) and attributed to your ads. On-Facebook purchases, in short.   |

These metrics will be summed together into `conversions` and `conversions_value` fields in each `*_report` end model.

However, you may choose your own `action_types` to consider as conversions. To do so, provide each action type to the below `facebook_ads__conversion_action_types` variable. For each action type, provide either an exact `name` **OR** a consistent `pattern` of naming convention. You may also provide an optional `where_sql` argument for each action type, in case you would like to dynamically choose conversion actions based on other columns (ie `source_relation` if you are running the package on multiple advertisers' datasets).

```yml
# dbt_project.yml
vars:
  facebook_ads__conversion_action_types: # case-insensitive
    - name: exact_conversion_action_type_name # will grab `*_actions` and `*_action_values` records where action_type = 'exact_conversion_action_type_name'
    - pattern: onsite_conversion% # will grab all `onsite_conversion%` records
    - name: offsite_conversion.custom.my_custom_conversion_123
    - name: very_specific_conversion_action
      where_sql: source_relation = 'specific advertiser source' # will grab `*_actions` and `*_action_values` records where (action_type = very_specific_conversion_action and {{ where_sql }})
    - pattern: subscribe%
      where_sql: source_relation = 'advertiser who only cares about subscriptions' # will grab `*_actions` and `*_action_values` records where (action_type like 'subscribe%' and {{ where_sql }})
```

> **Note**: Please ensure to exercise due diligence when adding or removing conversion action types. The action types added by default have been heavily vetted by our friends at [Seer Interactive](https://www.seerinteractive.com/) and the Fivetran team maintaining this package for accuracy. There are many ways to accidentally double-count conversion values, as some action types are hierarchical/aggregates or overlap with others. Reference the action type descriptions in the Meta [API docs](https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/) to ensure you select action types that appropriately and accurately fit your use case.

#### Change the build schema

By default, this package builds the Facebook Ads staging models (8 views, 8 tables) within a schema titled (`<target_schema>` + `_facebook_ads_source`) and your Facebook Ads modeling models (6 tables, 2 intermediate views) within a schema titled (`<target_schema>` + `_facebook_ads`) in your destination. If this is not where you would like your Facebook Ads data to be written to, add the following configuration to your root `dbt_project.yml` file:

```yml
models:
    facebook_ads:
      +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
      staging:
        +schema: my_new_schema_name # Leave +schema: blank to use the default target_schema.
```

#### Change the source table references
If an individual source table has a different name than the package expects, add the table name as it appears in your destination to the respective variable. This is not available when running the package on multiple unioned connections.

> IMPORTANT: See this project's [`dbt_project.yml`](https://github.com/fivetran/dbt_facebook_ads/blob/main/dbt_project.yml) variable declarations to see the expected names.

```yml
vars:
    facebook_ads_<default_source_table_name>_identifier: your_table_name 
```

</details>

### (Optional) Orchestrate your models with Fivetran Transformations for dbt Core™
<details><summary>Expand for more details</summary>

Fivetran offers the ability for you to orchestrate your dbt project through [Fivetran Transformations for dbt Core™](https://fivetran.com/docs/transformations/dbt#transformationsfordbtcore). Learn how to set up your project for orchestration through Fivetran in our [Transformations for dbt Core setup guides](https://fivetran.com/docs/transformations/dbt/setup-guide#transformationsfordbtcoresetupguide).

</details>

## Does this package have dependencies?
This dbt package is dependent on the following dbt packages. These dependencies are installed by default within this package. For more information on the following packages, refer to the [dbt hub](https://hub.getdbt.com/) site.
> IMPORTANT: If you have any of these dependent packages in your own `packages.yml` file, we highly recommend that you remove them from your root `packages.yml` to avoid package version conflicts.

```yml
packages:
    - package: fivetran/fivetran_utils
      version: [">=0.4.0", "<0.5.0"]

    - package: dbt-labs/dbt_utils
      version: [">=1.0.0", "<2.0.0"]

    - package: dbt-labs/spark_utils
      version: [">=0.3.0", "<0.4.0"]
```
<!--section="facebook-ads_maintenance"-->
## How is this package maintained and can I contribute?
### Package Maintenance
The Fivetran team maintaining this package only maintains the [latest version](https://hub.getdbt.com/fivetran/facebook_ads/latest/) of the package. We highly recommend you stay consistent with the latest version of the package and refer to the [CHANGELOG](https://github.com/fivetran/dbt_facebook_ads/blob/main/CHANGELOG.md) and release notes for more information on changes across versions.

### Contributions
A small team of analytics engineers at Fivetran develops these dbt packages. However, the packages are made better by community contributions.

We highly encourage and welcome contributions to this package. Learn how to contribute to a package in dbt's [Contributing to an external dbt package article](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657).

#### Contributors
We thank [everyone](https://github.com/fivetran/dbt_facebook_ads/graphs/contributors) who has taken the time to contribute. Each PR, bug report, and feature request has made this package better and is truly appreciated.

A special thank you to [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation), who we closely collaborated with to introduce native conversion support to our Ad packages.

<!--section-end-->

## Are there any resources available?
- If you have questions or want to reach out for help, see the [GitHub Issue](https://github.com/fivetran/dbt_facebook_ads/issues/new/choose) section to find the right avenue of support for you.
- If you would like to provide feedback to the dbt package team at Fivetran or would like to request a new dbt package, fill out our [Feedback Form](https://www.surveymonkey.com/r/DQ7K7WW).
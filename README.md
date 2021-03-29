# Facebook Ads 

This package models Facebook Ads data from [Fivetran's connector](https://fivetran.com/docs/applications/facebook-ads). It uses data in the format described by [this ERD](https://fivetran.com/docs/applications/facebook-ads#schemainformation).

The main focus of the package is to transform the core ad object tables into analytics-ready models, including an 'ad adapter' model that can be easily unioned in to other ad platform packages to get a single view.  This is especially easy using our [Ad Reporting package](https://github.com/fivetran/dbt_ad_reporting).

## Models

This package contains transformation models, designed to work simultaneously with our [Facebook Ads source package](https://github.com/fivetran/dbt_facebook_ads_source) and our [multi-platform Ad Reporting package](https://github.com/fivetran/dbt_ad_reporting). A dependency on the source package is declared in this package's `packages.yml` file, so it will automatically download when you run `dbt deps`. The primary outputs of this package are described below.

| **model**                      | **description**                                                                                                        |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| facebook_ads__ad_adapter       | Each record represents the daily ad performance of each creative, including information about the used UTM parameters. |
| facebook_ads__account_report   | Each record represents the daily ad performance of each account.                                                       |
| facebook_ads__campaign_report  | Each record represents the daily ad performance of each campaign.                                                      |
| facebook_ads__ad_set_report    | Each record represents the daily ad performance of each ad set.                                                        |

## Installation Instructions

Check [dbt Hub](https://hub.getdbt.com/) for the latest installation instructions, or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more information on installing packages.

## Configuration

By default, this package will look for your Facebook Ads data in the `facebook_ads` schema of your [target database](https://docs.getdbt.com/docs/running-a-dbt-project/using-the-command-line-interface/configure-your-profile). If this is not where your Facebook Ads data is, please add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
config-version: 2

vars:
    facebook_ads_schema: your_schema_name
    facebook_ads_database: your_database_name 
```

For additional configurations for the source models, visit the [Facebook Ads source package](https://github.com/fivetran/dbt_facebook_ads_source).

### Changing the Build Schema
By default this package will build the Facebook Ads staging models within a schema titled (<target_schema> + `_stg_facebook_ads`), the Facebook Creative History models within a schema titled (<target_schema> + `_facebook_ads_creative_history`), and the final Facebook Ads models within a schema titled (<target_schema> + `_facebook_ads`) in your target database. If this is not where you would like your modeled Facebook data to be written to, add the following configuration to your `dbt_project.yml` file:

```yml
# dbt_project.yml

...
models:
    facebook_ads:
        +schema: my_new_schema_name # leave blank for just the target_schema
    facebook_ads_creative_history:
        +schema: my_new_schema_name # leave blank for just the target_schema
    facebook_ads_source:
        +schema: my_new_schema_name # leave blank for just the target_schema
```

## Contributions

Additional contributions to this package are very welcome! Please create issues or open PRs against `master`. Check out [this post](https://discourse.getdbt.com/t/contributing-to-a-dbt-package/657) on the best workflow for contributing to a package.

## Resources:
- Provide [feedback](https://www.surveymonkey.com/r/DQ7K7WW) on our existing dbt packages or what you'd like to see next
- Find all of Fivetran's pre-built dbt packages in our [dbt hub](https://hub.getdbt.com/fivetran/)
- Learn more about Fivetran [in the Fivetran docs](https://fivetran.com/docs)
- Check out [Fivetran's blog](https://fivetran.com/blog)
- Learn more about dbt [in the dbt docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](http://slack.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the dbt blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

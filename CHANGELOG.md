# dbt_facebook_ads v0.8.0

## Feature Updates: Conversion Metrics
[PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43) includes the following updates:
- Adds a `conversions` and `conversions_value` field to each `_report` end model, representing the raw and monetary value of conversions, respectively, that occurred on each day for each ad/campaign/ad set/url/account. These will aggregate conversions of all included `action_types`. 
  - By default, the package will consider purchase, lead, and custom-defined events to be conversions based on the record's `action_type` (see below):

| Action Type    | Action Description ([Meta docs](https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/)) |
| -------- | ------- |
| `offsite_conversion.fb_pixel_custom`  |  Custom pixel events defined by the advertiser. This will group together individual `offsite_conversion.custom%` custom conversion events.  |
| `offsite_conversion.fb_pixel_lead`  | The number of "lead" events tracked by the pixel or Conversions API on your website and attributed to your ads. Off-Facebook leads, in short.  |
| `onsite_conversion.lead_grouped`  | The number of leads submitted on Meta technologies (including forms and Messenger) and attributed to your ads. On-Facebook leads, in short.   |
| `offsite_conversion.fb_pixel_purchase`  | The number of "purchase" events tracked by the pixel or Conversions API on your website and attributed to your ads. Off-Facebook purchases, in short.   |
| `onsite_conversion.purchase`  | The number of purchases made within Meta technologies (such as Pages or Messenger) and attributed to your ads. On-Facebook purchases, in short.   |

  - The above can be configured via the the new `facebook_ads__conversion_action_types` variable. See [README](https://github.com/fivetran/dbt_facebook_ads/tree/main?tab=readme-ov-file#configuring-conversion-action-types) for more details.
```yml
# dbt_project.yml
vars:
  facebook_ads__conversion_action_types: # case-insensitive
    - name: exact_conversion_action_type_name # will grab `basic_ad_actions` records where action_type = 'exact_conversion_action_type_name'
    - pattern: onsite_conversion% # will grab all `onsite_conversion%` records
    - name: offsite_conversion.custom.my_custom_conversion_123
    - name: very_specific_conversion_action
      where_sql: source_relation = 'specific advertiser source' # will grab `basic_ad_actions` records where (action_type = very_specific_conversion_action and {{ where_sql }})
    - pattern: subscribe%
      where_sql: source_relation = 'advertiser who only cares about subscriptions' # will grab `basic_ad_actions` records where (action_type like 'subscribe%' and {{ where_sql }})
```

>**Note**: If you were previously utilizing the `facebook_ads__basic_ad_passthrough_metrics` variable to include a (likely null) field called `conversions` or `conversions_value`, the package's version of these fields will take precedence over yours. To continue including your old conversions fields, change the `alias` of the passthrough field to another name.

- Creates the new `facebook_ads__basic_ad_actions_passthrough_metrics` and `facebook_ads__basic_ad_action_values_passthrough_metrics` variables to pass through additional conversion value metrics that are calculated using different attribution windows. 
  - By default, the package includes only the conversion values calculated using the [default](https://fivetran.com/docs/connectors/applications/facebook-ads/custom-reports#attributionwindows) attribution window set in Meta, but your report may include calculations using the other windows defined [here](https://developers.facebook.com/docs/marketing-api/reference/ads-action-stats/). See [README](https://github.com/fivetran/dbt_facebook_ads/tree/main?tab=readme-ov-file#passing-through-additional-metrics) for details on how to use the new variables.
- Adds `optimization_goal` field to `facebook_ads__ad_set_report` model. This is defined as the optimization goal this ad set is using, possible values of which are defined [here](https://developers.facebook.com/docs/marketing-api/reference/ad-campaign/#fields).
- Adds `conversion_domain` field to `facebook_ads__ad_report` model. This is defined as the domain you've configured the ad to convert to.

## Documentation
- Documents the ability to transform metrics provided to the `facebook_ads__basic_ad_passthrough_metrics` and `facebook_ads__basic_ad_action_values_passthrough_metrics` variables. See [README](https://github.com/fivetran/dbt_facebook_ads/tree/main?tab=readme-ov-file#passing-through-additional-metrics) for details ([PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43)).
- Added missing documentation for fields in the campaign, ad set, and account report models ([PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43)).

## Under the Hood
- Updated the `quickstart.yml` file to allow for automated Quickstart data model deployments ([PR #40](https://github.com/fivetran/dbt_facebook_ads/pull/40)).
- Updated the PR templates to align with our most up-to-date standards ([PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43)).
- Removed the now-defunct 2nd reviewer bot workflow ([PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43)).
- Added a new [version](https://github.com/fivetran/dbt_facebook_ads/blob/main/macros/facebook_ads_persist_pass_through_columns.sql) of the `persist_pass_through_columns()` [macro](https://github.com/fivetran/dbt_fivetran_utils/blob/v0.4.10/macros/persist_pass_through_columns.sql) in which we can include `coalesces` and exclusion fields. ([PR #43](https://github.com/fivetran/dbt_facebook_ads/pull/43)).
  - This macro will sum together any passthrough columns and cast them as **floats**.

## Contributors
- [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation)

# dbt_facebook_ads v0.7.2

[PR #38](https://github.com/fivetran/dbt_facebook_ads/pull/38) includes the following updates: 
## Bug Fixes 
- This package now leverages the new `facebook_ads_extract_url_parameter()` macro for use in parsing out url parameters. This was added to create special logic for Databricks instances not supported by `dbt_utils.get_url_parameter()`.
  - This macro will be replaced with the `fivetran_utils.extract_url_parameter()` macro in the next breaking change of this package.

## Under the Hood 
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_facebook_ads v0.7.1

[PR #36](https://github.com/fivetran/dbt_facebook_ads/pull/36) includes the following updates:
## Documentation Updates
- The [prerequisite steps in the README](https://github.com/fivetran/dbt_facebook_ads#step-1-prerequisites) for generating the `basic_ad` pre-built report have been modified to reflect the current state of the Facebook Ads connector.
- Adds the [DECISIONLOG](DECISIONLOG.md) to clarify why there exist differences among aggregations across different grains.

# dbt_facebook_ads v0.7.0
[PR #34](https://github.com/fivetran/dbt_facebook_ads/pull/34) includes the following updates:
## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple facebook_ads connectors. Refer to the [Union Multiple Connectors README section](https://github.com/fivetran/dbt_facebook_ads/blob/main/README.md#union-multiple-connectors) for more details.

## Under the hood 🚘
- In the source package, updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- To distinguish which source each field comes from, added `source_relation` column in each staging and downstream model and applied the `fivetran_utils.source_relation` macro.
  - The `source_relation` column is included in all joins and window function partition clauses in the transform package. 
- Updated tests to account for the new `source_relation` column.

[PR #27](https://github.com/fivetran/dbt_facebook_ads/pull/27) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).
# dbt_facebook_ads v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #23](https://github.com/fivetran/dbt_facebook_ads/pull/23) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- `packages.yml` has been updated to reflect new default `fivetran/fivetran_utils` version, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## 🎉 Features 🎉
- For use in the [dbt_ad_reporting package](https://github.com/fivetran/dbt_ad_reporting), users can now allow records having nulls in url fields to be included in the `ad_reporting__url_report` model. See the [dbt_ad_reporting README](https://github.com/fivetran/dbt_ad_reporting) for more details([#25](https://github.com/fivetran/dbt_facebook_ads/pull/25)). 
## 🚘 Under the Hood 🚘
- Disabled the `not_null` test for `facebook_ads__url_report` when null urls are allowed ([#25](https://github.com/fivetran/dbt_facebook_ads/pull/25)).

# dbt_facebook_ads v0.5.0
## 🚨 Breaking Changes 🚨
The following changes come with PR [https://github.com/fivetran/dbt_facebook_ads/pull/21]:
- Renames `facebook_ads__ad_adapter` model to `facebook_ads__url_report` to more accurately reflect what is included in the report; this report now also filters for only records that have a url value for `creative_history.page_link` or `creative_history.template_page_link`. 
- Renames `facebook_ads__creative_history_prep` model to `int_facebook_ads__creative_history` to conform with new styling standards.
## 🎉 Feature Enhancements 🎉
PR [https://github.com/fivetran/dbt_facebook_ads/pull/21] includes the following enhancements:
- Addition of new `facebook_ads__ad_report` that reports `spend`, `clicks` and `impressions` at the ad level.
- `README` updates for easier navigation and use of the package.
- Migrates `dbt_facebook_ads_creative_history.stg_facebook_ads__url_tag` model directly into this package as a final model named `facebook_ads__url_tags`. 
- Added passthrough functionality for `BASIC_AD` pre-built report using `facebook_ads__basic_ad_metrics` variable.`facebook_ads__basic_ad_metrics` example.
```yml
vars:
  facebook_ads__basic_ad_metrics:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
```
# dbt_facebook_ads v0.4.1

### Updates
- Adding in `Required Report(s)` section to be consistent with `dbt_facebook_ads_source` package.

# dbt_facebook_ads v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_facebook_ads_source`. Additionally, the latest `dbt_facebook_ads_source` package has a dependency on the latest `dbt_fivetran_utils`. Further, the latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_facebook_ads v0.1.0 -> v0.3.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!

# dbt_facebook_ads v0.UPDATE.UPDATE

 ## Under the Hood:

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

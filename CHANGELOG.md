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

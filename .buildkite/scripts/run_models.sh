#!/bin/bash

set -euo pipefail

apt-get update
apt-get install libsasl2-dev

python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip setuptools
pip install -r integration_tests/requirements.txt
mkdir -p ~/.dbt
cp integration_tests/ci/sample.profiles.yml ~/.dbt/profiles.yml

db=$1
echo `pwd`
cd integration_tests
dbt deps
dbt seed --target "$db" --full-refresh
dbt source freshness --target "$db" || echo "...Only verifying freshness runs…"
dbt run --target "$db" --full-refresh
dbt test --target "$db"
if [ "$db" = "bigquery" ] || [ "$db" = "redshift" ] || [ "$db" = "postgres" ] || [ "$db" = "snowflake" ]; then
dbt run --vars '{facebook_ads_creative_history_identifier: facebook_ads_creative_history_json_data}' --target "$db" --full-refresh
dbt test --target "$db"
fi
dbt run --vars '{ad_reporting__url_report__using_null_filter: false, facebook_ads__using_demographics_country: true, facebook_ads__using_demographics_region: true}' --target "$db" --full-refresh
dbt test --vars '{ad_reporting__url_report__using_null_filter: false, facebook_ads__using_demographics_country: true, facebook_ads__using_demographics_region: true}' --target "$db"
dbt run-operation fivetran_utils.drop_schemas_automation --target "$db"

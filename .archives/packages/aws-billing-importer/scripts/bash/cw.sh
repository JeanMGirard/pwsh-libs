#! /usr/bin/env bash

export AWS_PROFILE="${AWS_PROFILE:-gtv-dev-superuser}"
export NL="|"

rm out/cw.*




## Metrics
# Values:join('$NL', map(&join('=', [Name,Value]), Dimensions[]))
query="$(aws-query "Metrics[].{
  Namespace:Namespace,
  Name:MetricName,
  Dimensions:join(',', Dimensions[*].Name)
}")"
 # --namespace "CWAgent" \
aws-call awsv-exec cloudwatch list-metrics --max-items 500 --query "\"$query\"" \
  | jq -r '. | group_by(.Namespace,.Name) | map(.[0] + { Count: length }) | .' \
  | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/cw.metrics.csv




## alarms
query=$(aws-query "MetricAlarms[].{
  Namespace:Namespace,
  Metric:MetricName,
  Name:AlarmName,
  Description:AlarmDescription
}")
aws-call awsv-exec cloudwatch describe-alarms --query "\"$query\"" \
  | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | unique | @csv' \
  | tee out/cw.alarms


## Logs
awsv-exec logs describe-log-groups \
	--no-paginate \
	--query "logGroups[*].{
    Name:logGroupName,
    FilterCount:metricFilterCount,
    Arn:arn,
    Bytes:storedBytes,
    RetentionDays:to_string(retentionInDays || 'Never Expire')
  }" \
    --output json | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/cw.log-groups

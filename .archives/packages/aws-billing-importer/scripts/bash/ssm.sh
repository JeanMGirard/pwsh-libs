#! /usr/bin/env bash

export AWS_PROFILE="${AWS_PROFILE:-gtv-dev-superuser}"
NL="|"

rm out/ssm.*


## SSM
awsv-exec ssm describe-parameters \
	--no-paginate \
	--query "Parameters[*].{
    Name:Name,Type:Type,
    Tier:Tier,DataType:DataType
  }" \
  --output json | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ssm.parameters

awsv-exec ssm  describe-instance-information \
	--no-paginate \
	--query "InstanceInformationList[*]" \
  --output json | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ssm.instances

awsv-exec ssm list-documents \
	--no-paginate \
	--query "DocumentIdentifiers[*].{
    Owner:Owner,Type:TargetType,
    Name:Name,Format:DocumentFormat
  }" \
  --output json | jq -r '(.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ssm.documents




## secretsmanager
# echo "Owner Type Name Format" > secretsmanager.secrets.txt
# awsv-exec secretsmanager list-secrets \
# 	--no-paginate \
# 	--query "DocumentIdentifiers[*].[Owner,TargetType,DocumentFormat,Name]" \
# 	--output text >> out/secretsmanager.secrets.txt

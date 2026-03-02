#! /usr/bin/env bash

export AWS_PROFILE="${AWS_PROFILE:-gtv-dev-superuser}"
NL="|"

rm out/ec2.*


## MQ
awsv-exec mq list-brokers \
  --no-paginate \
	--query "BrokerSummaries[*].{
    Name:BrokerName,
    Type:EngineType,
    Mode:DeploymentMode,
    InstanceType:HostInstanceType,
    Id:BrokerId,
    Arn:BrokerArn
  }" \
  --output json | jq -r '. 
    | unique | sort_by( .Name )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.mq.instances


## RDS
awsv-exec rds describe-db-instances \
  --no-paginate \
	--query "DBInstances[*].{
    ClusterId:DBClusterIdentifier,
    InstanceId:DBInstanceIdentifier,
    InstanceSize:DBInstanceClass,
    Status:DBInstanceStatus,
    DB_Name:DBName,
    DB_Arn:DBInstanceArn,
    Engine:Engine,
    Public:PubliclyAccessible,
    Endpoint:join(':', [Endpoint.Address,to_string(Endpoint.Port)]),
    CaCert:CACertificateIdentifier,
    PreferredBackupWindowrn:PreferredBackupWindow
  }" \
  --output json | jq -r '. 
    | unique | sort_by( .ClusterId )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.rds.instances


## ec2
awsv-exec  ec2 describe-instances \
  --no-paginate \
  --query "Reservations[].Instances[].{
    Id:InstanceId,
    Name:join(',', Tags[?Key=='Name'].Value),
		Type:InstanceType,
		Monitoring:Monitoring.State,
		PrivateIp:PrivateIpAddress,
		State:State.Name,
		VpcId:VpcId,
		SubnetId:SubnetId,
		DeviceMappings:join(',', BlockDeviceMappings[].DeviceName),
		InstanceProfile:IamInstanceProfile.Arn,
		SecurityGroups:join(',', SecurityGroups[].GroupName),
    Tags:join('$NL', Tags[].Key)
	}" \
  --output json | jq -r '. 
    | unique | sort_by( .Type )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.instances

## ASG

#LaunchTemplate:LaunchTemplate.{Name:LaunchTemplateName,Version:Version},
awsv-exec autoscaling describe-auto-scaling-groups \
  --no-paginate \
  --query "AutoScalingGroups[].{
    Name:AutoScalingGroupName,
    Arn:AutoScalingGroupARN,
    MinSize:MinSize,
    MaxSize:MaxSize,
    Desired:DesiredCapacity,
    DefaultCooldown:DefaultCooldown,
    HealthCheck:HealthCheckType,
    HealthCheckGracePeriod:HealthCheckGracePeriod,
    CapacityRebalance:CapacityRebalance,
    ServiceLinkedRoleARN:ServiceLinkedRoleARN,
    AvailabilityZones:join(',', AvailabilityZones),
    LoadBalancerNames:join(',', LoadBalancerNames),
    TargetGroupARNs:join(',', TargetGroupARNs),
    Subnet:VPCZoneIdentifier
  }" \
  --output json | jq -r '. 
    | unique | sort_by( .Name )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.scaling-groups


awsv-exec autoscaling describe-scaling-activities \
  --no-paginate \
  --query "Activities[].{
    AutoScalingGroup:AutoScalingGroupName,
    ActivityId:ActivityId,
    Description:Description,
    Cause:Cause,
    StartTime:StartTime,
    EndTime:EndTime,
    StatusCode:StatusCode,
    Progress:Progress,
    Details:Details
  }" \
  --output json | jq -r '. 
    | unique | sort_by( .AutoScalingGroup )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.scaling-activities


awsv-exec autoscaling describe-policies \
  --no-paginate \
  --query "ScalingPolicies[].{
    Policy:PolicyName,
    Type:PolicyType,
    Adj_Type:AdjustmentType,
    Adj_Steps:join('$NL', map(&to_string(@), StepAdjustments[*].{Adjust:ScalingAdjustment,Bounds:[MetricIntervalLowerBound,MetricIntervalUpperBound]})),
    Metric:TargetTrackingConfiguration.PredefinedMetricSpecification.PredefinedMetricType,
    AggType:MetricAggregationType,
    EstWarmup:EstimatedInstanceWarmup,
    
    Alarms:join('$NL', Alarms[*].AlarmARN),
    Arn:PolicyARN,
    Enabled:Enabled,
    AutoScalingGroup:AutoScalingGroupName,
    Value:TargetTrackingConfiguration.TargetValue,
    MetricLabel:TargetTrackingConfiguration.PredefinedMetricSpecification.ResourceLabel,
    DisableScaleIn:DisableScaleIn
  }" \
  --output json | jq -r '. 
    | unique | sort_by( .Policy )
    | (.[0] | keys_unsorted) as $keys | $keys, map([.[ $keys[] ]])[] | @csv' \
  | tee out/ec2.scaling-policies

$data = @('amplify', 'amplifybackend', 'amplifyuibuilder', 'apigateway', 'apigatewaymanagementapi', 'apigatewayv2',
'appconfig', 'appconfigdata', 'appflow', 'appintegrations', 'application-autoscaling',
'application-insights', 'applicationcostprofiler', 'appmesh', 'apprunner', 'appstream',
'appsync', 'athena', 'autoscaling', 'autoscaling-plans', 'budgets', 'cloudcontrol',
'clouddirectory', 'cloudformation', 'cloudfront', 'cloudhsm', 'cloudhsmv2', 'cloudsearch',
'cloudsearchdomain', 'cloudtrail', 'cloudwatch', 'codeartifact', 'codebuild', 'codecommit',
'codepipeline', 'cognito-identity', 'cognito-idp', 'cognito-sync', 'databrew', 'dataexchange',
'datapipeline', 'datasync', 'accessanalyzer', 'account', 'acm', 'acm-pca', 'alexaforbusiness', 'amp',
'auditmanager', 'backup', 'backup-gateway', 'batch', 'braket', 'ce', 'chime', 'chime-sdk-identity',
'chime-sdk-meetings', 'chime-sdk-messaging', 'cloud9', 'codeguru-reviewer', 'codeguruprofiler',
'codestar', 'codestar-connections', 'codestar-notifications', 'comprehend', 'comprehendmedical',
'compute-optimizer', 'connect', 'connect-contact-lens', 'connectparticipant', 'cur',
'customer-profiles', 'dax', 'detective', 'devicefarm', 'devops-guru', 'directconnect',
'discovery', 'dlm', 'dms', 'docdb', 'drs', 'ds', 'dynamodb', 'dynamodbstreams', 'ebs', 'ec2',
'ec2-instance-connect', 'ecr', 'ecr-public', 'ecs', 'efs', 'eks', 'elastic-inference',
'elasticache', 'elasticbeanstalk', 'elastictranscoder', 'elb', 'elbv2', 'emr', 'emr-containers',
'es', 'events', 'evidently', 'finspace', 'finspace-data', 'firehose', 'fis', 'fms', 'forecast',
'forecastquery', 'frauddetector', 'fsx', 'gamelift', 'glacier', 'globalaccelerator', 'glue',
'grafana', 'greengrass', 'greengrassv2', 'groundstation', 'guardduty', 'health', 'healthlake',
'honeycode', 'iam', 'identitystore', 'imagebuilder', 'importexport', 'inspector', 'inspector2', 'iot', 'iot-data', 'iot-jobs-data', 'iot1click-devices', 'iot1click-projects', 'iotanalytics', 'iotdeviceadvisor', 'iotevents', 'iotevents-data', 'iotfleethub', 'iotsecuretunneling', 'iotsitewise', 'iotthingsgraph', 'iottwinmaker', 'iotwireless', 'ivs', 'kafka', 'kafkaconnect', 'kendra', 'kinesis', 'kinesis-video-archived-media', 'kinesis-video-media', 'kinesis-video-signaling', 'kinesisanalytics', 'kinesisanalyticsv2', 'kinesisvideo', 'kms', 'lakeformation', 'lambda', 'lex-models', 'lex-runtime', 'lexv2-models', 'lexv2-runtime', 'license-manager', 'lightsail', 'location', 'logs', 'lookoutequipment', 'lookoutmetrics', 'lookoutvision', 'machinelearning', 'macie', 'macie2', 'managedblockchain', 'marketplace-catalog', 'marketplace-entitlement', 'marketplacecommerceanalytics', 'mediaconnect',
'mediaconvert', 'medialive', 'mediapackage', 'mediapackage-vod', 'mediastore', 'mediastore-data',
'mediatailor', 'memorydb', 'meteringmarketplace', 'mgh', 'mgn', 'migration-hub-refactor-spaces',
'migrationhub-config', 'migrationhubstrategy', 'mobile', 'mq', 'mturk', 'mwaa', 'neptune',
'network-firewall', 'networkmanager', 'nimble', 'opensearch', 'opsworks', 'opsworkscm',
'organizations', 'outposts', 'panorama', 'personalize', 'personalize-events',
'personalize-runtime', 'pi', 'pinpoint', 'pinpoint-email', 'pinpoint-sms-voice', 'polly', 'pricing', 'proton', 'qldb', 'qldb-session', 'quicksight', 'ram', 'rbin', 'rds', 'rds-data', 'redshift', 'redshift-data', 'rekognition', 'resiliencehub', 'resource-groups', 'resourcegroupstaggingapi', 'robomaker', 'route53', 'route53-recovery-cluster', 'route53-recovery-control-config', 'route53-recovery-readiness', 'route53domains', 'route53resolver', 'rum', 's3control', 's3outposts', 'sagemaker', 'sagemaker-a2i-runtime', 'sagemaker-edge', 'sagemaker-featurestore-runtime', 'sagemaker-runtime', 'savingsplans', 'schemas', 'sdb', 'secretsmanager', 'securityhub', 'serverlessrepo', 'service-quotas', 'servicecatalog', 'servicecatalog-appregistry', 'servicediscovery', 'ses', 'sesv2', 'shield', 'signer', 'sms', 'snow-device-management', 'snowball', 'sns', 'sqs', 'ssm', 'ssm-contacts', 'ssm-incidents', 'sso', 'sso-admin', 'sso-oidc', 'stepfunctions', 'storagegateway', 'sts', 'support', 'swf', 'synthetics', 'textract', 'timestream-query', 'timestream-write', 'transcribe', 'transfer', 'translate', 'voice-id', 'waf', 'waf-regional', 'wafv2', 'wellarchitected', 'wisdom', 'workdocs', 'worklink', 'workmail', 'workmailmessageflow', 'workspaces', 'workspaces-web', 'xray', 's3api',
's3', 'ddb', 'deploy', 'configservice', 'opsworks-cm', 'history', 'cli-dev', 'help')




foreach ($svc in $data)
{
    $errOutput = $( $output = & aws "$svc" list ) 2>&1
    if(!$errOutput) { continue; }

    $lines = $errOutput -split "\n"
    $append = 0
    $cmds = [System.Collections.ArrayList]@()
#    Write-Output $lines.Length

    foreach ($line in $lines) {
        $line = ("$line" -replace "|").Trim()
        if($line.Length -lt 7){ continue; }

        if ($append -gt 0) {
            $actions = ($line -split " ") | Where-Object { $_ -like "ls*" -or $_ -like "list*" }
            foreach ($action in $actions)
            {
                $cmds.Add($action -replace "\s")
            }
        }
        if ($line -like "*valid choices are:*") {
            $append = 1
        }
    }
    if($cmds.Count -gt 0){

        $sep = "`n${svc} "
        Write-Output "$svc $($cmds -join $sep)"
        Write-Output "$svc $($cmds -join $sep)" | out-file -FilePath "commands-lists.txt" -Append
    }
}



#$line | out-file -FilePath "D:\Scripts\iis1.txt" -Append
#        $i1
#        $listOfCmds = $errOutput -split "valid choices are:"
#        $listOfCmds
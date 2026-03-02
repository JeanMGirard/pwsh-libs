
$onlyNotEmpty = 1
$removeAction = 1
$profile = "mws-us"
$outPrefix = "$profile"

if(!(Test-Path -Path "out/")){
    mkdir "out"
}
if(!(Test-Path -Path "out/${outPrefix}")){
    mkdir "out/${outPrefix}"
}
if(!(Test-Path -Path "out/${outPrefix}/errors")){
    mkdir "out/${outPrefix}/errors"
}

foreach($line in Get-Content "./commands-lists.txt"){
    $svc = ($line -split " ")[0]
    $cmd = ($line -split " ")[1]
    $params = " ${line} --profile ${profile} " -split " "
    Write-Output "$svc | $params"

    $errOutput = $( $output = & aws $params ) 2>&1


    if($errOutput -like "*arguments are required*") {
        Write-Output "arguments required"
        Write-Output $errOutput | out-file -FilePath "out/${outPrefix}/errors/args-$svc.$cmd"
        continue;
    }
    elseif($errOutput){
        Write-Output $errOutput
        Write-Output $errOutput | out-file -FilePath "out/${outPrefix}/errors/$svc.$cmd"
        continue
    }
    if($output){
        if($onlyNotEmpty -and ($output -split "\n").Length -lt 2){
            continue
        }
        if($removeAction){
            $cmd = $cmd -replace "list-"
        }
        Write-Output $output | out-file -FilePath "out/${outPrefix}/${svc}.${cmd}.yml"
    }
    # Write-Output "$errOutput" # | out-file -FilePath "out/$svc.$cmd.yml"
}
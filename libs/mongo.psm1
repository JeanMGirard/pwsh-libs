

$env:MONGO_CONFIG_FILE = [System.Environment]::GetFolderPath("ApplicationData") + "\mongocli\config.toml"


function New-MongoConfigFile {
  if (-not (Test-Path $env:MONGO_CONFIG_FILE)) {
    # Create the directory if it doesn't exist
    $configDir = [System.IO.Path]::GetDirectoryName($env:MONGO_CONFIG_FILE)
    if (-not (Test-Path $configDir)) { New-Item -Path $configDir -ItemType Directory -Force; }
    # Create the file
    New-Item -Path $env:MONGO_CONFIG_FILE -ItemType File -Force
  }
  
  # Example config file
  #
  # [default]
  #   organization_id = "qwer5678uiop23jb45lk78mn"
  #   public_api_key = "ABCDEFG"
  #   project_id= "5e2f04ecf10fcd33c7d4077e"
  #   private_api_key = "e750d2bf-1234-4cde-5678-ca4dcbcac9a4"
  #   service = "cloud"
  # [myOpsManager]
  #   ops_manager_ca_certificate = /etc/ssl/certs/ca.pem
  #   ops_manager_skip_verify = no
  #   ops_manager_url = "http://localhost:9080/"
  #   organization_id = "jklsa23123dsdf3jj456hs2"
  #   public_api_key = "HIJKLMN"
  #   project_id = "kk12jdn43jd123dkdkf97jg"
  #   private_api_key = "e750d2bf-9101-4cde-1121-ca4dcbcac9a5"
  #   service = "ops-manager"
}


Export-ModuleMember -Function `
  New-MongoConfigFile
Export-ModuleMember -Variable `
  MONGO_CONFIG_FILE

  
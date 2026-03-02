###################################################
#Script Title: Get DCOM Application Tool  
#Script File Name: Get-DCOMApplication.ps1 
#Author: Ron Ratzlaff (aka "The Ratzenator")  
#Date Created: 12/23/2015 
##################################################
 
#Requires -Version 3.0 


Function Get-DCOMApplication
{
    <#  
      .SYNOPSIS  
        
          The "Get-DCOMApplication" function displays all of the DCOM applications installed on one, or more computers.  
           
      .DESCRIPTION 

          I created this simple Get DCOM Application Tool, because I discovered many Event ID 10016 error notifications in the System Log on some of my SCCM 2012 servers. The event messages displayed the DCOM application ID, but it did not display the DCOM application name so I was not able to determine which DCOM application was causing the event to occur. When accessing the Component Services Management Tool to try and find the culprit DCOM application, you have to scroll through the list while in "Detail" view and meticulously look under the "Application ID" column since Microsoft has not provided a Find or Search function. I thought this was a real pain, so I created this PowerShell tool to help make this easier for me. There is only one parameter (ComputerName), because I did not want to get too elaborate and complex with this scripting tool and I decided to allow those who would like to use it take advantage of the Where-Objet cmdlet to filter out whatever DCOM application that they would like to find. 
      
      .EXAMPLE

          Retrieve all DCOM application properties on the local computer

          Get-DCOMApplication

      .EXAMPLE

          Retrieve all DCOM application properties on a single remote computer, or multiple remote computers

          Single Remote Computer
          ----------------------
          
          Get-DCOMApplication -ComputerName 'RemoteComputer1'

          Multiple Remote Computers
          -------------------------

          Get-DCOMApplication -ComputerName 'RemoteComputer1', 'RemoteComputer2', 'RemoteComputer3'

      .EXAMPLE
          
          Retrieve a DCOM application's properties given its application ID, or application name on the local computer

          ApplicationID Property
          ----------------------

          Get-DCOMApplication | Where-Object -FilterScript {$_.ApplicationID -eq '{AD65A69D-3831-40D7-9629-9B0B50A93843}'}

          ApplicationName
          ----------------

          Get-DCOMApplication | Where-Object -FilterScript {$_.ApplicationName -eq 'SMS Agent Host'}

          Both ApplicationID and ApplicationName Properties
          -------------------------------------------------

          Get-DCOMApplication | Where-Object -FilterScript {($_.ApplicationID -eq '{AD65A69D-3831-40D7-9629-9B0B50A93843}') -or ($_.ApplicationName -eq 'SMS Agent Host')}

      .EXAMPLE
          
          Retrieve a DCOM application's properties given its application ID on a single remote computer, or multiple remote computers

          Single Remote Computer
          ----------------------
          
          Get-DCOMApplication -ComputerName 'RemoteComputer1' | Where-Object -FilterScript {$_.ApplicationID -eq '{AD65A69D-3831-40D7-9629-9B0B50A93843}'}

          Multiple Remote Computers
          -------------------------

          Get-DCOMApplication -ComputerName 'RemoteComputer1', 'RemoteComputer2', 'RemoteComputer3' | Where-Object -FilterScript {$_.ApplicationID -eq '{AD65A69D-3831-40D7-9629-9B0B50A93843}'}

       .EXAMPLE

          Retrieve a DCOM application's properties given its name on multiple remote computers

          Get-DCOMApplication -ComputerName 'RemoteComputer1', 'RemoteComputer2', 'RemoteComputer3' | Where-Object -FilterScript {$_.Name -eq 'SMS Agent Host'}
    #>

    [cmdletbinding()]
    
        Param 
        (
            [Parameter(HelpMessage='Enter the name of either one or more computers')]
               [ValidateNotNullOrEmpty()]
               [Alias('CN')]   
               $ComputerName = $env:COMPUTERNAME
        )
    
    Begin {}
        
    Process
    {
        $NewLine = "`r`n"
        
       If ($ComputerName -ne $env:COMPUTERNAME)
       {
            $ComputerStatus = Foreach ($Computer in $ComputerName) 
            {
                $Online = @(ForEach-Object -Process { If (Test-Connection -ComputerName $Computer -Count '1' -Quiet) { $Computer.ToUpper() } })

                $Offline = @(ForEach-Object -Process { If (!(Test-Connection -ComputerName $Computer -Count '1' -Quiet)) { $Computer.ToUpper() } })

                [pscustomobject] @{
                    'Online' = $Online;
                    'Offline' = $Offline
                }
            }

            $NewLine 
                    
            Write-Output -Verbose "---------- Computers Online ----------"

            If ($ComputerStatus.Online)
            {
                $NewLine

                $ComputerStatus.Online
            }

            Else 
            {
                $NewLine

                Write-Output -Verbose 'None'
            }

            $NewLine 
                    
            Write-Output -Verbose "---------- Computers Offline ----------"
                     
            If ($ComputerStatus.Offline)
            {
                $NewLine

                $ComputerStatus.Offline
            }

            Else 
            {
                $NewLine

                Write-Output -Verbose 'None'
            }

            Foreach ($Computer in $ComputerStatus.Online)  
            {
                Try
                {
                    $Props = Get-WmiObject -Class "Win32_DCOMApplication" -Namespace "root\CIMV2" -ComputerName $Computer

                    Foreach ($Prop in $Props) 
                    { 
                        [pscustomobject] @{
                            ApplicationID = $Prop.AppID;
                            Caption = $Prop.Caption;
                            Description = $Prop.Description;
                            InstallationDate = $Prop.InstallDate; 
                            ApplicationName = $Prop.Name;
                            Status = $Prop.Status;
                            Computer = $Computer
                        } 
                    }
                }

                Catch
                {
                    $NewLine

                    Write-Warning -Message "The following error resulted on $($Computer): $_"

                    $NewLine
                }
            }
        }

        Else
        {
            Try
            {
                $Props = Get-WmiObject -Class "Win32_DCOMApplication" -Namespace "root\CIMV2" -ComputerName $ComputerName

                Foreach ($Prop in $Props) 
                { 
                    [pscustomobject] @{
                        ApplicationID = $Prop.AppID;
                        Caption = $Prop.Caption;
                        Description = $Prop.Description;
                        InstallationDate = $Prop.InstallDate; 
                        ApplicationName = $Prop.Name;
                        Status = $Prop.Status;
                        Computer = $ComputerName
                    }
                }
            }

            Catch
            {
                $NewLine

                Write-Warning -Message "The following error resulted on $($ComputerName): $_"

                $NewLine
            }
        }
    }

    End {}
}
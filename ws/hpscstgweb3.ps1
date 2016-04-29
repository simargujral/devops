Configuration hpsc_stg_web3
{
    param
    (
        [string]$WebPiSourcePath="C:\Program Files\WindowsPowerShell\Modules\xWebAdministration\WebPi\wpilauncher.exe",
        [string]$WebPiCmdPath ="$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
    )
	Import-DscResource -ModuleName xWebAdministration

    Node 'localhost'
    {    
        WindowsFeature IIS 
        { 
            Ensure          = "Present" 
            Name            = "Web-Server" 
        } 
        # Install the ASP .NET 4.6 role 
        WindowsFeature AspNet46 
        { 
            Ensure          = "Present" 
            Name            = "Web-Asp-Net45" 
        }
        WindowsFeature WebServerManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }
        WindowsFeature Web-Mgmt-Service  
        {  
            Ensure          = 'Present'  
            Name            = 'Web-Mgmt-Service' 	  
            DependsOn       = '[WindowsFeature]IIS'  
        }
        Package WebPi_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = $WebPiSourcePath
            ProductId = '4D84C195-86F0-4B34-8FDE-4A17EB41306A'
            Arguments = ''
        }

        Package WebDeploy_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Deploy 3.6"
            Path = $WebPiCmdPath
            ProductId = ''
            Arguments = "/install /products:WDeploy /AcceptEula"
            DependsOn = @("[Package]WebPi_Installation")
        }
	    xWebsite DefaultSite  
        { 
            Ensure          = "Present" 
            Name            = "Default Web Site" 
            State           = "Stopped" 
            PhysicalPath    = "C:\inetpub\wwwroot" 
            DependsOn       = "[WindowsFeature]IIS" 
        }
    # enable remote deployments
        Registry Enable-Remote-Management {
            Ensure         = 'Present'
            Key            = 'HKLM:\SOFTWARE\Microsoft\WebManagement\Server'  
            ValueName      = 'EnableRemoteManagement'
            ValueData      = '1'
            ValueType      = 'Dword'
            DependsOn      = '[WindowsFeature]Web-Mgmt-Service'  
        }
        <# Start msdeploy service is running
        Service WMSvc-Running
        {
            Name        = "WMSvc"
            StartupType = "Automatic"
            State       = "Running"
            DependsOn   = '[Registry]Enable-Remote-Management'  
        }
        xWaitForService WMSvc-Wait-Running
        {
            Name         = 'WMSvc'
            State        = 'Running'
            Restart      = $true
            DependsOn    = '[Service]WMSvc-Running'  
        }#>
        #
        # Create the Website 
        #
        File hpsc-stg-web-3 {
            Type            = 'Directory'
            DestinationPath = 'C:\inetpub\wwwroot\hpsc-stg-web-3'
            Ensure          = "Present"
            DependsOn       = '[WindowsFeature]IIS'  
        }        
        # Copy the website content 
        #File WebContent 
        #{ 
        #    Ensure          = "Present" 
        #    SourcePath      = "C:\Program Files\WindowsPowerShell\Modules\xWebAdministration\mysite" 
        #    DestinationPath = "C:\inetpub\wwwroot\hpsc-stg-web-3"
        #    Recurse         = $true 
        #    Type            = "Directory" 
          #  DependsOn       = "[WindowsFeature]AspNet45" 
        #}        
        # Create the new Website with HTTPS 
        xWebsite hpsc-stg-web-3 
        { 
            Ensure          = "Present" 
            Name            = "hpsc-stg-web-3" 
            State           = "Started" 
            PhysicalPath    = "C:\inetpub\wwwroot\hpsc-stg-web-3"
            BindingInfo     = @(
                               MSFT_xWebBindingInformation
                              {
                                  Protocol              = 'http'
                                  Port                  = '80'
                                  HostName              = ''
                              }
                              MSFT_xWebBindingInformation
                              {
                                  Protocol              = 'https'
                                  Port                  = '443'
                                  HostName              = ''
                              } )
        }
    }
}

hpsc_stg_web3

Start-DscConfiguration -Path .\hpsc_stg_web3 -Verbose -Wait -Force
Configuration Sample_xWebsite_NewWebsite
{
    param
    (
        [string]$WebPiSourcePath="C:\Windows\system32\WindowsPowerShell\v1.0\Modules\xWebAdministration\WebPi\wpilauncher.exe",
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
        # Install the ASP .NET 4.5 role 
        WindowsFeature AspNet45 
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
            Name = "Microsoft Web Deploy 3.5"
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
        # Copy the website content 
        File WebContent 
        { 
            Ensure          = "Present" 
            SourcePath      = "C:\Windows\system32\WindowsPowerShell\v1.0\Modules\xWebAdministration\mysite" 
            DestinationPath = "C:\inetpub\mywebsite"
            Recurse         = $true 
            Type            = "Directory" 
            DependsOn       = "[WindowsFeature]AspNet45" 
        }        
        # Create the new Website with HTTPS 
        xWebsite NewWebsite 
        { 
            Ensure          = "Present" 
            Name            = "myWebsite" 
            State           = "Started" 
            PhysicalPath    = "C:\inetpub\mywebsite"
            DependsOn       = "[File]WebContent"
            BindingInfo     = MSFT_xWebBindingInformation
            {
                Protocol              = 'http'
                Port                  = '80'
                HostName              = ''
            }    
        }
    }
}

Sample_xWebsite_NewWebsite

Start-DscConfiguration -Path .\Sample_xWebsite_NewWebsite -Verbose -Wait -Force
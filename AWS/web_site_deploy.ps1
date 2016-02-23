configuration Sample_xWebsite_NewWebsite 
{ 
    param 
    ( 
        # Target nodes to apply the configuration 
        [string[]]$NodeName = 'localhost' 
    ) 
    # Import the module that defines custom resources 
    Import-DscResource -ModuleName xWebAdministration 
    
    Node $NodeName 
    { 
        # Install the IIS role 
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
        # Stop the default website 
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
            SourcePath      = "C:\Windows\system32\WindowsPowerShell\v1.0\\Modules\xWebAdministration\mysite" 
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
        } 
    } 
} Sample_xWebsite_NewWebsite

Start-DscConfiguration -Path .\Sample_xWebsite_NewWebsite -Verbose -Wait -Force
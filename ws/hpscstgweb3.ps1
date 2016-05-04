Configuration hpsc_stg_web3
{
	Import-DscResource -ModuleName xWebAdministration
	Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    Node ('localhost')
    {   
        # Install IIS features	
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
			DependsOn       = '[WindowsFeature]IIS'
        }
		# Enable Web Management Console
        WindowsFeature WebServerManagementConsole
        {
            Name = "Web-Mgmt-Console"
            Ensure = "Present"
        }
		# Enable Web Management Service
        WindowsFeature Web-Mgmt-Service  
        {  
            Ensure          = 'Present'  
            Name            = 'Web-Mgmt-Service' 	  
            DependsOn       = '[WindowsFeature]IIS'  
        }
        # Download Web Platform Installer exe from web
		xRemoteFile wpidownload
		{
			DestinationPath = "C:\wpilauncher.exe"
            Uri = "http://download.microsoft.com/download/F/4/2/F42AB12D-C935-4E65-9D98-4E56F9ACBC8E/wpilauncher.exe"
			DependsOn       = '[WindowsFeature]IIS'
		}
		# Download Visual Studio 2015 Remote Debugger exe from web
        xRemoteFile vsremotedebugger
        {
            DestinationPath = "C:\rtools_setup_x64.exe"
            Uri = "https://download.microsoft.com/download/E/7/A/E7AEA696-A4EB-48DD-BA4A-9BE41A402400/rtools_setup_x64.exe"
			DependsOn       = '[WindowsFeature]IIS'
            
        }
		<#Package WebPi_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = $WebPiSourcePath
            ProductId = '4D84C195-86F0-4B34-8FDE-4A17EB41306A'
            Arguments = ''
        }#>
		# Installing Web Platform Installer
		Package wpiinstall
        {
            Ensure = "Present"
            Name = "Microsoft Web Platform Installer 5.0"
            Path = "C:\wpilauncher.exe"
            ProductId = "4D84C195-86F0-4B34-8FDE-4A17EB41306A"
			DependsOn = '[xRemoteFile]wpidownload'
            
        }
		# Installing Web Deploy
        Package WebDeploy_Installation
        {
            Ensure = "Present"
            Name = "Microsoft Web Deploy 3.5"
            Path = "$env:ProgramFiles\Microsoft\Web Platform Installer\WebPiCmd-x64.exe"
            ProductId = ''
            Arguments = "/install /products:WDeploy /AcceptEula"
            DependsOn = @("[Package]WebPi_Installation")
        }
		<#
		Package rtools
        {
            Ensure = "Present"
            Name = "Microsoft Visual Studio 2015 Remote Debugger"
            Path = "C:\rtools_setup_x64.exe"
			Arguments = "/norestart"
            ProductId = ""
			LogPath = "C:\rtools.log"
			DependsOn       = '[xRemoteFile]vsremotedebugger'
			
            
        }#>
        # Stopping Default Website
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
        # Create the Website 
        <#File hpsc-stg-web-3 {
            Type            = 'Directory'
            DestinationPath = 'C:\inetpub\wwwroot\hpsc-stg-web-3'
            Ensure          = "Present"
            DependsOn       = '[WindowsFeature]IIS'  
        }  #>              
        # Create the new Website
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
                                  HostName              = 'hspc-stg-web-3.hpsalescentral.com'
                              }
                              MSFT_xWebBindingInformation
                              {
                                  Protocol              = 'https'
                                  Port                  = '443'
                                  HostName              = 'hspc-stg-web-3.hpsalescentral.com'
                              } )
        }
    }
}

hpsc_stg_web3

Start-DscConfiguration -Path .\hpsc_stg_web3 -Verbose -Wait -Force
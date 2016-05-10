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
            DependsOn = @("[Package]wpiinstall")
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
		Script Install-VSRemoteDebugger
        {
            SetScript = {
                Write-Verbose "Starting Installation of VS2015 Remote Debugger"			
                Start-Process 'C:\rtools_setup_x64.exe' -ArgumentList "/install /quiet /norestart" -Wait   
            }
            TestScript = { 
                $check_file="C:\Program Files\Microsoft Visual Studio 14.0\Common7\IDE\Remote Debugger\x64\rdbgservice.exe"
                if(Test-Path $check_file) 
                {
                     Write-Verbose "Remote Debugger Already Installed"
                     return $true
                }
				return $false

            }
            GetScript = { 
                return @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = $result 
                }
            }          
        }
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
        # Create the Directory Structure for the website 
        File hpsc-stg-web-3 {
            Type            = 'Directory'
            DestinationPath = 'C:\inetpub\wwwroot\hpsc-stg-web-3'
            Ensure          = "Present"
            DependsOn       = '[WindowsFeature]IIS'  
        }             
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
		Script createIISMngrUser
        {
            SetScript = {
                [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Management")  
                [Microsoft.Web.Management.Server.ManagementAuthentication]::CreateUser("hpsc-stg-web-3-deploy", "pass@123456") 
                [Microsoft.Web.Management.Server.ManagementAuthorization]::Grant("hpsc-stg-web-3-deploy", "hpsc-stg-web-3", $FALSE)
				
				# Setting password for WDeployAdmin
                net user WDeployAdmin pass@123456 /expires:never
				
                $user = [adsi]"WinNT://$env:computername/WDeployAdmin"
                $user.UserFlags.value = $user.UserFlags.value -bor 0x10000
                $user.CommitChanges()

                $user = [adsi]"WinNT://$env:computername/WDeployConfigWriter"
                $user.UserFlags.value = $user.UserFlags.value -bor 0x10000
                $user.CommitChanges()

                $user = [adsi]"WinNT://$env:computername/wsadmin"
                $user.UserFlags.value = $user.UserFlags.value -bor 0x10000
                $user.CommitChanges()				
            }
            TestScript = {
                [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.Web.Management")
				$getuser=[Microsoft.Web.Management.Server.ManagementAuthentication]::GetUser("hpsc-stg-web-3-deploy")
                if($getuser.enabled -eq "True"){
                    return $true
			    }
				else{
				    return $false
				}

            }
            GetScript = { 
                return @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = $result 
                }
            }          
        }
		Script Install-Certificate
        {
            SetScript = {
                Write-Verbose "Installing SSL cert"
                Import-Certificate -FilePath "C:\Program Files\WindowsPowerShell\Modules\xWebAdministration\hp-idp.cert.cer" -CertStoreLocation "Cert:\LocalMachine\my"
                $certpwd = ConvertTo-SecureString -String "W1rest0ne!" -Force -AsPlainText
                Import-PfxCertificate –FilePath "C:\Program Files\WindowsPowerShell\Modules\xWebAdministration\wildcard_hpsalescentral_com.pfx" -CertStoreLocation "Cert:\LocalMachine\my" -Password $certpwd				
            }
            TestScript = {			
                    $check_cert=Get-ChildItem Cert:\LocalMachine\my\ | ? { $_.Thumbprint -eq '88BACE3D426227E0D476DF4DDD49B477AB2CD1AC323' }
                    if($check_cert.Thumbprint -eq '88BACE3D426227E0D476DF4DDD49B477AB2CD1AC323') 
                    {
                        Write-Verbose "Certificate already installed"
                        return $true
				    }
				    return $false
                
			}
            GetScript = { 
                return @{
                    GetScript = $GetScript
                    SetScript = $SetScript
                    TestScript = $TestScript
                    Result = $result 
                }
            }          
        }
    }
}

hpsc_stg_web3

Start-DscConfiguration -Path .\hpsc_stg_web3 -Verbose -Wait -Force
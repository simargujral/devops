netsh advfirewall firewall add rule name = testITT dir = in protocol = tcp localport = 3389 remoteip = 115.111.126.34/32 enable = yes action = allow
net user WDeployAdmin pass@123456 /expires:never
[System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.Web.Management”)  
[Microsoft.Web.Management.Server.ManagementAuthentication]::CreateUser("MyUser", "pass@123456") 
[Microsoft.Web.Management.Server.ManagementAuthorization]::Grant("MyUser", "hpsc-stg-web-3", $FALSE)
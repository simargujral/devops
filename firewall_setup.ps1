netsh advfirewall firewall add rule name = testITT dir = in protocol = tcp localport = 3389 remoteip = 115.111.126.34/32 enable = yes action = allow
net user WDeployAdmin pass@123456 /expires:never
netsh advfirewall firewall add rule name = WD1 dir = in protocol = tcp localport = 8172 remoteip = 90.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = WD2 dir = in protocol = tcp localport = 8172 remoteip = 98.88.65.237/32 enable = yes action = allow
net user WDeployAdmin pass@123456 /expires:never
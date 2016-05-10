
# Setting OS Level Firewall Rules
Write-Verbose -Message "Creating firewall configuration"
netsh advfirewall firewall add rule name = http dir = in protocol = tcp localport = 80 enable = yes action = allow
netsh advfirewall firewall add rule name = https dir = in protocol = tcp localport = 443 enable = yes action = allow
netsh advfirewall firewall add rule name = boi_VS2015_remote_debug1 dir = in protocol = tcp localport = 4020 remoteip = 70.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = boi_VS2015_remote_debug2 dir = in protocol = tcp localport = 4021 remoteip = 70.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = fc_VS2015_remote_debug1 dir = in protocol = tcp localport = 4020 remoteip = 208.186.96.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = fc_VS2015_remote_debug2 dir = in protocol = tcp localport = 4021 remoteip = 208.186.96.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = boi_VS2015_remote_debug_disc dir = in protocol = udp localport = 3702 remoteip = 70.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = fc_VS2015_remote_debug_disc dir = in protocol = udp localport = 3702 remoteip = 208.186.96.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = boi_office_rdp dir = in protocol = tcp localport = 3389 remoteip = 70.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = sac_office_rdp dir = in protocol = tcp localport = 3389 remoteip = 70.102.237.130/32 enable = yes action = allow
netsh advfirewall firewall add rule name = boi_office_deploy dir = in protocol = tcp localport = 8172 remoteip = 70.98.117.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = ftc_office_deploy dir = in protocol = tcp localport = 8172 remoteip = 208.186.96.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = ftc_office_rdp dir = in protocol = tcp localport = 3389 remoteip = 208.186.96.66/32 enable = yes action = allow
netsh advfirewall firewall add rule name = monitis_west1_ping dir = in remoteip = 104.200.152.54/32 enable = yes action = allow
netsh advfirewall firewall add rule name = monitis_west2_ping dir = in remoteip = 104.200.152.50/32 enable = yes action = allow
netsh advfirewall firewall add rule name = monitis_east2_ping dir = in remoteip = 173.192.200.100/32 enable = yes action = allow
netsh advfirewall firewall add rule name = monitis_east1_ping dir = in remoteip = 173.193.219.173/32 enable = yes action = allow
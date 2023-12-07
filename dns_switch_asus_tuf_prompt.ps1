# Displays your current DNS server
# Asks if you want to switch between $DnsTarget and DHCP DNS server

# DNS server IP you want to switch to (eg. your PiHole IP)
$DnsTarget = "192.168.1.34"

function Set-Dns {
    if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { #check if script is running as admin, if not, elevate
        $scriptBlock = { #script block to run elevated
            $interface = Get-NetAdapter | Where-Object Status -eq "Up" #get interface of status "Up"
            $index = $interface.ifIndex #get interface index value of "interface"
            $CurrentDnsServerIp = (Get-DnsClientServerAddress -InterfaceIndex $index -AddressFamily IPv4).ServerAddresses #get current DNS server IP

            Set-DnsClientServerAddress -InterfaceIndex $index -ResetServerAddresses #reset DNS server IP to DHCP
            if ($CurrentDnsServerIp -notmatch $DnsTarget) { #if your DNS server IP was different from $DnsTarget
                Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $DnsTarget #set it to $DnsTarget
            }
        }
    }
    Start-Process powershell "-encodedcommand $([Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock)))" -Verb RunAs
    Exit #close the initial powershell window
}
function Get-Dns {
    $interface = Get-NetAdapter | Where-Object Status -eq "Up" #get interface of status "Up"
    $index = $interface.ifIndex #get interface index value of "interface"
    $CurrentDnsServerIp = (Get-DnsClientServerAddress -InterfaceIndex $index -AddressFamily IPv4).ServerAddresses #get current DNS server IP

    Write-Host "Current DNS Server: "
    Write-Host $CurrentDnsServerIp
    Write-Host "Change DNS Server? (y/n)"
    $input = Read-Host
    if ($input -eq "y") {
        Set-Dns
    }
}

Get-Dns
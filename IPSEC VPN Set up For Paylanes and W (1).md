<a name="_8pxmg13xxwum"></a>IPSEC VPN Set up For Paylanes and W.U

Above diagram is tunnel functionality 

We need to connect two VPN endpoint using ipsec tunnel and share an encrypted communication between their subnets. 

**servers** 

|**VPN Server Paylanes**|||**VPN Server WU Reston**||
| :- | :- | :- | :- | :- |
|Paylanes-WU-VPN-server-01|||VA2-WU-VPN-CP21700||
|157\.230.176.74|||206\.201.226.10||
|**paylanes-qa-servers**|**Network**|||**Network**|
|paylanes-api-qa-01|68\.183.23.173||**Prod**|66\.218.162.5/32|
|paylanes-api-qa-02|161\.35.0.194||**UAT**|66\.218.162.6/32|
|paylanes-api-production-01|67\.205.162.91||**PI**|66\.218.162.7/32|
|paylanes-api-production-02|67\.207.92.12||||


**### Content**

1- Setting up the server

2- Installation

3- PSK 

4- Configuration files on both the servers 

5- Adding the Route 


**1- Setting up the server**

**- Configure the kernel to enable packet forwarding for IPv4. Edit the configuration file**

\```

nano /etc/sysctl.conf

\```

**- Add the following Lines** 

\```

net.ipv4.ip\_forward = 1

net.ipv6.conf.all.forwarding = 1

net.ipv4.conf.all.accept\_redirects = 0

net.ipv4.conf.all.send\_redirects = 0

\```

**- Save and close the file. Then, run the following command to reload the settings:**

\```

sysctl -p

\```

**- install the strongSwan IPSec daemon in your system**

\```

apt-get install strongswan libcharon-extra-plugins strongswan-pki -y

**3- PSK** 


**- Open the following file on PAYLANES VPN SERVER**

\```

vi /etc/ipsec.secrets

\```

**Edit this file differently on both VPN servers** 



\```

<paylanes-ip> <W.U ip> : PSK "your-ownsecret-text"
**



**4- Configuration files** 

**Open following File 
\```**

/etc/ipsec.conf

**```**
**Configure it using following set up** 

**```**
config setup

`        `charondebug="all"

`        `uniqueids=yes

`        `strictcrlpolicy=no

conn paylanes-to-reston

`  `keyexchange=ikev2

`  `authby=secret

`  `type=tunnel

`  `left=<Left IP>

`  `leftid=<Left ID>

`  `leftsubnet=<Left Subnet>

`  `right=<Right IP>

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

`  `ike=aes256-sha256-modp2048

`  `esp=aes256-sha256

`  `forceencaps=yes

`  `keyingtries=%forever

`  `ikelifetime=86400s

`  `lifetime=3600s

`  `dpddelay=300s

`  `dpdtimeout=3600s

`  `dpdaction=clear

`  `auto=start

conn paylanes-to-host2

`  `also=paylanes-to-reston

`  `leftsubnet=<Left Subnet>

conn paylanes-to-host7

`  `also=paylanes-to-reston

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

conn paylanes-to-host6

`  `also=paylanes-to-reston

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

conn paylanes-to-host5

`  `also=paylanes-to-reston

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

//Second Tunnel 
conn paylanes-to-chicago

`  `keyexchange=ikev2

`  `authby=secret

`  `type=tunnel

`  `left=<Left IP>

`  `leftid=<Left ID>

`  `leftsubnet=<Left Subnet>

`  `right=<Right ip Chicago>

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

`  `ike=aes256-sha256-modp2048

`  `esp=aes256-sha256

`  `forceencaps=yes

`  `keyingtries=%forever

`  `ikelifetime=86400s

`  `lifetime=3600s

`  `dpddelay=300s

`  `dpdtimeout=3600s

`  `dpdaction=clear

`  `auto=start

conn paylanes-to-host-c2

`  `also=paylanes-to-chicago

`  `leftsubnet=<ALL Left Subnet >

conn paylanes-to-host-c7

`  `also=paylanes-to-chicago

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

conn paylanes-to-host-c6

`  `also=paylanes-to-chicago

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>

conn paylanes-to-host-c5

`  `also=paylanes-to-chicago

`  `rightsubnet=<ALL Right Subnet , Prod, UAT and PI>
**

Above is the ipsec.conf file we need to edit as per our requirement 

**


**5- Adding the Route** 




**We need to add routes** 

\- for Paylanes PROD and QA api 
\- via Strongswan 
\- to connect W.U PROD, UAT and P.I in Reston and Chicago Region 

**Following Steps to Add Routes** 

1 -  Add Following rules inside VPN Server to forward incoming traffic from eth1 interface receiving input from subnets** 



sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

sudo iptables -A FORWARD -i eth1 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT

sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT

2- Add Ip route rules in Subnet for Sending the Trafiic destined for W.U subnets via VPN server** 

ip route add 66.218.162.7 via 10.136.121.40 

ip route add 66.218.162.6 via 10.136.121.40

ip route add 66.218.162.5 via 10.136.121.40
ip route add 66.218.172.7 via 10.136.121.40 

ip route add 66.218.172.6 via 10.136.121.40

ip route add 66.218.172.5 via 10.136.121.40

Add ip route add rules to all the api servers (Prod and QA) 


For testing the routes 

1- Use below command in all api servers it would **produce ip address of VPN server** 

\```
curl ipconfig.io 
\```

2- Check the reachability of W.U subnet from Api server using ping . 

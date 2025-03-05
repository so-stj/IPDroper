# IPDroper

<div id="top"></div>
<p style="display: inline">
  <!-- List of technologies used --> 
  List of technologies used:
  
<img src="https://img.shields.io/badge/Linux--FFA500.svg?logo=Linux&style=plastic">

## Table of Contents

1. [Description](#Description)
2. [Usage](#Usage)
3. [Troubleshooting](#Troubleshooting)

# Description

This bash script allows users to easily block ip address in iptables on Linux system. 

# Usage

Run the script then display menu there are allow select scripts.

1. IptablesConfiguration.sh allow to block IP address of country that specified from registry of the Number Resource Organization.

These NROs are available:

 1) APNIC - Asia-Pacific Network Information Centre

 2) RIPE-NCC - Réseaux IP Européens Network Coordination Centre

 3) ARIN - American Registry for Internet Numbers

 4) LACNIC - Latin American and Caribbean Internet Address Registry

 5) AFNIC - Association française pour le nommage Internet en coopération

User allow to select one that numbers between 1-5 of NRO.   
After that enter the country alpha2 code to block and begin the process of configuration on iptables.
When finished the configuration on iptables you need to save manually that configration because script will not iptables-save.

IPtablesRemove.sh allow to delete

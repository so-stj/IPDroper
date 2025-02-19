#########################################
#######THIS SCRIPT USE FOR PROXMOX#######
#########################################

# With apnic and arin index need to update on every months
# If you want to block IP addresses from ARIN, please delete # in begin line between 34 to 38

#/bin/bash
# Download a latest IP address list from the FTP servers of APNIC and ARIN
wget -O ip_apnic.txt https://ftp.apnic.net/stats/apnic/delegated-apnic-latest
wget -O ip_arin.txt https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest

# Delete existing rules on iptables
iptables -F REGION_BLOCK 2>/dev/null
iptables -X REGION_BLOCK 2>/dev/null

# Add the chain
iptables -N APNIC_BLOCK

# Add country code that ISO 3166-1 alpha-2 code to want block IP addresses of Asia example:("KR" "CN" "ID")
BLOCK_COUNTRY_APNIC=("CN" "KR" "SG" "TH" "HK" "AU" "ID" "TW" "PH")

# Add coutnry code that ISO 3166-1 alpha code to want block IP addresses of North America example:("US" "CA")
#BLOCK_COUNTRY_ARIN=("CA" "US")

# Block each countries IP that identified with alpha-2 code on APNIC
for COUNTRY in "${BLOCK_COUNTRY_APNIC[@]}"; do
    grep "|${COUNTRY}|" ip_apnic.txt | grep '|ipv4|' | cut -d '|' -f4,5 --output-delimiter="/" | while read line; do
        iptables -A REGION_BLOCK -s $line -j DROP
    done
done

# Block each countries IP that identified with alpha-2 code on ARIN
#for COUNTRY in "${BLOCK_COUNTRY_ARIN[@]}"; do
    #grep "|${COUNTRY}|" ip_arin.txt | grep '|ipv4|' | cut -d '|' -f4,5 --output-delimiter="/" | while read line; do
        #iptables -A REGION_BLOCK -s $line -j DROP
    #done
#done

# Appy INPUT chain
iptables -I INPUT -j REGION_BLOCK

echo "Blocked IP addresses from the specified countries from ARIN and APNIC"
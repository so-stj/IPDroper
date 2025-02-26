#!/bin/sh

# User allows to select Number Resource Organization
echo "Please select the Number Resource Organization:"
echo "1) APNIC"
echo "2) RIPE"
echo "3) ARIN"
echo "4) LACNIC"
read -p "Please enter the number (1-4): " ORG_CHOICE
echo "Please enter the Alpha-2 code (Examples: ID, JP):"
read COUNTRY

# Configure URL of Number Resource Organization
case $ORG_CHOICE in
    1)  URL='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest' ;;
    2)  URL='https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest' ;;
    3)  URL='https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest' ;;
    4)  URL='https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest' ;;
    *)  echo "invalid selector"; exit 1 ;;
esac

# Iptables will drop by identified the Alpa-2 code on registry that obtaine from Number Resource Organization (APNIC, RIPE-NCC, ARIN, LACNIC)
function drop_country_iptables(){

    echo "Getting the data: ${URL}"
    if curl -s ${URL} > /tmp/delegated-latest
    then
        echo "Settings of iptables in progress: it will take a while"
        iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
        iptables -F DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -X DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -N DROP-${COUNTRY}
        COUNT=0
        for i in $(awk -F'|' '$2~/'${COUNTRY}'/&&$3~/ipv4/{print $4","$5}' /tmp/delegated-latest)
        do
            IP_LIST_1=$(echo $i | cut -d',' -f1)
            IP_LIST_2=$(echo $i | cut -d',' -f2)
            IP_CO_LIST=$(cider_calculator $IP_LIST_1 $IP_LIST_2)

            if [ ${IP_CO_LIST} != 'null' ];then
                iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP
                echo_erase "iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP"
                echo "${IP_CO_LIST} - ${COUNTRY}" >> /var/log/blocked_ips.log
            fi

        done
        iptables -A DROP-${COUNTRY} -j RETURN
        iptables -I INPUT 1    -j DROP-${COUNTRY}
        iptables -nvxL
        rm -rf /tmp/delegated-latest
    else
        echo "Failed to get data:${URL}"
        exit 1
    fi
}

# Initialize iptables
function init_country_iptables(){

    iptables -D INPUT -j DROP-${COUNTRY}
    iptables -F DROP-${COUNTRY}
    iptables -X DROP-${COUNTRY}
    iptables -nvxL
    echo -e '\n==================================================\n'
    echo -e '\n Iptables has been initialized, becuase there was no response for 120 seconds \n'
}

# Calculate CIDR of IP address that holding
function cider_calculator(){

    local IP_ADDRESS_NUM=4294967296
    local IP_ADDRESS=$1
    local IP_NUM=$2
    local IP_CIDER='null'

    for i in $(seq 1 32)
    do
        IP_ADDRESS_NUM=$((${IP_ADDRESS_NUM}/2))
        if [ $((IP_ADDRESS_NUM/IP_NUM)) -eq 1 -a $((IP_ADDRESS_NUM%IP_NUM)) -eq 0 ]; then
            IP_CIDER=$i
            break
        fi
    done

    if [ $IP_CIDER = 'null' ];then
        echo 'null'
    else
        echo "$IP_ADDRESS/$IP_CIDER"
    fi
}

# Function that control of stnadard output
function echo_erase(){

    local STRING="$1"
    echo -n ${STRING}
    for i in $(seq 0 ${#STRING})
    do
        echo -n $'\b'
    done
}

# Run iptables and iptables going to initialize if no response on while 120 secounds after completed settings
drop_country_iptables
echo -e '\n==================================================\n'
echo -e "### Settings of iptables is complete ###\n"
echo -e 'If Iptables hasn't any problem on currently of settings, please press Ctrl + C and save iptables\n'
sleep 120
init_country_iptables

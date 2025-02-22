#!/bin/bash

echo "国コードを入力してください (例: ID, JP):"
read ${COUNTRY}

# Delete the chain on iptables
echo "Iptables chain deletion has started..."
iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
iptables -F DROP-${COUNTRY} > /dev/null 2>&1
iptables -X DROP-${COUNTRY} > /dev/null 2>&1

# Show currently iptables list
iptables -nvxL

echo "iptables chain deletion complete."

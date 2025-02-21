#!/bin/bash

# Delete the chain on iptables
echo "Iptables chain deletion has started..."

iptables -D INPUT -j DROP-BLOCKED-IP > /dev/null 2>&1
iptables -F DROP-BLOCKED-IP > /dev/null 2>&1
iptables -X DROP-BLOCKED-IP > /dev/null 2>&1

# Show currently iptables list
iptables -nvxL

echo "iptables chain deletion complete."
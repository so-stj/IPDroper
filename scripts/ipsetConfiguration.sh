#!/bin/bash

# IPDroper - ipset-based country IP blocking script
# This script uses ipset for better performance and easier management

# Function to validate country code
validate_country_code() {
    local valid_codes=("AD" "AE" "AF" "AG" "AI" "AL" "AM" "AO" "AR" "AS" "AT" "AU" "AW" "AX" "AZ"
                       "BA" "BB" "BD" "BE" "BF" "BG" "BH" "BI" "BJ" "BL" "BM" "BN" "BO" "BQ" "BR"
                       "BS" "BT" "BV" "BW" "BY" "BZ" "CA" "CC" "CD" "CF" "CG" "CH" "CI" "CK" "CL"
                       "CM" "CN" "CO" "CR" "CU" "CV" "CW" "CX" "CY" "CZ" "DE" "DJ" "DK" "DM" "DO"
                       "DZ" "EC" "EE" "EG" "EH" "ER" "ES" "ET" "FI" "FJ" "FM" "FO" "FR" "GA" "GB"
                       "GD" "GE" "GF" "GG" "GH" "GI" "GL" "GM" "GN" "GP" "GQ" "GR" "GT" "GU" "GW"
                       "GY" "HK" "HM" "HN" "HR" "HT" "HU" "ID" "IE" "IL" "IM" "IN" "IO" "IQ" "IR"
                       "IS" "IT" "JE" "JM" "JO" "JP" "KE" "KG" "KH" "KI" "KM" "KN" "KP" "KR" "KW"
                       "KY" "KZ" "LA" "LB" "LC" "LI" "LK" "LR" "LS" "LT" "LU" "LV" "LY" "MA" "MC"
                       "MD" "ME" "MF" "MG" "MH" "MK" "ML" "MM" "MN" "MO" "MP" "MQ" "MR" "MS" "MT"
                       "MU" "MV" "MW" "MX" "MY" "MZ" "NA" "NC" "NE" "NF" "NG" "NI" "NL" "NO" "NP"
                       "NR" "NU" "NZ" "OM" "PA" "PE" "PF" "PG" "PH" "PK" "PL" "PM" "PN" "PR" "PT"
                       "PW" "PY" "QA" "RE" "RO" "RS" "RU" "RW" "SA" "SB" "SC" "SD" "SE" "SG" "SH"
                       "SI" "SJ" "SK" "SL" "SM" "SN" "SO" "SR" "SS" "ST" "SV" "SX" "SY" "SZ" "TC"
                       "TD" "TF" "TG" "TH" "TJ" "TK" "TL" "TM" "TN" "TO" "TR" "TT" "TV" "TZ" "UA"
                       "UG" "UM" "US" "UY" "UZ" "VA" "VC" "VE" "VG" "VI" "VN" "VU" "WF" "WS" "YE"
                       "YT" "ZA" "ZM" "ZW")
    
    if [[ ! " ${valid_codes[@]} " =~ " ${COUNTRY} " ]]; then
        echo "ERROR: Invalid country code: ${COUNTRY}"
        echo "Please enter a valid ISO 3166-1 alpha-2 country code."
        exit 1
    fi
}

# Function to calculate CIDR from IP range
calculate_cidr() {
    local start_ip=$1
    local num_ips=$2
    
    # Convert IP to decimal
    local ip_decimal=$(echo $start_ip | awk -F. '{print $1*256^3 + $2*256^2 + $3*256 + $4}')
    local end_decimal=$((ip_decimal + num_ips - 1))
    
    # Calculate CIDR
    local cidr=32
    local temp=$num_ips
    
    while [ $temp -gt 1 ]; do
        temp=$((temp / 2))
        cidr=$((cidr - 1))
    done
    
    # Validate CIDR calculation
    local max_ips=$((2 ** (32 - cidr)))
    if [ $num_ips -le $max_ips ]; then
        echo "${start_ip}/${cidr}"
    else
        # If CIDR calculation fails, return null
        echo "null"
    fi
}

# Function to check if ipset is available
check_ipset() {
    if ! command -v ipset &> /dev/null; then
        echo "ERROR: ipset is not installed."
        echo "Installation instructions:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        exit 1
    fi
    
    # Check if ipset module is loaded
    if ! lsmod | grep -q "ip_set"; then
        echo "Loading ipset kernel modules..."
        modprobe ip_set
        modprobe ip_set_hash_net
    fi
}

# Function to create ipset and add IP ranges
create_country_ipset() {
    local country=$1
    local url=$2
    local set_name="DROP-${country}"
    
    # Read action configuration
    local action="DROP"  # Default action
    local config_file="/etc/ipdroper/action_config.conf"
    if [ -f "$config_file" ]; then
        local config_action=$(cat "$config_file" 2>/dev/null | grep "^ACTION=" | cut -d'=' -f2)
        if [ -n "$config_action" ]; then
            action="$config_action"
        fi
    fi
    
    echo "Blocking IP ranges for ${country}..."
    echo "Downloading RIR data from: ${url}"
    echo "Action: ${action}"
    
    # Download RIR data
    if ! curl -s "${url}" > /tmp/delegated-latest; then
        echo "ERROR: Failed to download RIR data from: ${url}"
        exit 1
    fi
    
    # Remove existing ipset if it exists
    if ipset list -name | grep -q "^${set_name}$"; then
        echo "Removing existing ipset: ${set_name}"
        ipset destroy "${set_name}"
    fi
    
    # Create new ipset
    echo "Creating ipset: ${set_name}"
    ipset create "${set_name}" hash:net family inet hashsize 1024 maxelem 65536
    
    # Process IP ranges
    echo "Processing IP ranges..."
    local count=0
    local valid_ranges=0
    
    while IFS='|' read -r registry cc type start_ip num_ips date status; do
        if [[ "$cc" == "$country" && "$type" == "ipv4" ]]; then
            local cidr=$(calculate_cidr "$start_ip" "$num_ips")
            if [[ "$cidr" != "null" ]]; then
                ipset add "${set_name}" "$cidr" 2>/dev/null
                if [ $? -eq 0 ]; then
                    valid_ranges=$((valid_ranges + 1))
                    echo -n "OK $cidr "
                fi
                count=$((count + 1))
                
                # Progress indicator
                if [ $((count % 100)) -eq 0 ]; then
                    echo "($count ranges processed)"
                fi
            fi
        fi
    done < /tmp/delegated-latest
    
    echo ""
    echo "Processing complete: ${valid_ranges} valid IP ranges added to ${set_name}"
    
    # Clean up temporary file
    rm -f /tmp/delegated-latest
    
    # Show ipset statistics
    echo "ipset statistics:"
    ipset list "${set_name}" | head -20
    echo "..."
    
    # Create iptables rule based on selected action
    local iptables_action=""
    local iptables_options=""
    
    case "$action" in
        "REJECT")
            iptables_action="REJECT"
            iptables_options="--reject-with icmp-host-unreachable"
            ;;
        *)
            iptables_action="DROP"
            iptables_options=""
            ;;
    esac
    
    # Create iptables rule if it doesn't exist
    if ! iptables -C INPUT -m set --match-set "${set_name}" src -j "$iptables_action" $iptables_options 2>/dev/null; then
        echo "Creating iptables rule with ${iptables_action} action..."
        if [ -n "$iptables_options" ]; then
            iptables -A INPUT -m set --match-set "${set_name}" src -j "$iptables_action" $iptables_options
        else
            iptables -A INPUT -m set --match-set "${set_name}" src -j "$iptables_action"
        fi
        echo "iptables rule created successfully with ${iptables_action} action"
    else
        echo "iptables rule already exists with ${iptables_action} action"
    fi
}

# Main execution
main() {
    echo "IPDroper - ipset version"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # User input
    echo "Please select Regional Internet Registry:"
    echo "1) APNIC (Asia Pacific)"
    echo "2) RIPE-NCC (Europe)"
    echo "3) ARIN (North America)"
    echo "4) LACNIC (Latin America)"
    echo "5) AFRINIC (Africa)"
    
    read -p "Enter number (1-5): " org_choice
    
    case $org_choice in
        1) url="https://ftp.apnic.net/stats/apnic/delegated-apnic-latest" ;;
        2) url="https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest" ;;
        3) url="https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" ;;
        4) url="https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest" ;;
        5) url="https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest" ;;
        *) echo "ERROR: Invalid selection"; exit 1 ;;
    esac
    
    read -p "Enter country code (e.g., CN, RU, JP): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
    
    # Validate country code
    validate_country_code
    
    echo ""
    echo "Configuration confirmation:"
    echo "  Country: ${COUNTRY}"
    echo "  RIR: $url"
    echo ""
    
    read -p "Continue? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Operation cancelled"
        exit 0
    fi
    
    # Create ipset and block country
    create_country_ipset "$COUNTRY" "$url"
    
    echo ""
    echo "Blocking of ${COUNTRY} completed successfully!"
    echo "Current iptables rules:"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|${COUNTRY})"
    
    echo ""
    echo "Tips:"
    echo "  - Remove block: sudo ./scripts/ipsetRemove.sh"
    echo "  - Check status: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

#!/bin/bash

# IPDroper - ipset removal script
# This script removes country IP blocks created with ipset

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
        echo "❌ Invalid country code: ${COUNTRY}"
        echo "Please enter a valid ISO 3166-1 alpha-2 country code."
        exit 1
    fi
}

# Function to check if ipset is available
check_ipset() {
    if ! command -v ipset &> /dev/null; then
        echo "❌ ipset is not installed."
        echo "Installation instructions:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        exit 1
    fi
}

# Function to remove country ipset
remove_country_ipset() {
    local country=$1
    local set_name="DROP-${country}"
    
    echo "🗑️ Removing IP block for ${country}..."
    
    # Check if ipset exists
    if ! ipset list -name | grep -q "^${set_name}$"; then
        echo "ℹ️ ipset ${set_name} does not exist"
        return 0
    fi
    
    # Remove iptables rule if it exists
    if iptables -C INPUT -m set --match-set "${set_name}" src -j DROP 2>/dev/null; then
        echo "🔓 Removing iptables rule..."
        iptables -D INPUT -m set --match-set "${set_name}" src -j DROP
        echo "✅ iptables rule removed successfully"
    else
        echo "ℹ️ iptables rule does not exist"
    fi
    
    # Show ipset contents before removal
    echo "📊 ipset contents before removal:"
    ipset list "${set_name}" | head -10
    echo "..."
    
    # Get ipset statistics
    local entry_count=$(ipset list "${set_name}" | grep -c "^[0-9]")
    echo "📈 Entry count: ${entry_count}"
    
    # Remove ipset
    echo "🗑️ Removing ipset: ${set_name}"
    ipset destroy "${set_name}"
    
    if [ $? -eq 0 ]; then
        echo "✅ ipset ${set_name} removed successfully"
    else
        echo "❌ Failed to remove ipset"
        exit 1
    fi
}

# Function to list all available ipsets
list_available_ipsets() {
    echo "📋 Available ipset list:"
    echo "================================"
    
    local ipset_count=0
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
        echo "  ${country_code}: ${set_name} (${entry_count} entries)"
        ipset_count=$((ipset_count + 1))
    done
    
    if [ $ipset_count -eq 0 ]; then
        echo "  ℹ️ No countries are blocked"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "🗑️ IPDroper - ipset removal tool"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # Show available ipsets
    list_available_ipsets
    
    # User input
    read -p "Enter country code to remove (e.g., CN, RU, JP): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
    
    # Validate country code
    validate_country_code
    
    echo ""
    echo "🔍 Removal confirmation:"
    echo "  Country: ${COUNTRY}"
    echo "  ipset: DROP-${COUNTRY}"
    echo ""
    
    read -p "Are you sure you want to remove the block for ${COUNTRY}? (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Operation cancelled"
        exit 0
    fi
    
    # Remove country ipset
    remove_country_ipset "$COUNTRY"
    
    echo ""
    echo "🎉 Block removal for ${COUNTRY} completed successfully!"
    echo "📊 Current iptables rules:"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|${COUNTRY})" || echo "  ℹ️ No related rules found"
    
    echo ""
    echo "💡 Tips:"
    echo "  - Block new country: sudo ./scripts/ipsetConfiguration.sh"
    echo "  - Check status: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

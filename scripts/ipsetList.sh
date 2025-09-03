#!/bin/bash

# IPDroper - ipset status display script
# This script shows the current status of ipset-based country blocks

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

# Function to display ipset statistics
display_ipset_stats() {
    echo "📊 ipset statistics"
    echo "================================"
    
    local total_entries=0
    local total_ipsets=0
    
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
        local memory_usage=$(ipset list "$set_name" 2>/dev/null | grep "Size in memory" | awk '{print $4}' || echo "N/A")
        
        echo "  🌍 ${country_code}:"
        echo "    ipset: ${set_name}"
        echo "    Entry count: ${entry_count}"
        echo "    Memory usage: ${memory_usage}"
        echo ""
        
        total_entries=$((total_entries + entry_count))
        total_ipsets=$((total_ipsets + 1))
    done
    
    if [ $total_ipsets -eq 0 ]; then
        echo "  ℹ️ No countries are blocked"
    else
        echo "📈 Summary:"
        echo "  Blocked countries: ${total_ipsets}"
        echo "  Total entries: ${total_entries}"
    fi
    
    echo ""
}

# Function to display iptables rules
display_iptables_rules() {
    echo "🔒 iptables rules"
    echo "================================"
    
    # Show INPUT chain rules related to ipset
    echo "INPUT chain (ipset related):"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|ipset)" || echo "  ℹ️ No ipset-related rules found"
    
    echo ""
    
    # Show all chains
    echo "All chains:"
    iptables -L -n --line-numbers | grep -E "^Chain|DROP-" || echo "  ℹ️ No chains found"
    
    echo ""
}

# Function to display system information
display_system_info() {
    echo "💻 System information"
    echo "================================"
    
    # Kernel version
    echo "Kernel version: $(uname -r)"
    
    # iptables version
    local iptables_version=$(iptables --version 2>/dev/null | head -1 || echo "N/A")
    echo "iptables version: ${iptables_version}"
    
    # ipset version
    local ipset_version=$(ipset --version 2>/dev/null | head -1 || echo "N/A")
    echo "ipset version: ${ipset_version}"
    
    # Loaded ipset modules
    echo "Loaded ipset modules:"
    lsmod | grep "ip_set" || echo "  ℹ️ No ipset modules loaded"
    
    echo ""
}

# Function to display detailed ipset information
display_detailed_ipset() {
    local set_name=$1
    
    if [ -z "$set_name" ]; then
        echo "Enter ipset name to display details:"
        read -p "ipset name (e.g., DROP-CN): " set_name
    fi
    
    if [ -z "$set_name" ]; then
        echo "❌ No ipset name specified"
        return 1
    fi
    
    if ! ipset list -name | grep -q "^${set_name}$"; then
        echo "❌ ipset ${set_name} does not exist"
        return 1
    fi
    
    echo "🔍 Detailed information for ${set_name}"
    echo "================================"
    
    # Show full ipset contents
    ipset list "${set_name}"
    
    echo ""
    
    # Show iptables rules using this ipset
    echo "iptables rules using this ipset:"
    iptables -L -n | grep -E "${set_name}" || echo "  ℹ️ No related rules found"
}

# Function to show performance metrics
display_performance_metrics() {
    echo "⚡ Performance metrics"
    echo "================================"
    
    # Show iptables statistics
    echo "iptables statistics:"
    iptables -L INPUT -v -n | grep -E "(DROP|ipset)" || echo "  ℹ️ No statistics available"
    
    echo ""
    
    # Show ipset performance info
    echo "ipset performance information:"
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        echo "  ${country_code}:"
        ipset list "${set_name}" | grep -E "(Size in memory|References|Number of entries)" | sed 's/^/    /'
    done
    
    echo ""
}

# Main execution
main() {
    echo "📋 IPDroper - ipset status display tool"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # Display menu
    echo "Select display option:"
    echo "1) Overview display (recommended)"
    echo "2) Detailed display"
    echo "3) Specific ipset details"
    echo "4) Performance metrics"
    echo "5) All information"
    
    read -p "Enter number (1-5): " choice
    
    case $choice in
        1)
            echo ""
            display_ipset_stats
            display_iptables_rules
            ;;
        2)
            echo ""
            display_ipset_stats
            display_iptables_rules
            display_system_info
            ;;
        3)
            echo ""
            display_detailed_ipset
            ;;
        4)
            echo ""
            display_performance_metrics
            ;;
        5)
            echo ""
            display_ipset_stats
            display_iptables_rules
            display_system_info
            display_performance_metrics
            ;;
        *)
            echo "❌ Invalid selection"
            exit 1
            ;;
    esac
    
    echo ""
    echo "💡 Tips:"
    echo "  - Block new country: sudo ./scripts/ipsetConfiguration.sh"
    echo "  - Remove block: sudo ./scripts/ipsetRemove.sh"
    echo "  - Run this tool again: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

#!/bin/bash

# IPDroper - ipset version main menu
# This is the main menu script for ipset-based country IP blocking

# Script list and descriptions
declare -a script_list=("ipsetConfiguration.sh" "ipsetRemove.sh" "ipsetList.sh")
declare -a script_descriptions=("Block country (ipset version)" "Remove block (ipset version)" "Show current status (ipset version)")

# Scripts directory
script_dir="./scripts"

# Validate scripts directory
if [ ! -d "$script_dir" ]; then
    echo "ERROR: Script directory not found: $script_dir"
    exit 1
fi

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: This script requires root privileges"
        echo "Please use: sudo ./setup_ipset.sh"
        exit 1
    fi
    
    # Check if ipset is available
    if ! command -v ipset &> /dev/null; then
        echo "ERROR: ipset is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        echo "  Arch Linux: sudo pacman -S ipset"
        echo ""
        echo "Please install ipset and run this script again"
        exit 1
    fi
    
    # Check if iptables is available
    if ! command -v iptables &> /dev/null; then
        echo "ERROR: iptables is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  Ubuntu/Debian: sudo apt-get install iptables"
        echo "  CentOS/RHEL: sudo yum install iptables"
        echo "  Arch Linux: sudo pacman -S iptables"
        echo ""
        echo "Please install iptables and run this script again"
        exit 1
    fi
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "ERROR: curl is not installed"
        echo ""
        echo "Installation instructions:"
        echo "  Ubuntu/Debian: sudo apt-get install curl"
        echo "  CentOS/RHEL: sudo yum install curl"
        echo "  Arch Linux: sudo pacman -S curl"
        echo ""
        echo "Please install curl and run this script again"
        exit 1
    fi
    
    # Load ipset modules if needed
    if ! lsmod | grep -q "ip_set"; then
        echo "Loading ipset kernel modules..."
        modprobe ip_set
        modprobe ip_set_hash_net
        
        if ! lsmod | grep -q "ip_set"; then
            echo "ERROR: Failed to load ipset kernel modules"
            echo "Please check if your kernel supports ipset"
            exit 1
        fi
    fi
    
    echo "Prerequisites check completed"
    echo ""
}

# Function to show current status
show_current_status() {
    echo "Current status"
    echo "================================"
    
    # Show blocked countries
    local blocked_countries=$(ipset list -name 2>/dev/null | grep "^DROP-" | wc -l)
    if [ "$blocked_countries" -gt 0 ]; then
        echo "Blocked countries: ${blocked_countries}"
        for set_name in $(ipset list -name 2>/dev/null | grep "^DROP-"); do
            local country_code=$(echo "$set_name" | sed 's/^DROP-//')
            local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
            echo "  ${country_code}: ${entry_count} IP ranges"
        done
    else
        echo "No countries are blocked"
    fi
    
    echo ""
    
    # Show iptables rules
    local ipset_rules=$(iptables -L INPUT -n 2>/dev/null | grep -c "ipset" || echo "0")
    echo "ipset-related iptables rules: ${ipset_rules}"
    
    echo ""
}

# Function to show menu
show_menu() {
    echo "IPDroper - ipset version"
    echo "================================"
    echo "Country-based IP blocking tool (high-performance ipset version)"
    echo ""
    
    show_current_status
    
    echo "Available scripts:"
    local index=1
    for script in "${script_list[@]}"; do
        local description="${script_descriptions[$((index-1))]}"
        echo "$index) $script - $description"
        index=$((index + 1))
    done
    
    echo ""
    echo "Tips:"
    echo "  - For first-time use, start with option 1"
    echo "  - Check current status with option 3"
    echo "  - Remove blocks with option 2"
    echo ""
}

# Function to run selected script
run_script() {
    local selected=$1
    local script_file="$script_dir/$selected"
    
    # Check if script exists
    if [ ! -f "$script_file" ]; then
        echo "ERROR: Script not found: $script_file"
        return 1
    fi
    
    # Make script executable
    chmod +x "$script_file"
    
    # Show script description
    local selected_index=$(echo "${script_list[@]}" | tr ' ' '\n' | grep -n "$selected" | cut -d ':' -f 1)
    local description="${script_descriptions[$((selected_index-1))]}"
    
    echo ""
    echo "Selected script: $selected"
    echo "Description: $description"
    echo ""
    
    read -p "Do you want to run this script? (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo "Running script..."
        echo ""
        
        # Run script
        bash "$script_file"
        
        echo ""
        echo "Script execution completed"
    else
        echo "Script execution cancelled"
    fi
}

# Function to handle user selection
handle_selection() {
    echo "Please select:"
    PS3="Enter number: "
    
    select selected in "${script_list[@]}"; do
        if [ -z "$selected" ]; then
            echo "ERROR: Invalid selection"
            echo "Please enter a number between 1-${#script_list[@]}"
        else
            run_script "$selected"
            break
        fi
    done
}

# Function to show help
show_help() {
    echo "IPDroper - ipset version help"
    echo "================================"
    echo ""
    echo "Country-based IP blocking tool"
    echo "This tool uses ipset to efficiently block IP addresses from"
    echo "specific countries. Compared to traditional iptables method,"
    echo "it achieves significant performance improvements and simplified management."
    echo ""
    echo "Main features:"
    echo "  - Fast IP lookup (hash table based)"
    echo "  - Memory efficient management"
    echo "  - Single iptables rule for thousands of IP ranges"
    echo "  - Easy add/remove/update operations"
    echo ""
    echo "Prerequisites:"
    echo "  - Linux kernel (ipset support)"
    echo "  - ipset package"
    echo "  - iptables package"
    echo "  - curl package"
    echo "  - Root privileges"
    echo ""
    echo "Usage:"
    echo "  1. Block country: Option 1"
    echo "  2. Remove block: Option 2"
    echo "  3. Check status: Option 3"
    echo ""
    echo "Performance comparison:"
    echo "  | Item | iptables method | ipset method |"
    echo "  |------|-----------------|--------------|"
    echo "  | Rule count | Thousands~Tens of thousands | 1 (+IPs in ipset) |"
    echo "  | Lookup speed | Linear search | Hash search |"
    echo "  | Memory usage | High | Low |"
    echo "  | Update speed | Slow | Fast |"
    echo ""
}

# Main execution
main() {
    # Check if help is requested
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Show menu
    show_menu
    
    # Handle user selection
    handle_selection
    
    echo ""
    echo "Exiting IPDroper - ipset version"
    echo "Thank you for using our tool!"
}

# Run main function
main "$@"

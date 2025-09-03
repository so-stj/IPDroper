#!/bin/bash

# IPDroper - ipset action selection script
# This script allows users to select between DROP and REJECT actions

# Configuration file for storing action preference
CONFIG_FILE="/etc/ipdroper/action_config.conf"
CONFIG_DIR="/etc/ipdroper"

# Function to check prerequisites
check_prerequisites() {
    if [ "$EUID" -ne 0 ]; then
        echo "ERROR: This script requires root privileges"
        echo "Please use: sudo ./ipsetActionSelect.sh"
        exit 1
    fi
    
    # Create config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        chmod 755 "$CONFIG_DIR"
    fi
}

# Function to show current action
show_current_action() {
    echo "Current action configuration:"
    echo "================================"
    
    if [ -f "$CONFIG_FILE" ]; then
        local current_action=$(cat "$CONFIG_FILE" 2>/dev/null | grep "^ACTION=" | cut -d'=' -f2)
        if [ -n "$current_action" ]; then
            echo "Current action: $current_action"
        else
            echo "Current action: DROP (default)"
        fi
    else
        echo "Current action: DROP (default)"
    fi
    
    echo ""
    
    # Show current iptables rules
    echo "Current ipset-related iptables rules:"
    echo "----------------------------------------"
    local ipset_rules=$(iptables -L INPUT -n 2>/dev/null | grep -E "(DROP|REJECT)" | grep "ipset" || echo "No ipset rules found")
    if [ "$ipset_rules" != "No ipset rules found" ]; then
        echo "$ipset_rules"
    else
        echo "No ipset rules found"
    fi
    
    echo ""
}

# Function to select action
select_action() {
    echo "Action Selection"
    echo "================================"
    echo "Choose the action for blocked IP addresses:"
    echo ""
    echo "1) DROP - Silently drop packets (default)"
    echo "   - Packets are dropped without any response"
    echo "   - More stealthy, no feedback to sender"
    echo "   - Recommended for security purposes"
    echo ""
    echo "2) REJECT - Reject packets with error message"
    echo "   - Packets are rejected with ICMP error"
    echo "   - Sender receives immediate feedback"
    echo "   - Useful for debugging and testing"
    echo ""
    echo "3) Show current configuration"
    echo "4) Exit"
    echo ""
}

# Function to apply DROP action
apply_drop_action() {
    echo "Applying DROP action..."
    
    # Save configuration
    echo "ACTION=DROP" > "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    
    # Update existing iptables rules
    local updated_rules=0
    
    # Find all ipset-related REJECT rules and change them to DROP
    while IFS= read -r line; do
        if [[ "$line" =~ ipset.*REJECT ]]; then
            local rule_number=$(echo "$line" | awk '{print $1}' | tr -d '[:alpha:]')
            local match_set=$(echo "$line" | grep -o "match-set [^ ]*" | awk '{print $2}')
            
            if [ -n "$rule_number" ] && [ -n "$match_set" ]; then
                echo "Updating rule $rule_number for ipset $match_set..."
                iptables -D INPUT "$rule_number" 2>/dev/null
                iptables -I INPUT "$rule_number" -m set --match-set "$match_set" src -j DROP
                updated_rules=$((updated_rules + 1))
            fi
        fi
    done < <(iptables -L INPUT -n --line-numbers | grep -E "ipset.*REJECT")
    
    echo "Updated $updated_rules rules to use DROP action"
    echo "Configuration saved: $CONFIG_FILE"
}

# Function to apply REJECT action
apply_reject_action() {
    echo "Applying REJECT action..."
    
    # Save configuration
    echo "ACTION=REJECT" > "$CONFIG_FILE"
    chmod 644 "$CONFIG_FILE"
    
    # Update existing iptables rules
    local updated_rules=0
    
    # Find all ipset-related DROP rules and change them to REJECT
    while IFS= read -r line; do
        if [[ "$line" =~ ipset.*DROP ]]; then
            local rule_number=$(echo "$line" | awk '{print $1}' | tr -d '[:alpha:]')
            local match_set=$(echo "$line" | grep -o "match-set [^ ]*" | awk '{print $2}')
            
            if [ -n "$rule_number" ] && [ -n "$match_set" ]; then
                echo "Updating rule $rule_number for ipset $match_set..."
                iptables -D INPUT "$rule_number" 2>/dev/null
                iptables -I INPUT "$rule_number" -m set --match-set "$match_set" src -j REJECT --reject-with icmp-host-unreachable
                updated_rules=$((updated_rules + 1))
            fi
        fi
    done < <(iptables -L INPUT -n --line-numbers | grep -E "ipset.*DROP")
    
    echo "Updated $updated_rules rules to use REJECT action"
    echo "Configuration saved: $CONFIG_FILE"
}

# Function to handle user selection
handle_selection() {
    while true; do
        select_action
        read -p "Enter your choice (1-4): " choice
        
        case $choice in
            1)
                apply_drop_action
                break
                ;;
            2)
                apply_reject_action
                break
                ;;
            3)
                show_current_action
                read -p "Press Enter to continue..."
                ;;
            4)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter a number between 1-4."
                echo ""
                ;;
        esac
    done
}

# Function to show help
show_help() {
    echo "IPDroper - Action Selection Help"
    echo "================================"
    echo ""
    echo "This script allows you to choose between DROP and REJECT actions"
    echo "for blocked IP addresses in your ipset configuration."
    echo ""
    echo "Actions:"
    echo "  DROP   - Silently drop packets (stealthy, no feedback)"
    echo "  REJECT - Reject packets with ICMP error (immediate feedback)"
    echo ""
    echo "Usage:"
    echo "  sudo ./ipsetActionSelect.sh"
    echo ""
    echo "Configuration:"
    echo "  - Settings are saved to: $CONFIG_FILE"
    echo "  - Changes apply to all existing ipset rules"
    echo "  - New rules will use the selected action"
    echo ""
}

# Main execution
main() {
    # Check if help is requested
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    echo "IPDroper - Action Selection"
    echo "================================"
    
    # Check prerequisites
    check_prerequisites
    
    # Show current status
    show_current_action
    
    # Handle user selection
    handle_selection
    
    echo ""
    echo "Action selection completed!"
    echo "Current configuration:"
    if [ -f "$CONFIG_FILE" ]; then
        cat "$CONFIG_FILE"
    else
        echo "ACTION=DROP (default)"
    fi
    
    echo ""
    echo "Note: New ipset rules will use the selected action automatically."
    echo "You can run this script again anytime to change the action."
}

# Run main function
main "$@"

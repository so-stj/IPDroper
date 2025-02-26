#!/bin/bash

# Menu tables and description
declare -a script_list=("iptablesConfigration.sh" "iptablesRemove.sh" "iptablesList.sh")
declare -a script_descriptions=("Add drop script" "Delete drop chein script" " Show current iptables script")

# Scripts that stored in directory
script_dir="./scripts"

# Validate the scripts that stored in directory
if [ ! -d "$script_dir" ]; then
    echo "The specified directory does not exist: $script_dir"
    exit 1
fi

# Show menu
echo "Please select scrips to run:"
index=1
for script in "${script_list[@]}"; do
    description="${script_descriptions[$((index-1))]}"
    echo "$index) $script ($description)"
    index=$((index + 1))
done

# Allow user to select menu
PS3="Select number: "
select selected in "${script_list[@]}"; do
    if [ -z "$selected" ]; then
        echo "Invlid select"
    else
        # Get the file pass that selected scripts
        if [[ "$selected" == "view_iptables.sh" ]]; then
            # Show currently settings of iptables
            echo "Show current iptables..."
            sudo iptables -L
            break
        fi

        script_file="$script_dir/$selected"
        
        # Check the script that existing or not
        if [ ! -f "$script_file" ]; then
            echo "The specified script does not found: $script_file"
            break
        fi
        
        # Show description thier scripts
        selected_index=$(echo "${script_list[@]}" | tr ' ' '\n' | grep -n "$selected" | cut -d ':' -f 1)
        echo "Selected script: $selected"
        echo "Description: ${script_descriptions[$((selected_index-1))]}"
        echo "Do you want to run this script? (y/n)"
        
        # Require to user
        read confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            # Run script
            bash "$script_file"
            echo "$selected script has been executed. "
        else
            echo "$selected was not executed. "
        fi
        break
    fi
done

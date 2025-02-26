#!/bin/bash

# Menu tables and description
declare -a script_list=("iptablesConfigration.sh" "iptablesRemove.sh" "iptablesList.sh")
declare -a script_descriptions=("iptables 設定を追加するスクリプト" "iptables 設定を削除するスクリプト" "現在の iptables 設定を表示")

# Scripts that stored in directory
script_dir="./scripts"

# Validate the scripts that stored in directory
if [ ! -d "$script_dir" ]; then
    echo "指定したディレクトリが存在しません: $script_dir"
    exit 1
fi

# Show menu
echo "実行したいスクリプトを選んでください:"
index=1
for script in "${script_list[@]}"; do
    description="${script_descriptions[$((index-1))]}"
    echo "$index) $script ($description)"
    index=$((index + 1))
done

# Allow user to select menu
PS3="選択してください (番号を入力): "
select selected in "${script_list[@]}"; do
    if [ -z "$selected" ]; then
        echo "無効な選択です。"
    else
        # Get the file pass that selected scripts
        if [[ "$selected" == "view_iptables.sh" ]]; then
            # Show currently settings of iptables
            echo "現在の iptables 設定を表示します..."
            sudo iptables -L
            break
        fi

        script_file="$script_dir/$selected"
        
        # Check the script that existing or not
        if [ ! -f "$script_file" ]; then
            echo "指定したスクリプトが見つかりません: $script_file"
            break
        fi
        
        # Show description thier scripts
        selected_index=$(echo "${script_list[@]}" | tr ' ' '\n' | grep -n "$selected" | cut -d ':' -f 1)
        echo "選択したスクリプト: $selected"
        echo "説明: ${script_descriptions[$((selected_index-1))]}"
        echo "このスクリプトを実行しますか？ (y/n)"
        
        # Require to user
        read confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            # Run script
            bash "$script_file"
            echo "$selected が実行されました。"
        else
            echo "$selected は実行されませんでした。"
        fi
        break
    fi
done

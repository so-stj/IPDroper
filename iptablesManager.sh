#!/bin/bash

# メニュー項目とその説明 114514
declare -a script_list=("setup_4.sh" "block_remover.sh" "view_iptables.sh")
declare -a script_descriptions=("iptables 設定を追加するスクリプト" "iptables 設定を削除するスクリプト" "現在の iptables 設定を表示")

# スクリプトが格納されているディレクトリ
script_dir="./scripts"

# スクリプトが格納されているディレクトリが存在するか確認
if [ ! -d "$script_dir" ]; then
    echo "指定したディレクトリが存在しません: $script_dir"
    exit 1
fi

# メニュー表示
echo "実行したいスクリプトを選んでください:"
index=1
for script in "${script_list[@]}"; do
    description="${script_descriptions[$((index-1))]}"
    echo "$index) $script ($description)"
    index=$((index + 1))
done

# ユーザーに選択させる
PS3="選択してください (番号を入力): "
select selected in "${script_list[@]}"; do
    if [ -z "$selected" ]; then
        echo "無効な選択です。"
    else
        # 選ばれたスクリプトのファイルパスを取得
        if [[ "$selected" == "view_iptables.sh" ]]; then
            # iptables の現在のルールを表示する
            echo "現在の iptables 設定を表示します..."
            sudo iptables -L
            break
        fi

        script_file="$script_dir/$selected"
        
        # スクリプトが存在するか確認
        if [ ! -f "$script_file" ]; then
            echo "指定したスクリプトが見つかりません: $script_file"
            break
        fi
        
        # スクリプトの説明を表示
        selected_index=$(echo "${script_list[@]}" | tr ' ' '\n' | grep -n "$selected" | cut -d ':' -f 1)
        echo "選択したスクリプト: $selected"
        echo "説明: ${script_descriptions[$((selected_index-1))]}"
        echo "このスクリプトを実行しますか？ (y/n)"
        
        # ユーザーに確認を求める
        read confirm
        if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
            # スクリプト実行
            bash "$script_file"
            echo "$selected が実行されました。"
        else
            echo "$selected は実行されませんでした。"
        fi
        break
    fi
done

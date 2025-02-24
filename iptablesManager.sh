#!/bin/bash

# メニュー項目とその説明
declare -a script_list=("setup_4.sh" "block_remover.sh")
declare -a script_descriptions=("iptables 設定を追加するスクリプト" "iptables 設定を削除するスクリプト")

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
このスクリプトの動作:
メニューの表示:

setup_4.sh と block_remover.sh の2つのスクリプトに対して説明文を付けて、選択肢として表示します。
例えば、setup_4.sh は「iptables 設定を追加するスクリプト」、block_remover.sh は「iptables 設定を削除するスクリプト」といった具合です。
選択肢:

ユーザーは番号を入力してスクリプトを選びます。
スクリプトを選ぶと、説明が表示され、「このスクリプトを実行しますか？」と確認が求められます。
確認:

ユーザーが y または Y を入力すると、選択したスクリプトが実行されます。
他のキーを入力すると、スクリプトは実行されません。
例:
makefile
コピーする
編集する
実行したいスクリプトを選んでください:
1) setup_4.sh (iptables 設定を追加するスクリプト)
2) block_remover.sh (iptables 設定を削除するスクリプト)
選択してください (番号を入力): 1
選択したスクリプト: setup_4.sh
説明: iptables 設定を追加するスクリプト
このスクリプトを実行しますか？ (y/n)
ユーザーが y を入力すると、setup_4.sh が実行されます。

注意点:
スクリプトは、指定したディレクトリ（この場合は ./scripts）に存在する必要があります。
実行するスクリプトに適切な実行権限が必要です（chmod +x setup_4.sh などで設定）。
これで、インストーラのような選択画面を作り、オプションに説明を追加した形で iptables 設定を管理できるようになります！







あなた:
iptablesを見れるようにしてほしい
ChatGPT:
iptables の設定を確認できるようにするため、選択メニューに「現在の iptables のルールを表示する」オプションを追加することができます。これにより、ユーザーは現在の iptables の設定を確認した後、設定を追加したり削除したりできるようになります。

以下はその改良版です：

bash
コピーする
編集する
#!/bin/bash

# メニュー項目とその説明
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
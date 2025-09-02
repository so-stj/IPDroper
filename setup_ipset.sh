#!/bin/bash

# IPDroper - ipset版メインメニュー
# This is the main menu script for ipset-based country IP blocking

# Script list and descriptions
declare -a script_list=("ipsetConfiguration.sh" "ipsetRemove.sh" "ipsetList.sh")
declare -a script_descriptions=("国をブロック (ipset版)" "ブロックを削除 (ipset版)" "現在の状態を表示 (ipset版)")

# Scripts directory
script_dir="./scripts"

# Validate scripts directory
if [ ! -d "$script_dir" ]; then
    echo "❌ スクリプトディレクトリが見つかりません: $script_dir"
    exit 1
fi

# Function to check prerequisites
check_prerequisites() {
    echo "🔍 前提条件をチェック中..."
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        echo "❌ このスクリプトはroot権限で実行する必要があります"
        echo "sudo ./setup_ipset.sh を使用してください"
        exit 1
    fi
    
    # Check if ipset is available
    if ! command -v ipset &> /dev/null; then
        echo "❌ ipsetがインストールされていません"
        echo ""
        echo "📦 インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        echo "  Arch Linux: sudo pacman -S ipset"
        echo ""
        echo "インストール後、このスクリプトを再実行してください"
        exit 1
    fi
    
    # Check if iptables is available
    if ! command -v iptables &> /dev/null; then
        echo "❌ iptablesがインストールされていません"
        echo ""
        echo "📦 インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install iptables"
        echo "  CentOS/RHEL: sudo yum install iptables"
        echo "  Arch Linux: sudo pacman -S iptables"
        echo ""
        echo "インストール後、このスクリプトを再実行してください"
        exit 1
    fi
    
    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo "❌ curlがインストールされていません"
        echo ""
        echo "📦 インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install curl"
        echo "  CentOS/RHEL: sudo yum install curl"
        echo "  Arch Linux: sudo pacman -S curl"
        echo ""
        echo "インストール後、このスクリプトを再実行してください"
        exit 1
    fi
    
    # Load ipset modules if needed
    if ! lsmod | grep -q "ip_set"; then
        echo "📥 ipsetカーネルモジュールを読み込み中..."
        modprobe ip_set
        modprobe ip_set_hash_net
        
        if ! lsmod | grep -q "ip_set"; then
            echo "❌ ipsetカーネルモジュールの読み込みに失敗しました"
            echo "カーネルがipsetをサポートしているか確認してください"
            exit 1
        fi
    fi
    
    echo "✅ 前提条件チェック完了"
    echo ""
}

# Function to show current status
show_current_status() {
    echo "📊 現在の状態"
    echo "================================"
    
    # Show blocked countries
    local blocked_countries=$(ipset list -name 2>/dev/null | grep "^DROP-" | wc -l)
    if [ "$blocked_countries" -gt 0 ]; then
        echo "🌍 ブロックされた国: ${blocked_countries}カ国"
        for set_name in $(ipset list -name 2>/dev/null | grep "^DROP-"); do
            local country_code=$(echo "$set_name" | sed 's/^DROP-//')
            local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
            echo "  ${country_code}: ${entry_count}個のIP範囲"
        done
    else
        echo "ℹ️ ブロックされた国はありません"
    fi
    
    echo ""
    
    # Show iptables rules
    local ipset_rules=$(iptables -L INPUT -n 2>/dev/null | grep -c "ipset" || echo "0")
    echo "🔒 ipset関連のiptablesルール: ${ipset_rules}個"
    
    echo ""
}

# Function to show menu
show_menu() {
    echo "🚀 IPDroper - ipset版"
    echo "================================"
    echo "国別IPブロックツール (高性能ipset版)"
    echo ""
    
    show_current_status
    
    echo "📋 利用可能なスクリプト:"
    local index=1
    for script in "${script_list[@]}"; do
        local description="${script_descriptions[$((index-1))]}"
        echo "$index) $script - $description"
        index=$((index + 1))
    done
    
    echo ""
    echo "💡 ヒント:"
    echo "  - 初回使用時はオプション1から開始してください"
    echo "  - 現在の状態確認はオプション3を使用してください"
    echo "  - ブロック削除はオプション2を使用してください"
    echo ""
}

# Function to run selected script
run_script() {
    local selected=$1
    local script_file="$script_dir/$selected"
    
    # Check if script exists
    if [ ! -f "$script_file" ]; then
        echo "❌ スクリプトが見つかりません: $script_file"
        return 1
    fi
    
    # Make script executable
    chmod +x "$script_file"
    
    # Show script description
    local selected_index=$(echo "${script_list[@]}" | tr ' ' '\n' | grep -n "$selected" | cut -d ':' -f 1)
    local description="${script_descriptions[$((selected_index-1))]}"
    
    echo ""
    echo "🔍 選択されたスクリプト: $selected"
    echo "説明: $description"
    echo ""
    
    read -p "このスクリプトを実行しますか？ (y/N): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        echo "🚀 スクリプトを実行中..."
        echo ""
        
        # Run script
        bash "$script_file"
        
        echo ""
        echo "✅ スクリプトの実行が完了しました"
    else
        echo "❌ スクリプトの実行がキャンセルされました"
    fi
}

# Function to handle user selection
handle_selection() {
    echo "選択してください:"
    PS3="番号を入力してください: "
    
    select selected in "${script_list[@]}"; do
        if [ -z "$selected" ]; then
            echo "❌ 無効な選択です"
            echo "1-${#script_list[@]}の間の番号を入力してください"
        else
            run_script "$selected"
            break
        fi
    done
}

# Function to show help
show_help() {
    echo "📖 IPDroper - ipset版 ヘルプ"
    echo "================================"
    echo ""
    echo "🌍 国別IPブロックツール"
    echo "このツールはipsetを使用して、特定の国からのIPアドレスを"
    echo "効率的にブロックします。従来のiptables方式と比較して、"
    echo "大幅なパフォーマンス向上と管理の簡素化を実現します。"
    echo ""
    echo "✨ 主な特徴:"
    echo "  - 高速なIPルックアップ (ハッシュテーブルベース)"
    echo "  - メモリ効率の良い管理"
    echo "  - 数千のIP範囲でも単一のiptablesルール"
    echo "  - 簡単な追加・削除・更新操作"
    echo ""
    echo "🔧 前提条件:"
    echo "  - Linux カーネル (ipsetサポート)"
    echo "  - ipset パッケージ"
    echo "  - iptables パッケージ"
    echo "  - curl パッケージ"
    echo "  - root権限"
    echo ""
    echo "📚 使用方法:"
    echo "  1. 国をブロック: オプション1"
    echo "  2. ブロックを削除: オプション2"
    echo "  3. 状態を確認: オプション3"
    echo ""
    echo "💡 パフォーマンス比較:"
    echo "  | 項目 | iptables方式 | ipset方式 |"
    echo "  |------|-------------|-----------|"
    echo "  | ルール数 | 数千〜数万 | 1 (+ipset内のIP) |"
    echo "  | ルックアップ | 線形検索 | ハッシュ検索 |"
    echo "  | メモリ使用量 | 多い | 少ない |"
    echo "  | 更新速度 | 遅い | 高速 |"
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
    echo "👋 IPDroper - ipset版を終了します"
    echo "またのご利用をお待ちしています！"
}

# Run main function
main "$@"

#!/bin/bash

# IPDroper - ipset status display script
# This script shows the current status of ipset-based country blocks

# Function to check if ipset is available
check_ipset() {
    if ! command -v ipset &> /dev/null; then
        echo "❌ ipsetがインストールされていません。"
        echo "インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        exit 1
    fi
}

# Function to display ipset statistics
display_ipset_stats() {
    echo "📊 ipset統計情報"
    echo "================================"
    
    local total_entries=0
    local total_ipsets=0
    
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
        local memory_usage=$(ipset list "$set_name" 2>/dev/null | grep "Size in memory" | awk '{print $4}' || echo "N/A")
        
        echo "  🌍 ${country_code}:"
        echo "    ipset: ${set_name}"
        echo "    エントリ数: ${entry_count}"
        echo "    メモリ使用量: ${memory_usage}"
        echo ""
        
        total_entries=$((total_entries + entry_count))
        total_ipsets=$((total_ipsets + 1))
    done
    
    if [ $total_ipsets -eq 0 ]; then
        echo "  ℹ️ ブロックされた国はありません"
    else
        echo "📈 総計:"
        echo "  ブロックされた国数: ${total_ipsets}"
        echo "  総エントリ数: ${total_entries}"
    fi
    
    echo ""
}

# Function to display iptables rules
display_iptables_rules() {
    echo "🔒 iptablesルール"
    echo "================================"
    
    # Show INPUT chain rules related to ipset
    echo "INPUTチェーン (ipset関連):"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|ipset)" || echo "  ℹ️ ipset関連のルールはありません"
    
    echo ""
    
    # Show all chains
    echo "全チェーン:"
    iptables -L -n --line-numbers | grep -E "^Chain|DROP-" || echo "  ℹ️ チェーンが見つかりません"
    
    echo ""
}

# Function to display system information
display_system_info() {
    echo "💻 システム情報"
    echo "================================"
    
    # Kernel version
    echo "カーネルバージョン: $(uname -r)"
    
    # iptables version
    local iptables_version=$(iptables --version 2>/dev/null | head -1 || echo "N/A")
    echo "iptablesバージョン: ${iptables_version}"
    
    # ipset version
    local ipset_version=$(ipset --version 2>/dev/null | head -1 || echo "N/A")
    echo "ipsetバージョン: ${ipset_version}"
    
    # Loaded ipset modules
    echo "読み込まれたipsetモジュール:"
    lsmod | grep "ip_set" || echo "  ℹ️ ipsetモジュールは読み込まれていません"
    
    echo ""
}

# Function to display detailed ipset information
display_detailed_ipset() {
    local set_name=$1
    
    if [ -z "$set_name" ]; then
        echo "詳細表示するipset名を入力してください:"
        read -p "ipset名 (例: DROP-CN): " set_name
    fi
    
    if [ -z "$set_name" ]; then
        echo "❌ ipset名が指定されていません"
        return 1
    fi
    
    if ! ipset list -name | grep -q "^${set_name}$"; then
        echo "❌ ipset ${set_name}は存在しません"
        return 1
    fi
    
    echo "🔍 ${set_name}の詳細情報"
    echo "================================"
    
    # Show full ipset contents
    ipset list "${set_name}"
    
    echo ""
    
    # Show iptables rules using this ipset
    echo "このipsetを使用するiptablesルール:"
    iptables -L -n | grep -E "${set_name}" || echo "  ℹ️ 関連するルールはありません"
}

# Function to show performance metrics
display_performance_metrics() {
    echo "⚡ パフォーマンス指標"
    echo "================================"
    
    # Show iptables statistics
    echo "iptables統計:"
    iptables -L INPUT -v -n | grep -E "(DROP|ipset)" || echo "  ℹ️ 統計情報はありません"
    
    echo ""
    
    # Show ipset performance info
    echo "ipsetパフォーマンス情報:"
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        echo "  ${country_code}:"
        ipset list "${set_name}" | grep -E "(Size in memory|References|Number of entries)" | sed 's/^/    /'
    done
    
    echo ""
}

# Main execution
main() {
    echo "📋 IPDroper - ipset状態表示ツール"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # Display menu
    echo "表示オプションを選択してください:"
    echo "1) 概要表示 (推奨)"
    echo "2) 詳細表示"
    echo "3) 特定のipset詳細"
    echo "4) パフォーマンス指標"
    echo "5) 全情報表示"
    
    read -p "番号を入力してください (1-5): " choice
    
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
            echo "❌ 無効な選択です"
            exit 1
            ;;
    esac
    
    echo ""
    echo "💡 ヒント:"
    echo "  - 新しい国をブロック: sudo ./scripts/ipsetConfiguration.sh"
    echo "  - ブロックを削除: sudo ./scripts/ipsetRemove.sh"
    echo "  - このツールを再実行: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

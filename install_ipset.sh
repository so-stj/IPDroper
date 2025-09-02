#!/bin/bash

# IPDroper - ipsetインストールスクリプト
# This script installs and configures ipset for IPDroper

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Function to install ipset on Ubuntu/Debian
install_ipset_debian() {
    print_status $BLUE "📦 Debian/Ubuntu系ディストリビューションを検出しました"
    
    # Update package list
    print_status $YELLOW "パッケージリストを更新中..."
    apt-get update
    
    # Install ipset
    print_status $YELLOW "ipsetをインストール中..."
    apt-get install -y ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "iptablesをインストール中..."
        apt-get install -y iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "curlをインストール中..."
        apt-get install -y curl
    fi
}

# Function to install ipset on CentOS/RHEL
install_ipset_rhel() {
    print_status $BLUE "📦 CentOS/RHEL系ディストリビューションを検出しました"
    
    # Install ipset
    print_status $YELLOW "ipsetをインストール中..."
    yum install -y ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "iptablesをインストール中..."
        yum install -y iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "curlをインストール中..."
        yum install -y curl
    fi
}

# Function to install ipset on Arch Linux
install_ipset_arch() {
    print_status $BLUE "📦 Arch Linux系ディストリビューションを検出しました"
    
    # Install ipset
    print_status $YELLOW "ipsetをインストール中..."
    pacman -S --noconfirm ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "iptablesをインストール中..."
        pacman -S --noconfirm iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "curlをインストール中..."
        pacman -S --noconfirm curl
    fi
}

# Function to check kernel support
check_kernel_support() {
    print_status $BLUE "🔍 カーネルのipsetサポートをチェック中..."
    
    # Check if ipset modules are available
    if [ -d "/lib/modules/$(uname -r)/kernel/net/netfilter/ipset" ]; then
        print_status $GREEN "✅ カーネルがipsetをサポートしています"
        return 0
    else
        print_status $RED "❌ カーネルがipsetをサポートしていません"
        print_status $YELLOW "カーネルの再コンパイルまたは更新が必要です"
        return 1
    fi
}

# Function to load ipset modules
load_ipset_modules() {
    print_status $BLUE "📥 ipsetカーネルモジュールを読み込み中..."
    
    # Load ipset module
    if modprobe ip_set; then
        print_status $GREEN "✅ ip_setモジュールが読み込まれました"
    else
        print_status $RED "❌ ip_setモジュールの読み込みに失敗しました"
        return 1
    fi
    
    # Load hash:net module
    if modprobe ip_set_hash_net; then
        print_status $GREEN "✅ ip_set_hash_netモジュールが読み込まれました"
    else
        print_status $RED "❌ ip_set_hash_netモジュールの読み込みに失敗しました"
        return 1
    fi
    
    return 0
}

# Function to configure persistent module loading
configure_persistent_modules() {
    print_status $BLUE "🔧 永続的なモジュール読み込みを設定中..."
    
    local distro=$(detect_distro)
    local modules_file=""
    
    case $distro in
        "ubuntu"|"debian"|"linuxmint")
            modules_file="/etc/modules"
            ;;
        "centos"|"rhel"|"fedora"|"rocky"|"alma")
            modules_file="/etc/modules-load.d/ipset.conf"
            ;;
        "arch"|"manjaro")
            modules_file="/etc/modules-load.d/ipset.conf"
            ;;
        *)
            print_status $YELLOW "⚠️ このディストリビューションの永続化設定は手動で行う必要があります"
            return 0
            ;;
    esac
    
    # Add modules to the file
    if [ ! -f "$modules_file" ]; then
        touch "$modules_file"
    fi
    
    # Check if modules are already added
    if ! grep -q "ip_set" "$modules_file"; then
        echo "ip_set" >> "$modules_file"
        print_status $GREEN "✅ ip_setを$modules_fileに追加しました"
    fi
    
    if ! grep -q "ip_set_hash_net" "$modules_file"; then
        echo "ip_set_hash_net" >> "$modules_file"
        print_status $GREEN "✅ ip_set_hash_netを$modules_fileに追加しました"
    fi
    
    print_status $GREEN "✅ 永続的なモジュール読み込みが設定されました"
}

# Function to test ipset functionality
test_ipset() {
    print_status $BLUE "🧪 ipsetの動作テスト中..."
    
    # Create test ipset
    if ipset create test_set hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null; then
        print_status $GREEN "✅ テストipsetの作成に成功しました"
        
        # Add test entry
        if ipset add test_set 192.168.1.0/24 2>/dev/null; then
            print_status $GREEN "✅ テストエントリの追加に成功しました"
            
            # List test ipset
            if ipset list test_set >/dev/null 2>&1; then
                print_status $GREEN "✅ ipsetの一覧表示に成功しました"
                
                # Remove test ipset
                if ipset destroy test_set 2>/dev/null; then
                    print_status $GREEN "✅ テストipsetの削除に成功しました"
                    return 0
                else
                    print_status $RED "❌ テストipsetの削除に失敗しました"
                    return 1
                fi
            else
                print_status $RED "❌ ipsetの一覧表示に失敗しました"
                return 1
            fi
        else
            print_status $RED "❌ テストエントリの追加に失敗しました"
            ipset destroy test_set 2>/dev/null
            return 1
        fi
    else
        print_status $RED "❌ テストipsetの作成に失敗しました"
        return 1
    fi
}

# Function to show installation summary
show_summary() {
    print_status $GREEN "🎉 ipsetのインストールが完了しました！"
    echo ""
    echo "📋 インストールされたパッケージ:"
    echo "  ✅ ipset: $(ipset --version 2>/dev/null | head -1 || echo 'N/A')"
    echo "  ✅ iptables: $(iptables --version 2>/dev/null | head -1 || echo 'N/A')"
    echo "  ✅ curl: $(curl --version 2>/dev/null | head -1 || echo 'N/A')"
    echo ""
    echo "🔧 設定された項目:"
    echo "  ✅ カーネルモジュールの読み込み"
    echo "  ✅ 永続的なモジュール読み込み設定"
    echo "  ✅ ipsetの動作テスト"
    echo ""
    echo "🚀 次のステップ:"
    echo "  1. sudo ./setup_ipset.sh を実行してIPDroperを開始"
    echo "  2. 初回使用時はオプション1から開始してください"
    echo ""
    echo "💡 ヘルプ:"
    echo "  ./setup_ipset.sh --help で詳細なヘルプを表示"
    echo ""
}

# Main execution
main() {
    print_status $BLUE "🚀 IPDroper - ipsetインストーラー"
    echo "=========================================="
    echo "国別IPブロックツール用のipsetをインストールします"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_status $RED "❌ このスクリプトはroot権限で実行する必要があります"
        echo "sudo ./install_ipset.sh を使用してください"
        exit 1
    fi
    
    # Detect distribution and install packages
    local distro=$(detect_distro)
    case $distro in
        "ubuntu"|"debian"|"linuxmint")
            install_ipset_debian
            ;;
        "centos"|"rhel"|"fedora"|"rocky"|"alma")
            install_ipset_rhel
            ;;
        "arch"|"manjaro")
            install_ipset_arch
            ;;
        *)
            print_status $RED "❌ サポートされていないディストリビューションです: $distro"
            echo "手動でipset、iptables、curlをインストールしてください"
            exit 1
            ;;
    esac
    
    # Check kernel support
    if ! check_kernel_support; then
        exit 1
    fi
    
    # Load ipset modules
    if ! load_ipset_modules; then
        exit 1
    fi
    
    # Configure persistent module loading
    configure_persistent_modules
    
    # Test ipset functionality
    if ! test_ipset; then
        print_status $RED "❌ ipsetの動作テストに失敗しました"
        exit 1
    fi
    
    # Show installation summary
    show_summary
}

# Run main function
main "$@"

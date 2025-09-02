#!/bin/bash

# IPDroper - ipset-based country IP blocking script
# This script uses ipset for better performance and easier management

# Function to validate country code
validate_country_code() {
    local valid_codes=("AD" "AE" "AF" "AG" "AI" "AL" "AM" "AO" "AR" "AS" "AT" "AU" "AW" "AX" "AZ"
                       "BA" "BB" "BD" "BE" "BF" "BG" "BH" "BI" "BJ" "BL" "BM" "BN" "BO" "BQ" "BR"
                       "BS" "BT" "BV" "BW" "BY" "BZ" "CA" "CC" "CD" "CF" "CG" "CH" "CI" "CK" "CL"
                       "CM" "CN" "CO" "CR" "CU" "CV" "CW" "CX" "CY" "CZ" "DE" "DJ" "DK" "DM" "DO"
                       "DZ" "EC" "EE" "EG" "EH" "ER" "ES" "ET" "FI" "FJ" "FM" "FO" "FR" "GA" "GB"
                       "GD" "GE" "GF" "GG" "GH" "GI" "GL" "GM" "GN" "GP" "GQ" "GR" "GT" "GU" "GW"
                       "GY" "HK" "HM" "HN" "HR" "HT" "HU" "ID" "IE" "IL" "IM" "IN" "IO" "IQ" "IR"
                       "IS" "IT" "JE" "JM" "JO" "JP" "KE" "KG" "KH" "KI" "KM" "KN" "KP" "KR" "KW"
                       "KY" "KZ" "LA" "LB" "LC" "LI" "LK" "LR" "LS" "LT" "LU" "LV" "LY" "MA" "MC"
                       "MD" "ME" "MF" "MG" "MH" "MK" "ML" "MM" "MN" "MO" "MP" "MQ" "MR" "MS" "MT"
                       "MU" "MV" "MW" "MX" "MY" "MZ" "NA" "NC" "NE" "NF" "NG" "NI" "NL" "NO" "NP"
                       "NR" "NU" "NZ" "OM" "PA" "PE" "PF" "PG" "PH" "PK" "PL" "PM" "PN" "PR" "PT"
                       "PW" "PY" "QA" "RE" "RO" "RS" "RU" "RW" "SA" "SB" "SC" "SD" "SE" "SG" "SH"
                       "SI" "SJ" "SK" "SL" "SM" "SN" "SO" "SR" "SS" "ST" "SV" "SX" "SY" "SZ" "TC"
                       "TD" "TF" "TG" "TH" "TJ" "TK" "TL" "TM" "TN" "TO" "TR" "TT" "TV" "TZ" "UA"
                       "UG" "UM" "US" "UY" "UZ" "VA" "VC" "VE" "VG" "VI" "VN" "VU" "WF" "WS" "YE"
                       "YT" "ZA" "ZM" "ZW")
    
    if [[ ! " ${valid_codes[@]} " =~ " ${COUNTRY} " ]]; then
        echo "❌ 無効な国コードです: ${COUNTRY}"
        echo "有効なISO 3166-1 alpha-2国コードを入力してください。"
        exit 1
    fi
}

# Function to calculate CIDR from IP range
calculate_cidr() {
    local start_ip=$1
    local num_ips=$2
    
    # Convert IP to decimal
    local ip_decimal=$(echo $start_ip | awk -F. '{print $1*256^3 + $2*256^2 + $3*256 + $4}')
    local end_decimal=$((ip_decimal + num_ips - 1))
    
    # Calculate CIDR
    local cidr=32
    local temp=$num_ips
    
    while [ $temp -gt 1 ]; do
        temp=$((temp / 2))
        cidr=$((cidr - 1))
    done
    
    # Validate CIDR calculation
    local max_ips=$((2 ** (32 - cidr)))
    if [ $num_ips -le $max_ips ]; then
        echo "${start_ip}/${cidr}"
    else
        # If CIDR calculation fails, return null
        echo "null"
    fi
}

# Function to check if ipset is available
check_ipset() {
    if ! command -v ipset &> /dev/null; then
        echo "❌ ipsetがインストールされていません。"
        echo "インストール方法:"
        echo "  Ubuntu/Debian: sudo apt-get install ipset"
        echo "  CentOS/RHEL: sudo yum install ipset"
        exit 1
    fi
    
    # Check if ipset module is loaded
    if ! lsmod | grep -q "ip_set"; then
        echo "📥 ipsetカーネルモジュールを読み込み中..."
        modprobe ip_set
        modprobe ip_set_hash_net
    fi
}

# Function to create ipset and add IP ranges
create_country_ipset() {
    local country=$1
    local url=$2
    local set_name="DROP-${country}"
    
    echo "🌍 ${country}のIP範囲をブロック中..."
    echo "📥 RIRデータをダウンロード中: ${url}"
    
    # Download RIR data
    if ! curl -s "${url}" > /tmp/delegated-latest; then
        echo "❌ RIRデータのダウンロードに失敗しました: ${url}"
        exit 1
    fi
    
    # Remove existing ipset if it exists
    if ipset list -name | grep -q "^${set_name}$"; then
        echo "🗑️ 既存のipsetを削除中: ${set_name}"
        ipset destroy "${set_name}"
    fi
    
    # Create new ipset
    echo "🆕 ipsetを作成中: ${set_name}"
    ipset create "${set_name}" hash:net family inet hashsize 1024 maxelem 65536
    
    # Process IP ranges
    echo "⚡ IP範囲を処理中..."
    local count=0
    local valid_ranges=0
    
    while IFS='|' read -r registry cc type start_ip num_ips date status; do
        if [[ "$cc" == "$country" && "$type" == "ipv4" ]]; then
            local cidr=$(calculate_cidr "$start_ip" "$num_ips")
            if [[ "$cidr" != "null" ]]; then
                ipset add "${set_name}" "$cidr" 2>/dev/null
                if [ $? -eq 0 ]; then
                    valid_ranges=$((valid_ranges + 1))
                    echo -n "✅ $cidr "
                fi
                count=$((count + 1))
                
                # Progress indicator
                if [ $((count % 100)) -eq 0 ]; then
                    echo "($count ranges processed)"
                fi
            fi
        fi
    done < /tmp/delegated-latest
    
    echo ""
    echo "📊 処理完了: ${valid_ranges}個の有効なIP範囲を${set_name}に追加"
    
    # Clean up temporary file
    rm -f /tmp/delegated-latest
    
    # Show ipset statistics
    echo "📈 ipset統計:"
    ipset list "${set_name}" | head -20
    echo "..."
    
    # Create iptables rule if it doesn't exist
    if ! iptables -C INPUT -m set --match-set "${set_name}" src -j DROP 2>/dev/null; then
        echo "🔒 iptablesルールを作成中..."
        iptables -A INPUT -m set --match-set "${set_name}" src -j DROP
        echo "✅ iptablesルールが作成されました"
    else
        echo "ℹ️ iptablesルールは既に存在します"
    fi
}

# Main execution
main() {
    echo "🚀 IPDroper - ipset版"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # User input
    echo "地域インターネットレジストリを選択してください:"
    echo "1) APNIC (Asia Pacific)"
    echo "2) RIPE-NCC (Europe)"
    echo "3) ARIN (North America)"
    echo "4) LACNIC (Latin America)"
    echo "5) AFRINIC (Africa)"
    
    read -p "番号を入力してください (1-5): " org_choice
    
    case $org_choice in
        1) url="https://ftp.apnic.net/stats/apnic/delegated-apnic-latest" ;;
        2) url="https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest" ;;
        3) url="https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest" ;;
        4) url="https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest" ;;
        5) url="https://ftp.afrinic.net/pub/stats/afrinic/delegated-afrinic-latest" ;;
        *) echo "❌ 無効な選択です"; exit 1 ;;
    esac
    
    read -p "国コードを入力してください (例: CN, RU, JP): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
    
    # Validate country code
    validate_country_code
    
    echo ""
    echo "🔍 設定確認:"
    echo "  国: ${COUNTRY}"
    echo "  RIR: $url"
    echo ""
    
    read -p "続行しますか？ (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ 操作がキャンセルされました"
        exit 0
    fi
    
    # Create ipset and block country
    create_country_ipset "$COUNTRY" "$url"
    
    echo ""
    echo "🎉 ${COUNTRY}のブロックが完了しました！"
    echo "📊 現在のiptablesルール:"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|${COUNTRY})"
    
    echo ""
    echo "💡 ヒント:"
    echo "  - ブロックを解除: sudo ./scripts/ipsetRemove.sh"
    echo "  - 現在の状態確認: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

#!/bin/bash

# IPDroper - ipset removal script
# This script removes country IP blocks created with ipset

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

# Function to remove country ipset
remove_country_ipset() {
    local country=$1
    local set_name="DROP-${country}"
    
    echo "🗑️ ${country}のIPブロックを削除中..."
    
    # Check if ipset exists
    if ! ipset list -name | grep -q "^${set_name}$"; then
        echo "ℹ️ ipset ${set_name}は存在しません"
        return 0
    fi
    
    # Remove iptables rule if it exists
    if iptables -C INPUT -m set --match-set "${set_name}" src -j DROP 2>/dev/null; then
        echo "🔓 iptablesルールを削除中..."
        iptables -D INPUT -m set --match-set "${set_name}" src -j DROP
        echo "✅ iptablesルールが削除されました"
    else
        echo "ℹ️ iptablesルールは既に存在しません"
    fi
    
    # Show ipset contents before removal
    echo "📊 削除前のipset内容:"
    ipset list "${set_name}" | head -10
    echo "..."
    
    # Get ipset statistics
    local entry_count=$(ipset list "${set_name}" | grep -c "^[0-9]")
    echo "📈 エントリ数: ${entry_count}"
    
    # Remove ipset
    echo "🗑️ ipsetを削除中: ${set_name}"
    ipset destroy "${set_name}"
    
    if [ $? -eq 0 ]; then
        echo "✅ ipset ${set_name}が正常に削除されました"
    else
        echo "❌ ipsetの削除に失敗しました"
        exit 1
    fi
}

# Function to list all available ipsets
list_available_ipsets() {
    echo "📋 利用可能なipset一覧:"
    echo "================================"
    
    local ipset_count=0
    for set_name in $(ipset list -name | grep "^DROP-"); do
        local country_code=$(echo "$set_name" | sed 's/^DROP-//')
        local entry_count=$(ipset list "$set_name" 2>/dev/null | grep -c "^[0-9]" || echo "0")
        echo "  ${country_code}: ${set_name} (${entry_count} entries)"
        ipset_count=$((ipset_count + 1))
    done
    
    if [ $ipset_count -eq 0 ]; then
        echo "  ℹ️ ブロックされた国はありません"
    fi
    
    echo ""
}

# Main execution
main() {
    echo "🗑️ IPDroper - ipset削除ツール"
    echo "================================"
    
    # Check prerequisites
    check_ipset
    
    # Show available ipsets
    list_available_ipsets
    
    # User input
    read -p "削除する国のコードを入力してください (例: CN, RU, JP): " COUNTRY
    COUNTRY=$(echo "$COUNTRY" | tr '[:lower:]' '[:upper:]')
    
    # Validate country code
    validate_country_code
    
    echo ""
    echo "🔍 削除確認:"
    echo "  国: ${COUNTRY}"
    echo "  ipset: DROP-${COUNTRY}"
    echo ""
    
    read -p "本当に${COUNTRY}のブロックを削除しますか？ (y/N): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ 操作がキャンセルされました"
        exit 0
    fi
    
    # Remove country ipset
    remove_country_ipset "$COUNTRY"
    
    echo ""
    echo "🎉 ${COUNTRY}のブロック削除が完了しました！"
    echo "📊 現在のiptablesルール:"
    iptables -L INPUT -n --line-numbers | grep -E "(DROP|${COUNTRY})" || echo "  ℹ️ 関連するルールはありません"
    
    echo ""
    echo "💡 ヒント:"
    echo "  - 新しい国をブロック: sudo ./scripts/ipsetConfiguration.sh"
    echo "  - 現在の状態確認: sudo ./scripts/ipsetList.sh"
}

# Run main function
main "$@"

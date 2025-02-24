#!/bin/sh

# 管理組織のURLと国コードを入力できるように変更
echo "使用する管理組織を選択してください:"
echo "1) APNIC"
echo "2) RIPE"
echo "3) ARIN"
echo "4) LACNIC"
read -p "番号を入力してください (1-4): " ORG_CHOICE
echo "国コードを入力してください (例: ID, JP):"
read COUNTRY

# alpha2コードの形式チェック
if ! echo "$COUNTRY" | grep -q '^[A-Za-z][A-Za-z]$'; then
    echo "無効な国コードです。alpha2コードを使用してください。"
    exit 1
fi

# 各管理組織のURLを設定
case $ORG_CHOICE in
    1)  APNIC_URL='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest' ;;
    2)  APNIC_URL='https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest' ;;
    3)  APNIC_URL='https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest' ;;
    4)  APNIC_URL='https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest' ;;
    *)  echo "無効な選択です"; exit 1 ;;
esac

# 国コードが選ばれた管理組織に関連しているかチェック
function is_valid_country_for_org() {
    case $ORG_CHOICE in
        1)  VALID_COUNTRIES=("AP" "AU" "BD" "CN" "ID" "IN" "JP" "KR" "MY" "NP" "SG" "TH" "VN") ;;  # APNICで管理している国
        2)  VALID_COUNTRIES=("AL" "AT" "BE" "BG" "HR" "CY" "CZ" "DK" "EE" "FI" "FR" "DE" "GR" "HU" "IS" "IE" "IT" "LV" "LT" "LU" "MT" "NL" "NO" "PL" "PT" "RO" "SK" "SI" "ES" "SE" "GB") ;;  # RIPEで管理している国
        3)  VALID_COUNTRIES=("US" "CA" "MX") ;;  # ARINで管理している国
        4)  VALID_COUNTRIES=("AR" "BR" "CL" "CO" "EC" "GT" "HN" "MX" "NI" "PA" "PY" "PE" "SR" "UY" "VE") ;;  # LACNICで管理している国
        *)  echo "無効な選択です"; exit 1 ;;
    esac

    # 国コードがリストにあるか確認
    for country in "${VALID_COUNTRIES[@]}"; do
        if [ "$COUNTRY" == "$country" ]; then
            return 0  # 国コードが有効
        fi
    done
    return 1  # 国コードが無効
}

# 国コードが管理組織に関連しているかを確認
if ! is_valid_country_for_org; then
    echo "選択した管理組織には、指定された国コード($COUNTRY)が関連していません。"
    exit 1
fi

#------------------------------------------
# APNIC から指定された国を抽出し無条件でDROP
#------------------------------------------
function drop_country_iptables() {
    echo "データー取得中: ${APNIC_URL}"
    if curl -s ${APNIC_URL} > /tmp/delegated-latest
    then
        echo "iptables 設定中: しばらく時間がかかります"
        iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
        iptables -F DROP-${COUNTRY} > /dev/null 2>&1
        iptables -X DROP-${COUNTRY} > /dev/null 2>&1
        iptables -N DROP-${COUNTRY}
        COUNT=0
        for i in $(awk -F'|' '$2~/'${COUNTRY}'/&&$3~/ipv4/{print $4","$5}' /tmp/delegated-latest)
        do
            IP_LIST_1=$(echo $i | cut -d',' -f1)
            IP_LIST_2=$(echo $i | cut -d',' -f2)
            IP_CO_LIST=$(cider_calc $IP_LIST_1 $IP_LIST_2)

            if [ ${IP_CO_LIST} != 'null' ]; then
                iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP
                echo_erase "iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP"
                echo "${IP_CO_LIST} - ${COUNTRY}" >> /var/log/blocked_ips.log
            fi
        done
        iptables -A DROP-${COUNTRY} -j RETURN
        iptables -I INPUT 1 -j DROP-${COUNTRY}
        iptables -nvxL
        rm -rf /tmp/delegated-latest
    else
        echo "データー取得失敗:${APNIC_URL}"
        exit 1
    fi
}

# その他の関数（`init_country_iptables`, `cider_calc`, `echo_erase`）はそのままで良い。

#------------------------------------------
# iptables の 実行
#------------------------------------------
drop_country_iptables
echo -e '\n==================================================\n'
echo -e "### 設定完了 ###\n"
echo -e '現在の設定で問題がなければ120秒以内に「 Ctrl + c 」で抜けてセーブして下さい。\n'
sleep 120
init_country_iptables

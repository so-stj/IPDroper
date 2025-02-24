#!/bin/sh

# 管理組織のURLと国コードを入力できるように変更
echo "使用する管理組織を選択してください:"
echo "1) APNIC"
echo "2) RIPE"
echo "3) ARIN"
echo "4) LACNIC"
read -p "番号を入力してください (1-3): " ORG_CHOICE
echo "国コードを入力してください (例: ID, JP):"
read COUNTRY

# 各管理組織のURLを設定
case $ORG_CHOICE in
    1)  URL='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest' ;;
    2)  URL='https://ftp.ripe.net/ripe/stats/delegated-ripencc-latest' ;;
    3)  URL='https://ftp.arin.net/pub/stats/arin/delegated-arin-extended-latest' ;;
    4)  URL='https://ftp.lacnic.net/pub/stats/ripencc/delegated-ripencc-latest' ;;
    *)  echo "無効な選択です"; exit 1 ;;
esac

#------------------------------------------
# APNIC から指定された国を抽出し無条件でDROP
#------------------------------------------
function drop_country_iptables(){

    echo "データー取得中: ${URL}"
    if curl -s ${URL} > /tmp/delegated-latest
    then
        echo "iptables 設定中: しばらく時間がかかります"
        iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
        iptables -F DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -X DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -N DROP-${COUNTRY}
        COUNT=0
        for i in $(awk -F'|' '$2~/'${COUNTRY}'/&&$3~/ipv4/{print $4","$5}' /tmp/delegated-latest)
        do
            IP_LIST_1=$(echo $i | cut -d',' -f1)
            IP_LIST_2=$(echo $i | cut -d',' -f2)
            IP_CO_LIST=$(cider_calculator $IP_LIST_1 $IP_LIST_2)

            if [ ${IP_CO_LIST} != 'null' ];then
                iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP
                echo_erase "iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP"
                echo "${IP_CO_LIST} - ${COUNTRY}" >> /var/log/blocked_ips.log
            fi

        done
        iptables -A DROP-${COUNTRY} -j RETURN
        iptables -I INPUT 1    -j DROP-${COUNTRY}
        iptables -nvxL
        rm -rf /tmp/delegated-latest
    else
        echo "データー取得失敗:${URL}"
        exit 1
    fi
}

#------------------------------------------
# iptables の初期化
#------------------------------------------
function init_country_iptables(){

    iptables -D INPUT -j DROP-${COUNTRY}
    iptables -F DROP-${COUNTRY}
    iptables -X DROP-${COUNTRY}
    iptables -nvxL
    echo -e '\n==================================================\n'
    echo -e '\n120秒間反応がなかったためiptables を初期化しました\n'
}

#------------------------------------------
# 保有IP数よりCIDERを算出
#------------------------------------------
function cider_calculator){

    local IP_ADDRESS_NUM=4294967296
    local IP_ADDRESS=$1
    local IP_NUM=$2
    local IP_CIDER='null'

    for i in $(seq 1 32)
    do
        IP_ADDRESS_NUM=$((${IP_ADDRESS_NUM}/2))
        if [ $((IP_ADDRESS_NUM/IP_NUM)) -eq 1 -a $((IP_ADDRESS_NUM%IP_NUM)) -eq 0 ]; then
            IP_CIDER=$i
            break
        fi
    done

    if [ $IP_CIDER = 'null' ];then
        echo 'null'
    else
        echo "$IP_ADDRESS/$IP_CIDER"
    fi
}

#------------------------------------------
# 標準出力を制御する関数
#------------------------------------------
function echo_erase(){

    local STRING="$1"
    echo -n ${STRING}
    for i in $(seq 0 ${#STRING})
    do
        echo -n $'\b'
    done
}

#------------------------------------------
# iptables の 実行
#------------------------------------------
drop_country_iptables
echo -e '\n==================================================\n'
echo -e "### 設定完了 ###\n"
echo -e '現在の設定で問題がなければ120秒以内に「 Ctrl + c 」で抜けてセーブして下さい。\n'
sleep 120
init_country_iptables

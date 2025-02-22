#!/bin/sh

APNIC_URL='http://ftp.apnic.net/stats/apnic/delegated-apnic-latest'
COUNTRY='ID'

#------------------------------------------
# APNIC から CN だけ抽出し無条件でDROP
#------------------------------------------
function drop_cn_iptables(){

    echo "データー取得中: ${APNIC_URL}"
    if curl -s ${APNIC_URL} > /tmp/delegated-apnic-latest
    then
        echo "iptables 設定中: しばらく時間がかかります"
        iptables -D INPUT -j DROP-${COUNTRY} > /dev/null 2>&1
        iptables -F DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -X DROP-${COUNTRY}          > /dev/null 2>&1
        iptables -N DROP-${COUNTRY}
        COUNT=0
        for i in $(awk -F'|' '$2~/'${COUNTRY}'/&&$3~/ipv4/{print $4","$5}' /tmp/delegated-apnic-latest)
        do
            IP_LIST_1=$(echo $i | cut -d',' -f1)
            IP_LIST_2=$(echo $i | cut -d',' -f2)
            IP_CO_LIST=$(cider_calc $IP_LIST_1 $IP_LIST_2)

            if [ ${IP_CO_LIST} != 'null' ];then
                iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP
                echo_erase "iptables -A DROP-${COUNTRY} -s ${IP_CO_LIST} -j DROP"
                echo "${IP_CO_LIST} - ${COUNTRY}" >> /var/log/blocked_ips.log
            fi

        done
        iptables -A DROP-${COUNTRY} -j RETURN
        iptables -I INPUT 1    -j DROP-${COUNTRY}
        iptables -nvxL
        rm -rf /tmp/delegated-apnic-latest
    else
        echo "データー取得失敗:${APNIC_URL}"
        exit 1
    fi
}

#------------------------------------------
# iptables の初期化
#------------------------------------------
function init_cn_iptables(){

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
function cider_calc(){

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
drop_cn_iptables
echo -e '\n==================================================\n'
echo -e "### 設定完了 ###\n"
echo -e '現在の設定で問題がなければ120秒以内に「 Ctrl + c 」で抜けてセーブして下さい。\n'
sleep 120
init_cn_iptables
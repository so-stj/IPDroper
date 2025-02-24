#!/bin/bash

# iptablesの設定を表示する
echo "現在の iptables 設定を表示します..."
sudo iptables -L -v -n
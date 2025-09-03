# IPDroper

<div id="top"></div>

[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)
[![ipset](https://img.shields.io/badge/ipset-4.0+-blue.svg)](https://ipset.netfilter.org/)

地域インターネットレジストリ（RIR）データを使用してiptablesルールでIPアドレスを国別にブロックするための強力なbashベースツールです。IPDroperを使用すると、Linuxシステムへの特定の国からのIP範囲全体のアクセスを簡単にブロックできます。

** 2つのバージョンが利用可能:**
- **従来版（iptables）** - 直接iptablesルールを使用する標準的なアプローチ
- **高性能ipset版** - 大幅なパフォーマンス向上を実現する高度なアプローチ

## 目次

- [説明](#説明)
- [バージョン比較](#バージョン比較)
- [機能](#機能)
- [前提条件](#前提条件)
- [インストール](#インストール)
- [使用方法](#使用方法)
- [スクリプト概要](#スクリプト概要)
- [ディレクトリ構造](#ディレクトリ構造)
- [トラブルシューティング](#トラブルシューティング)
- [貢献](#貢献)
- [ライセンス](#ライセンス)

## 説明

IPDroperは、Linuxシステムでiptablesを使用して国別にIPアドレスをブロックするプロセスを簡素化する包括的なbashスクリプトスイートです。地域インターネットレジストリ（RIR）のデータを活用して、国全体のIP範囲をブロックするためのiptablesルールを自動的に生成・管理します。

このツールは主要なRIRをすべてサポートしています：
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## バージョン比較

| 項目 | 従来版（iptables） | ipset版 | 改善率 |
|------|------------------|---------|--------|
| ルール数 | 数千〜数万 | 1 (+ipset内のIP) | **99%削減** |
| ルックアップ速度 | 線形検索 | ハッシュ検索 | **10-100倍高速** |
| メモリ使用量 | 多い | 少ない | **50-80%削減** |
| 更新速度 | 遅い | 高速 | **5-10倍高速** |
| 管理の容易さ | 困難 | 簡単 | **大幅改善** |

### なぜipset版を選ぶのか？

1. **ハッシュテーブルベース**: 数千のIP範囲でも高速なルックアップ
2. **メモリ効率**: 従来のiptables方式と比較して大幅なメモリ削減
3. **単一ルール**: 数千のIP範囲でも1つのiptablesルールで管理
4. **動的更新**: ルールを再読み込みせずにIPリストを更新

## 機能

- **国別IPブロック** - ISO 3166-1 alpha-2国コードを使用して国全体をブロック
- **マルチRIRサポート** - 主要な地域インターネットレジストリすべてに対応
- **簡単な管理** - すべての操作のためのシンプルなメニュー駆動インターフェース
- **リアルタイム監視** - 現在のiptablesルールと統計を表示
- **柔軟な削除** - 不要になった国ブロックを簡単に削除
- **自動CIDR計算** - IP範囲をCIDR表記に自動変換
- **検証機能** - 国コードを検証し、適切なiptablesチェーン管理を保証
- **高性能ipsetオプション** - ハッシュテーブルベースのIP管理による高度なバージョン
- **メモリ効率** - ipset版で50-80%のメモリ削減

## 前提条件

### 従来版
- Linuxオペレーティングシステム
- Bashシェル
- `iptables`がインストールされ設定されていること
- RIRデータのダウンロード用の`curl`
- iptables操作のためのroot/sudo権限

### ipset版
- Linuxオペレーティングシステム（カーネル2.6.39以上）
- Bashシェル
- `ipset`がインストールされ設定されていること
- `iptables`がインストールされ設定されていること
- RIRデータのダウンロード用の`curl`
- ipsetとiptables操作のためのroot/sudo権限

## インストール

### 従来版

1. **リポジトリをクローン:**
   ```bash
   git clone https://github.com/yourusername/IPDroper.git
   cd IPDroper
   ```

2. **スクリプトを実行可能にする:**
   ```bash
   chmod +x setup.sh
   chmod +x scripts/*.sh
   ```

3. **セットアップスクリプトを実行:**
   ```bash
   ./setup.sh
   ```

### ipset版

1. **リポジトリをクローン:**
   ```bash
   git clone https://github.com/yourusername/IPDroper.git
   cd IPDroper
   ```

2. **スクリプトを実行可能にする:**
   ```bash
   chmod +x *.sh
   chmod +x scripts/*.sh
   ```

3. **ipsetをインストール（初回のみ）:**
   ```bash
   sudo ./install_ipset.sh
   ```

4. **IPDroperを開始:**
   ```bash
   sudo ./setup_ipset.sh
   ```

## 使用方法

### 従来版

1. **メインのセットアップスクリプトを実行:**
   ```bash
   sudo ./setup.sh
   ```

2. **メニューからオプションを選択:**
   - **1** - ドロップスクリプトを追加（国をブロック）
   - **2** - ドロップチェーンスクリプトを削除（国のブロックを解除）
   - **3** - 現在のiptablesスクリプトを表示（ルールを表示）

### ipset版

1. **ipsetセットアップスクリプトを実行:**
   ```bash
   sudo ./setup_ipset.sh
   ```

2. **メニューからオプションを選択:**
   - **1** - ipsetを使用して国ブロックを追加
   - **2** - 国ブロックを削除
   - **3** - 現在のipsetとiptablesルールを表示

### 国のブロック

1. セットアップメニューからオプション **1** を選択
2. 地域インターネットレジストリを選択（1-5）
3. 国のalpha-2コードを入力（例：中国は`CN`、ロシアは`RU`）
4. 操作を確認

**例:**
```bash
# 従来版
sudo ./scripts/iptablesConfiguration.sh
# 選択: 1 (APNIC)
# 国コードを入力: CN

# ipset版
sudo ./setup_ipset.sh
# 選択: 1 (国ブロックを追加)
# RIRを選択: 1 (APNIC)
# 国コードを入力: CN
```

### 国のブロック解除

1. セットアップメニューからオプション **2** を選択
2. 国のalpha-2コードを入力
3. スクリプトが自動的にすべての関連ルールを削除

### 現在のルールの表示

1. セットアップメニューからオプション **3** を選択
2. 詳細なルールと統計を表示

## スクリプト概要

### 従来版
- **`setup.sh`** - 従来のiptables操作のためのメインメニュースクリプト
- **`scripts/iptablesConfiguration.sh`** - 直接iptablesルールで国ブロックを追加
- **`scripts/iptablesRemove.sh`** - 国ブロックを削除
- **`scripts/iptablesList.sh`** - 現在のiptablesルールを表示

### ipset版
- **`setup_ipset.sh`** - ipset操作のためのメインメニュースクリプト
- **`install_ipset.sh`** - ipsetのインストールと設定
- **`scripts/iptablesConfiguration.sh`** - ipsetを使用して国ブロックを追加
- **`scripts/iptablesRemove.sh`** - 国ブロックを削除
- **`scripts/iptablesList.sh`** - 現在のipsetとiptablesルールを表示

## ディレクトリ構造

```
IPDroper/
├── README.md                 # このファイル
├── setup.sh                  # 従来版メインメニュー
├── setup_ipset.sh            # ipset版メインメニュー
├── install_ipset.sh          # ipsetインストールスクリプト
├── README_ipset.md           # 詳細なipset版ドキュメント
└── scripts/
    ├── iptablesConfiguration.sh  # 国ブロックを追加
    ├── iptablesRemove.sh         # 国ブロックを削除
    └── iptablesList.sh           # 現在のルールを表示
```

## トラブルシューティング

### よくある問題

**1. 権限が拒否される**
```bash
# sudo権限があることを確認
sudo ./setup.sh
# またはipset版の場合
sudo ./setup_ipset.sh
```

**2. iptablesが見つからない**
```bash
# iptablesをインストール（Ubuntu/Debian）
sudo apt-get install iptables

# iptablesをインストール（CentOS/RHEL）
sudo yum install iptables
```

**3. ipsetが見つからない（ipset版の場合）**
```bash
# インストールスクリプトを実行
sudo ./install_ipset.sh
```

**4. curlが見つからない**
```bash
# curlをインストール（Ubuntu/Debian）
sudo apt-get install curl

# curlをインストール（CentOS/RHEL）
sudo yum install curl
```

**5. 無効な国コード**
- 有効なISO 3166-1 alpha-2国コードを使用していることを確認
- 例：`US`、`CN`、`RU`、`JP`、`DE`

**6. ネットワーク接続の問題**
- インターネット接続を確認
- ファイアウォール設定でアウトバウンド接続が許可されていることを確認
- DNS解決が正常に動作していることを確認

### デバッグモード

詳細な出力を表示するには、スクリプトを直接実行できます：
```bash
# 従来版
sudo bash -x ./scripts/iptablesConfiguration.sh

# ipset版
sudo bash -x ./setup_ipset.sh
```

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。

---

**警告:** このツールはiptablesルールを変更し、ネットワーク接続に影響を与える可能性があります。必ず安全な環境でテストし、iptables設定の適切なバックアップを確保してください。

**注意:** IPDroperは教育とセキュリティ目的で設計されています。このツールを使用する際は、地域の法律や規制に準拠していることを確認してください。

**パフォーマンスのヒント:** 本番環境や多くの国ブロックを持つシステムでは、ipset版の使用を検討してください。大幅なパフォーマンス向上と管理の簡素化を実現できます。
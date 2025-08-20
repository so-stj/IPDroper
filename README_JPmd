# IPDroper

<div id="top"></div>

[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)

地域インターネットレジストリ（RIR）データを使用してiptablesルールでIPアドレスを国別にブロックするための強力なbashベースツールです。IPDroperを使用すると、Linuxシステムへの特定の国からのIP範囲全体のアクセスを簡単にブロックできます。

## 📋 目次

- [説明](#説明)
- [機能](#機能)
- [前提条件](#前提条件)
- [インストール](#インストール)
- [使用方法](#使用方法)
- [スクリプト概要](#スクリプト概要)
- [ディレクトリ構造](#ディレクトリ構造)
- [トラブルシューティング](#トラブルシューティング)
- [貢献](#貢献)
- [ライセンス](#ライセンス)

## 📖 説明

IPDroperは、Linuxシステムでiptablesを使用して国別にIPアドレスをブロックするプロセスを簡素化する包括的なbashスクリプトスイートです。地域インターネットレジストリ（RIR）のデータを活用して、国全体のIP範囲をブロックするためのiptablesルールを自動的に生成・管理します。

このツールは主要なRIRをすべてサポートしています：
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## ✨ 機能

- 🔒 **国別IPブロック** - ISO 3166-1 alpha-2国コードを使用して国全体をブロック
- 🌍 **マルチRIRサポート** - 主要な地域インターネットレジストリすべてに対応
- 🛠️ **簡単な管理** - すべての操作のためのシンプルなメニュー駆動インターフェース
- 📊 **リアルタイム監視** - 現在のiptablesルールと統計を表示
- 🔄 **柔軟な削除** - 不要になった国ブロックを簡単に削除
- ⚡ **自動CIDR計算** - IP範囲をCIDR表記に自動変換
- 🛡️ **検証機能** - 国コードを検証し、適切なiptablesチェーン管理を保証

## 🔧 前提条件

- Linuxオペレーティングシステム
- Bashシェル
- `iptables`がインストールされ設定されていること
- RIRデータのダウンロード用の`curl`
- iptables操作のためのroot/sudo権限

## 📦 インストール

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

## 🚀 使用方法

### クイックスタート

1. **メインのセットアップスクリプトを実行:**
   ```bash
   sudo ./setup.sh
   ```

2. **メニューからオプションを選択:**
   - **1** - ドロップスクリプトを追加（国をブロック）
   - **2** - ドロップチェーンスクリプトを削除（国のブロックを解除）
   - **3** - 現在のiptablesスクリプトを表示（ルールを表示）

### 国のブロック

1. セットアップメニューからオプション **1** を選択
2. 地域インターネットレジストリを選択（1-5）
3. 国のalpha-2コードを入力（例：中国は`CN`、ロシアは`RU`）
4. 操作を確認

**例:**
```bash
# APNICデータを使用して中国をブロック
sudo ./scripts/iptablesConfiguration.sh
# 選択: 1 (APNIC)
# 国コードを入力: CN
```

### 国のブロック解除

1. セットアップメニューからオプション **2** を選択
2. 国のalpha-2コードを入力
3. スクリプトが関連するすべてのiptablesルールを自動的に削除

### 現在のルールの表示

1. セットアップメニューからオプション **3** を選択
2. 詳細なiptablesルールと統計を表示

## 📁 スクリプト概要

### `setup.sh`
すべてのIPDroper機能にアクセスするためのインタラクティブインターフェースを提供するメインメニュースクリプト。

### `scripts/iptablesConfiguration.sh`
- 選択されたRIRから国のIPデータをダウンロード
- IP範囲のCIDR表記を計算
- ブロック用のiptablesチェーンとルールを作成
- 主要なRIRすべてをサポート（APNIC、RIPE-NCC、ARIN、LACNIC、AFRINIC）

### `scripts/iptablesRemove.sh`
- ISO 3166-1 alpha-2標準を使用して国コードを検証
- 指定された国のすべてのiptablesルールを削除
- チェーンと参照をクリーンアップ

### `scripts/iptablesList.sh`
- 詳細な出力で現在のiptablesルールを表示
- パケット数とルール統計を表示

## 📂 ディレクトリ構造

```
IPDroper/
├── README.md                 # このファイル
├── setup.sh                  # メインメニュースクリプト
└── scripts/
    ├── iptablesConfiguration.sh  # 国ブロックを追加
    ├── iptablesRemove.sh         # 国ブロックを削除
    └── iptablesList.sh           # 現在のルールを表示
```

## 🔍 トラブルシューティング

### よくある問題

**1. 権限が拒否されました**
```bash
# sudo権限があることを確認
sudo ./setup.sh
```

**2. iptablesが見つかりません**
```bash
# iptablesをインストール（Ubuntu/Debian）
sudo apt-get install iptables

# iptablesをインストール（CentOS/RHEL）
sudo yum install iptables
```

**3. curlが見つかりません**
```bash
# curlをインストール（Ubuntu/Debian）
sudo apt-get install curl

# curlをインストール（CentOS/RHEL）
sudo yum install curl
```

**4. 無効な国コード**
- 有効なISO 3166-1 alpha-2国コードを使用していることを確認
- 例：`US`、`CN`、`RU`、`JP`、`DE`

**5. ネットワーク接続の問題**
- インターネット接続を確認
- ファイアウォール設定でアウトバウンド接続が許可されていることを確認
- DNS解決が正常に動作していることを確認

### デバッグモード

詳細な出力を表示するには、スクリプトを直接実行できます：
```bash
sudo bash -x ./scripts/iptablesConfiguration.sh
```

## 🤝 貢献

貢献を歓迎します！プルリクエストを自由に送信してください。大きな変更の場合は、まずイシューを開いて変更内容について話し合ってください。

## 📄 ライセンス

このプロジェクトはMITライセンスの下でライセンスされています - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

---

**⚠️ 警告:** このツールはiptablesルールを変更し、ネットワーク接続に影響を与える可能性があります。必ず安全な環境でテストし、iptables設定の適切なバックアップを確保してください。

**📝 注意:** IPDroperは教育およびセキュリティ目的で設計されています。このツールを使用する際は、現地の法律や規制への準拠を確認してください。

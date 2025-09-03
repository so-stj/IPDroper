# IPDroper

<div id="top"></div>

=======

[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)

A powerful bash-based tool for managing iptables rules to block IP addresses by country using Regional Internet Registry (RIR) data. IPDroper allows you to easily block entire countries' IP ranges from accessing your Linux system.

## Language

For Japanese README is [here](https://github.com/so-stj/IPDroper/blob/main/README_JP.md)


[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)


A powerful bash-based tool for managing iptables rules to block IP addresses by country using Regional Internet Registry (RIR) data. IPDroper allows you to easily block entire countries' IP ranges from accessing your Linux system.

## 📋 Table of Contents

- [Description](#description)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
- [Directory Structure](#directory-structure)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## 📖 Description

IPDroper is a comprehensive bash script suite that simplifies the process of blocking IP addresses by country using iptables on Linux systems. It leverages data from Regional Internet Registries (RIRs) to automatically generate and manage iptables rules for blocking entire country IP ranges.

The tool supports all major RIRs:
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## ✨ Features

- 🔒 **Country-based IP blocking** - Block entire countries using ISO 3166-1 alpha-2 country codes
- 🌍 **Multi-RIR support** - Works with all major Regional Internet Registries
- 🛠️ **Easy management** - Simple menu-driven interface for all operations
- 📊 **Real-time monitoring** - View current iptables rules and statistics
- 🔄 **Flexible removal** - Easily remove country blocks when no longer needed
- ⚡ **Automatic CIDR calculation** - Converts IP ranges to CIDR notation automatically
- 🛡️ **Validation** - Validates country codes and ensures proper iptables chain management

## 🔧 Prerequisites

- Linux operating system
- Bash shell
- `iptables` installed and configured
- `curl` for downloading RIR data
- Root/sudo privileges for iptables operations

## 📦 Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/IPDroper.git
   cd IPDroper
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x setup.sh
   chmod +x scripts/*.sh
   ```

3. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

## 🚀 Usage

### Quick Start

1. **Run the main setup script:**
   ```bash
   sudo ./setup.sh
   ```

2. **Select an option from the menu:**
   - **1** - Add drop script (block a country)
   - **2** - Delete drop chain script (unblock a country)
   - **3** - Show current iptables script (view rules)

### Blocking a Country

1. Select option **1** from the setup menu
2. Choose your Regional Internet Registry (1-5)
3. Enter the country's alpha-2 code (e.g., `CN` for China, `RU` for Russia)
4. Confirm the operation

**Example:**
```bash
# Block China using APNIC data
sudo ./scripts/iptablesConfiguration.sh
# Select: 1 (APNIC)
# Enter country code: CN
```

### Unblocking a Country

1. Select option **2** from the setup menu
2. Enter the country's alpha-2 code
3. The script will automatically remove all related iptables rules

### Viewing Current Rules

1. Select option **3** from the setup menu
2. View detailed iptables rules and statistics

## 📁 Scripts Overview

### `setup.sh`
Main menu script that provides an interactive interface to access all IPDroper functionality.

### `scripts/iptablesConfiguration.sh`
- Downloads country IP data from selected RIR
- Calculates CIDR notation for IP ranges
- Creates iptables chains and rules for blocking
- Supports all major RIRs (APNIC, RIPE-NCC, ARIN, LACNIC, AFRINIC)

### `scripts/iptablesRemove.sh`
- Validates country codes using ISO 3166-1 alpha-2 standard
- Removes all iptables rules for specified country
- Cleans up chains and references

### `scripts/iptablesList.sh`
- Displays current iptables rules with verbose output
- Shows packet counts and rule statistics

## 📂 Directory Structure

```
IPDroper/
├── README.md                 # This file
├── setup.sh                  # Main menu script
└── scripts/
    ├── iptablesConfiguration.sh  # Add country blocks
    ├── iptablesRemove.sh         # Remove country blocks
    └── iptablesList.sh           # View current rules
```

## 🔍 Troubleshooting

### Common Issues

**1. Permission Denied**
```bash
# Ensure you have sudo privileges
sudo ./setup.sh
```

**2. iptables not found**
```bash
# Install iptables (Ubuntu/Debian)
sudo apt-get install iptables

# Install iptables (CentOS/RHEL)
sudo yum install iptables
```

**3. curl not found**
```bash
# Install curl (Ubuntu/Debian)
sudo apt-get install curl

# Install curl (CentOS/RHEL)
sudo yum install curl
```

**4. Invalid country code**
- Ensure you're using valid ISO 3166-1 alpha-2 country codes
- Examples: `US`, `CN`, `RU`, `JP`, `DE`

**5. Network connectivity issues**
- Check your internet connection
- Verify firewall settings allow outbound connections
- Ensure DNS resolution is working

### Debug Mode

To see detailed output, you can run scripts directly:
```bash
sudo bash -x ./scripts/iptablesConfiguration.sh
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**⚠️ Warning:** This tool modifies iptables rules and can affect network connectivity. Always test in a safe environment first and ensure you have proper backups of your iptables configuration.

**📝 Note:** IPDroper is designed for educational and security purposes. Please ensure compliance with local laws and regulations when using this tool.
=======
- [Description](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-description)
- [Features](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-features)
- [Prerequisites](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-prerequisites)
- [Installation](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-installation)
- [Usage](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-usage)
- [Scripts Overview](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-scripts-overview)
- [Directory Structure](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-directory-structure)
- [Troubleshooting](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-troubleshooting)
- [Contributing](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-contributing)
- [License](https://github.com/so-stj/IPDroper?tab=readme-ov-file#-license)

## Description

IPDroper is a comprehensive bash script suite that simplifies the process of blocking IP addresses by country using iptables on Linux systems. It leverages data from Regional Internet Registries (RIRs) to automatically generate and manage iptables rules for blocking entire country IP ranges.

The tool supports all major RIRs:
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## Features

-  **Country-based IP blocking** - Block entire countries using ISO 3166-1 alpha-2 country codes
-  **Multi-RIR support** - Works with all major Regional Internet Registries
- 🛠 **Easy management** - Simple menu-driven interface for all operations
-  **Real-time monitoring** - View current iptables rules and statistics
-  **Flexible removal** - Easily remove country blocks when no longer needed
-  **Automatic CIDR calculation** - Converts IP ranges to CIDR notation automatically
- 🛡 **Validation** - Validates country codes and ensures proper iptables chain management

## Prerequisites

- Linux operating system
- Bash shell
- `iptables` installed and configured
- `curl` for downloading RIR data
- Root/sudo privileges for iptables operations

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/IPDroper.git
   cd IPDroper
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x setup.sh
   chmod +x scripts/*.sh
   ```

3. **Run the setup script:**
   ```bash
   ./setup.sh
   ```

## Usage

### Quick Start

1. **Run the main setup script:**
   ```bash
   sudo ./setup.sh
   ```

2. **Select an option from the menu:**
   - **1** - Add drop script (block a country)
   - **2** - Delete drop chain script (unblock a country)
   - **3** - Show current iptables script (view rules)

### Blocking a Country

1. Select option **1** from the setup menu
2. Choose your Regional Internet Registry (1-5)
3. Enter the country's alpha-2 code (e.g., `CN` for China, `RU` for Russia)
4. Confirm the operation

**Example:**
```bash
# Block China using APNIC data
sudo ./scripts/iptablesConfiguration.sh
# Select: 1 (APNIC)
# Enter country code: CN
```

### Unblocking a Country

1. Select option **2** from the setup menu
2. Enter the country's alpha-2 code
3. The script will automatically remove all related iptables rules

### Viewing Current Rules

1. Select option **3** from the setup menu
2. View detailed iptables rules and statistics

## Scripts Overview

### `setup.sh`
Main menu script that provides an interactive interface to access all IPDroper functionality.

### `scripts/iptablesConfiguration.sh`
- Downloads country IP data from selected RIR
- Calculates CIDR notation for IP ranges
- Creates iptables chains and rules for blocking
- Supports all major RIRs (APNIC, RIPE-NCC, ARIN, LACNIC, AFRINIC)

### `scripts/iptablesRemove.sh`
- Validates country codes using ISO 3166-1 alpha-2 standard
- Removes all iptables rules for specified country
- Cleans up chains and references

### `scripts/iptablesList.sh`
- Displays current iptables rules with verbose output
- Shows packet counts and rule statistics

## Directory Structure

```
IPDroper/
├── README.md                 # This file
├── setup.sh                  # Main menu script
└── scripts/
    ├── iptablesConfiguration.sh  # Add country blocks
    ├── iptablesRemove.sh         # Remove country blocks
    └── iptablesList.sh           # View current rules
```

## Troubleshooting

### Common Issues

**1. Permission Denied**
```bash
# Ensure you have sudo privileges
sudo ./setup.sh
```

**2. iptables not found**
```bash
# Install iptables (Ubuntu/Debian)
sudo apt-get install iptables

# Install iptables (CentOS/RHEL)
sudo yum install iptables
```

**3. curl not found**
```bash
# Install curl (Ubuntu/Debian)
sudo apt-get install curl

# Install curl (CentOS/RHEL)
sudo yum install curl
```

**4. Invalid country code**
- Ensure you're using valid ISO 3166-1 alpha-2 country codes
- Examples: `US`, `CN`, `RU`, `JP`, `DE`

**5. Network connectivity issues**
- Check your internet connection
- Verify firewall settings allow outbound connections
- Ensure DNS resolution is working

### Debug Mode

To see detailed output, you can run scripts directly:
```bash
sudo bash -x ./scripts/iptablesConfiguration.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

** Warning:** This tool modifies iptables rules and can affect network connectivity. Always test in a safe environment first and ensure you have proper backups of your iptables configuration.

** Note:** IPDroper is designed for educational and security purposes. Please ensure compliance when using this tool.

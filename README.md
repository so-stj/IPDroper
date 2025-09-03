# IPDroper

<div id="top"></div>

[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)
[![ipset](https://img.shields.io/badge/ipset-4.0+-blue.svg)](https://ipset.netfilter.org/)

A powerful bash-based tool for managing iptables rules to block IP addresses by country using Regional Internet Registry (RIR) data. IPDroper allows you to easily block entire countries' IP ranges from accessing your Linux system.

**Two versions available:**
- **Traditional iptables version** - Standard approach with direct iptables rules
- **High-performance ipset version** - Advanced approach with significant performance improvements

## Language

For Japanese README is [here](https://github.com/so-stj/IPDroper/blob/main/README_JP.md)

## Table of Contents

- [Description](#description)
- [Versions Comparison](#versions-comparison)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
- [Directory Structure](#directory-structure)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Description

IPDroper is a comprehensive bash script suite that simplifies the process of blocking IP addresses by country using iptables on Linux systems. It leverages data from Regional Internet Registries (RIRs) to automatically generate and manage iptables rules for blocking entire country IP ranges.

The tool supports all major RIRs:
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## Versions Comparison

| Feature | iptable Version| ipset Version |
|---------|--------------------------------|---------------|
| Rule Count | Thousands to tens of thousands | 1 (+ IPs in ipset) |
| Lookup Speed | Linear search | Hash-based search |
| Memory Usage | High | Low |
| Update Speed | Slow | Fast |
| Management | Complex | Simple |

### Why Choose ipset Version?

1. **Hash-table based**: Fast lookup even with thousands of IP ranges
2. **Memory efficient**: Significant memory reduction compared to traditional iptables
3. **Single rule**: Manage thousands of IP ranges with just one iptables rule
4. **Dynamic updates**: Update IP lists without reloading rules

## Features

-  **Country-based IP blocking** - Block entire countries using ISO 3166-1 alpha-2 country codes
-  **Multi-RIR support** - Works with all major Regional Internet Registries
-  **Easy management** - Simple menu-driven interface for all operations
-  **Flexible removal** - Easily remove country blocks when no longer needed
-  **Automatic CIDR calculation** - Converts IP ranges to CIDR notation automatically
-  **Validation** - Validates country codes and ensures proper iptables chain management
-  **High-performance ipset option** - Advanced version with hash-table based IP management

## Prerequisites

### iptable Version
- Linux operating system
- Bash shell
- `iptables` installed and configured
- `curl` for downloading RIR data
- Root/sudo privileges for iptables operations

### ipset Version
- Linux operating system (kernel 2.6.39+)
- Bash shell
- `ipset` installed and configured
- `iptables` installed and configured
- `curl` for downloading RIR data
- Root/sudo privileges for ipset and iptables operations

## Installation

### iptable Version

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

### ipset Version

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/IPDroper.git
   cd IPDroper
   ```

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   chmod +x scripts/*.sh
   ```

3. **Install ipset (first time only):**
   ```bash
   sudo ./install_ipset.sh
   ```

4. **Start IPDroper:**
   ```bash
   sudo ./setup_ipset.sh
   ```

## Usage

### iptable Version

1. **Run the main setup script:**
   ```bash
   sudo ./setup.sh
   ```

2. **Select an option from the menu:**
   - **1** - Add drop script (block a country)
   - **2** - Delete drop chain script (unblock a country)
   - **3** - Show current iptables script (view rules)

### ipset Version

1. **Run the ipset setup script:**
   ```bash
   sudo ./setup_ipset.sh
   ```

2. **Select an option from the menu:**
   - **1** - Add country block using ipset
   - **2** - Remove country block
   - **3** - Show current ipset and iptables rules

### Blocking a Country

1. Select option **1** from the setup menu
2. Choose your Regional Internet Registry (1-5)
3. Enter the country's alpha-2 code (e.g., `CN` for China, `RU` for Russia)
4. Confirm the operation

**Example:**
```bash
# Traditional version
sudo ./scripts/iptablesConfiguration.sh
# Select: 1 (APNIC)
# Enter country code: CN

# ipset version
sudo ./setup_ipset.sh
# Select: 1 (Add country block)
# Select RIR: 1 (APNIC)
# Enter country code: CN
```

### Unblocking a Country

1. Select option **2** from the setup menu
2. Enter the country's alpha-2 code
3. The script will automatically remove all related rules

### Viewing Current Rules

1. Select option **3** from the setup menu
2. View detailed rules and statistics

## Scripts Overview

### iptable Version
- **`setup.sh`** - Main menu script for traditional iptables operations
- **`scripts/iptablesConfiguration.sh`** - Add country blocks with direct iptables rules
- **`scripts/iptablesRemove.sh`** - Remove country blocks
- **`scripts/iptablesList.sh`** - View current iptables rules

### ipset Version
- **`setup_ipset.sh`** - Main menu script for ipset operations
- **`install_ipset.sh`** - Install and configure ipset
- **`scripts/iptablesConfiguration.sh`** - Add country blocks using ipset
- **`scripts/iptablesRemove.sh`** - Remove country blocks
- **`scripts/iptablesList.sh`** - View current ipset and iptables rules

## Directory Structure

```
IPDroper/
├── README.md                 # This file
├── setup.sh                  # Traditional version main menu
├── setup_ipset.sh            # ipset version main menu
├── install_ipset.sh          # ipset installation script
├── README_ipset.md           # Detailed ipset version documentation
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
# or for ipset version
sudo ./setup_ipset.sh
```

**2. iptables not found**
```bash
# Install iptables (Ubuntu/Debian)
sudo apt-get install iptables

# Install iptables (CentOS/RHEL)
sudo yum install iptables
```

**3. ipset not found (for ipset version)**
```bash
# Run the installation script
sudo ./install_ipset.sh
```

**4. curl not found**
```bash
# Install curl (Ubuntu/Debian)
sudo apt-get install curl

# Install curl (CentOS/RHEL)
sudo yum install curl
```

**5. Invalid country code**
- Ensure you're using valid ISO 3166-1 alpha-2 country codes
- Examples: `US`, `CN`, `RU`, `JP`, `DE`

**6. Network connectivity issues**
- Check your internet connection
- Verify firewall settings allow outbound connections
- Ensure DNS resolution is working

### Debug Mode

To see detailed output, you can run scripts directly:
```bash
# Traditional version
sudo bash -x ./scripts/iptablesConfiguration.sh

# ipset version
sudo bash -x ./setup_ipset.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Warning:** This tool modifies iptables rules and can affect network connectivity. Always test in a safe environment first and ensure you have proper backups of your iptables configuration.

**Note:** IPDroper is designed for educational and security purposes. Please ensure compliance with local laws and regulations when using this tool.

**Performance Tip:** For production environments or systems with many country blocks, consider using the ipset version for significantly better performance and easier management.

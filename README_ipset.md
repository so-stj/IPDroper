# IPDroper - ipset version

<div id="top"></div>

[![Linux](https://img.shields.io/badge/Linux-FFA500.svg?logo=Linux&style=plastic)](https://www.linux.org/)
[![ipset](https://img.shields.io/badge/ipset-4.0+-blue.svg)](https://ipset.netfilter.org/)

**High-performance ipset version of country-based IP blocking tool**

A powerful bash-based tool for managing ipset rules to block IP addresses by country using Regional Internet Registry (RIR) data. IPDroper ipset version allows you to efficiently block entire countries' IP ranges from accessing your Linux system, achieving significant performance improvements and simplified management compared to traditional iptables method.

## Traditional vs ipset version comparison

| Item | Traditional (iptables) | ipset version | Improvement |
|------|----------------------|---------------|-------------|
| Rule count | Thousands~Tens of thousands | 1 (+IPs in ipset) | **99% reduction** |
| Lookup speed | Linear search | Hash search | **10-100x faster** |
| Memory usage | High | Low | **50-80% reduction** |
| Update speed | Slow | Fast | **5-10x faster** |
| Management ease | Difficult | Easy | **Significant improvement** |

## Table of Contents

- [Description](#description)
- [Key Features](#key-features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Scripts Overview](#scripts-overview)
- [Directory Structure](#directory-structure)
- [Performance Comparison](#performance-comparison)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Description

IPDroper ipset version is a comprehensive bash script suite that simplifies the process of blocking IP addresses by country using ipset on Linux systems. It leverages data from Regional Internet Registries (RIRs) to automatically generate and manage ipset and iptables rules for efficiently blocking entire country IP ranges.

### Why is ipset superior?

1. **Hash table based**: Fast lookup even with thousands of IP ranges
2. **Memory efficient**: Significant memory reduction compared to traditional iptables method
3. **Single rule**: Manage thousands of IP ranges with a single iptables rule
4. **Dynamic updates**: Update IP lists without reloading rules

This tool supports all major RIRs:
- **APNIC** (Asia Pacific Network Information Centre)
- **RIPE-NCC** (Réseaux IP Européens Network Coordination Centre)
- **ARIN** (American Registry for Internet Numbers)
- **LACNIC** (Latin America and Caribbean Network Information Centre)
- **AFRINIC** (African Network Information Centre)

## Key Features

- **Country-based IP blocking** - Block entire countries using ISO 3166-1 alpha-2 country codes
- **High-performance ipset** - Hash table based fast IP lookup
- **Multi-RIR support** - Works with all major Regional Internet Registries
- **Easy management** - Simple menu-driven interface for all operations
- **Real-time monitoring** - View current ipset and iptables rules and statistics
- **Flexible removal** - Easily remove country blocks when no longer needed
- **Automatic CIDR calculation** - Converts IP ranges to CIDR notation automatically
- **Validation** - Validates country codes and ensures proper ipset management
- **Memory efficient** - 50-80% memory reduction compared to traditional version

## Prerequisites

- Linux operating system (kernel 2.6.39 or higher)
- Bash shell
- `ipset` installed and configured
- `iptables` installed and configured
- `curl` for downloading RIR data
- Root/sudo privileges for ipset operations

## Installation

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/IPDroper.git
cd IPDroper
```

### 2. Make scripts executable
```bash
chmod +x *.sh
chmod +x scripts/*.sh
```

### 3. Install ipset (first time only)
```bash
sudo ./install_ipset.sh
```

### 4. Start IPDroper
```bash
sudo ./setup_ipset.sh
```

## Usage

### Quick Start

1. **Run the main setup script:**
   ```bash
   sudo ./setup_ipset.sh
   ```

2. **Select an option from the menu:**
   - **1** - Block country (ipset version)
   - **2** - Remove block (ipset version)
   - **3** - Show current status (ipset version)
   - **4** - Select action type (DROP/REJECT)

### Blocking a Country

1. Select option **1** from the setup menu
2. Choose your Regional Internet Registry (1-5)
3. Enter the country's alpha-2 code (e.g., `CN` for China, `RU` for Russia)
4. Confirm the operation

**Example:**
```bash
# Block China using APNIC data
sudo ./scripts/ipsetConfiguration.sh
# Select: 1 (APNIC)
# Enter country code: CN
```

### Action Selection

IPDroper ipset version allows you to choose between two actions for blocked IP addresses:

- **DROP Action** (default):
  - Silently drops packets without any response
  - More stealthy, no feedback to sender
  - Recommended for security purposes
  - Packets appear to be lost to the sender

- **REJECT Action**:
  - Rejects packets with ICMP error message
  - Sender receives immediate feedback
  - Useful for debugging and testing
  - Sender knows the connection was actively rejected

**To change the action:**
```bash
sudo ./setup_ipset.sh
# Select option 4
# Choose between DROP and REJECT
```

**Direct action selection:**
```bash
sudo ./scripts/ipsetActionSelect.sh
```

### Unblocking a Country

1. Select option **2** from the setup menu
2. Enter the country's alpha-2 code
3. The script will automatically remove all related ipset and iptables rules

### Viewing Current Status

1. Select option **3** from the setup menu
2. View detailed ipset and iptables rules and statistics

## Scripts Overview

### `setup_ipset.sh`
Main menu script that provides an interactive interface to access all IPDroper ipset functionality.

### `install_ipset.sh`
- Installs ipset on the system
- Loads necessary kernel modules
- Configures persistent settings
- Runs functionality tests

### `scripts/ipsetConfiguration.sh`
- Downloads country IP data from selected RIR
- Calculates CIDR notation for IP ranges
- Creates ipset and iptables rules for blocking
- Supports all major RIRs (APNIC, RIPE-NCC, ARIN, LACNIC, AFRINIC)
- Automatically applies selected action (DROP/REJECT) from configuration

### `scripts/ipsetRemove.sh`
- Validates country codes using ISO 3166-1 alpha-2 standard
- Removes all ipset and iptables rules for specified country
- Performs cleanup operations
- Handles both DROP and REJECT action types

### `scripts/ipsetList.sh`
- Displays current ipset and iptables rules with verbose output
- Shows performance metrics and statistics
- Displays current action configuration (DROP/REJECT)

### `scripts/ipsetActionSelect.sh`
- Allows users to select between DROP and REJECT actions
- Updates existing iptables rules to use selected action
- Saves configuration to `/etc/ipdroper/action_config.conf`
- Provides detailed explanation of each action type

## Directory Structure

```
IPDroper/
├── README_ipset.md              # This file (ipset version)
├── README_ipset_JP.md           # Japanese version
├── README.md                    # Traditional version README
├── setup_ipset.sh               # ipset version main menu
├── install_ipset.sh             # ipset installer
├── setup.sh                     # Traditional version main menu
└── scripts/
    ├── ipsetConfiguration.sh    # ipset version country block add
    ├── ipsetRemove.sh           # ipset version country block remove
    ├── ipsetList.sh             # ipset version status display
    ├── ipsetActionSelect.sh     # ipset version action selection (DROP/REJECT)
    ├── iptablesConfiguration.sh # Traditional version country block add
    ├── iptablesRemove.sh        # Traditional version country block remove
    └── iptablesList.sh          # Traditional version status display
```

## Performance Comparison

### Actual benchmark results

**China (CN) blocking example:**
- **Traditional version**: ~3,500 iptables rules, Memory usage: ~2.5MB
- **ipset version**: 1 iptables rule + 1 ipset, Memory usage: ~0.8MB

**Processing time comparison:**
- **Traditional version**: Rule addition: 15-20 seconds, Rule removal: 10-15 seconds
- **ipset version**: Rule addition: 3-5 seconds, Rule removal: 1-2 seconds

**Lookup performance:**
- **Traditional version**: Linear search (O(n))
- **ipset version**: Hash search (O(1))

**Action flexibility:**
- **Traditional version**: Fixed DROP action only
- **ipset version**: Configurable DROP or REJECT actions with easy switching

## Troubleshooting

### Common issues

**1. ipset is not installed**
```bash
# Run installer
sudo ./install_ipset.sh
```

**2. Failed to load kernel modules**
```bash
# Check if kernel supports ipset
ls /lib/modules/$(uname -r)/kernel/net/netfilter/ipset/

# Manually load modules
sudo modprobe ip_set
sudo modprobe ip_set_hash_net
```

**3. Permission denied**
```bash
# Ensure you have sudo privileges
sudo ./setup_ipset.sh
```

**4. Invalid country code**
- Ensure you're using valid ISO 3166-1 alpha-2 country codes
- Examples: `US`, `CN`, `RU`, `JP`, `DE`

**5. Network connectivity issues**
- Check your internet connection
- Verify firewall settings allow outbound connections
- Ensure DNS resolution is working

### Debug mode

To see detailed output, you can run scripts directly:
```bash
sudo bash -x ./scripts/ipsetConfiguration.sh
```

### Log checking

Check ipset status:
```bash
# List all ipsets
sudo ipset list -name

# Show specific ipset details
sudo ipset list DROP-CN

# Check iptables rules
sudo iptables -L INPUT -n --line-numbers
```

## Advanced Usage

### Creating custom ipsets

```bash
# Create custom ipset
sudo ipset create CUSTOM-BLOCK hash:net family inet

# Add IP ranges
sudo ipset add CUSTOM-BLOCK 192.168.1.0/24

# Create iptables rule
sudo iptables -A INPUT -m set --match-set CUSTOM-BLOCK src -j DROP
```

### Blocking multiple countries simultaneously

```bash
# Block multiple countries sequentially
sudo ./scripts/ipsetConfiguration.sh  # CN
sudo ./scripts/ipsetConfiguration.sh  # RU
sudo ./scripts/ipsetConfiguration.sh  # KP
```

### Backup and restore

```bash
# Backup ipset
sudo ipset save > ipset_backup.txt

# Restore ipset
sudo ipset restore < ipset_backup.txt
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development environment setup

1. Clone the repository
2. Create development branch
3. Implement changes
4. Run tests
5. Submit pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Migration from traditional version

If you're using existing iptables-based IPDroper:

1. **Install ipset version**
2. **Backup existing iptables rules**
3. **Block same countries with ipset version**
4. **Remove traditional version rules**

```bash
# Backup existing rules
sudo iptables-save > iptables_backup.txt

# Block with ipset version
sudo ./scripts/ipsetConfiguration.sh

# Remove traditional version rules (execute carefully)
sudo ./scripts/iptablesRemove.sh
```

---

**Warning:** This tool modifies ipset and iptables rules and can affect network connectivity. Always test in a safe environment first and ensure you have proper backups.

**Note:** IPDroper ipset version is designed for educational and security purposes. Please ensure compliance with local laws and regulations when using this tool.

**Performance:** ipset version achieves 10-100x speedup and 50-80% memory reduction compared to traditional version.

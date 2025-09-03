#!/bin/bash

# IPDroper - ipset installation script
# This script installs and configures ipset for IPDroper

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to detect Linux distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/redhat-release ]; then
        echo "rhel"
    elif [ -f /etc/debian_version ]; then
        echo "debian"
    else
        echo "unknown"
    fi
}

# Function to install ipset on Ubuntu/Debian
install_ipset_debian() {
    print_status $BLUE "📦 Detected Debian/Ubuntu-based distribution"
    
    # Update package list
    print_status $YELLOW "Updating package list..."
    apt-get update
    
    # Install ipset
    print_status $YELLOW "Installing ipset..."
    apt-get install -y ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "Installing iptables..."
        apt-get install -y iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "Installing curl..."
        apt-get install -y curl
    fi
}

# Function to install ipset on CentOS/RHEL
install_ipset_rhel() {
    print_status $BLUE "📦 Detected CentOS/RHEL-based distribution"
    
    # Install ipset
    print_status $YELLOW "Installing ipset..."
    yum install -y ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "Installing iptables..."
        yum install -y iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "Installing curl..."
        yum install -y curl
    fi
}

# Function to install ipset on Arch Linux
install_ipset_arch() {
    print_status $BLUE "📦 Detected Arch Linux-based distribution"
    
    # Install ipset
    print_status $YELLOW "Installing ipset..."
    pacman -S --noconfirm ipset
    
    # Install iptables if not present
    if ! command -v iptables &> /dev/null; then
        print_status $YELLOW "Installing iptables..."
        pacman -S --noconfirm iptables
    fi
    
    # Install curl if not present
    if ! command -v curl &> /dev/null; then
        print_status $YELLOW "Installing curl..."
        pacman -S --noconfirm curl
    fi
}

# Function to check kernel support
check_kernel_support() {
    print_status $BLUE "🔍 Checking kernel ipset support..."
    
    # Check if ipset modules are available
    if [ -d "/lib/modules/$(uname -r)/kernel/net/netfilter/ipset" ]; then
        print_status $GREEN "✅ Kernel supports ipset"
        return 0
    else
        print_status $RED "❌ Kernel does not support ipset"
        print_status $YELLOW "Kernel recompilation or update may be required"
        return 1
    fi
}

# Function to load ipset modules
load_ipset_modules() {
    print_status $BLUE "📥 Loading ipset kernel modules..."
    
    # Load ipset module
    if modprobe ip_set; then
        print_status $GREEN "✅ ip_set module loaded successfully"
    else
        print_status $RED "❌ Failed to load ip_set module"
        return 1
    fi
    
    # Load hash:net module
    if modprobe ip_set_hash_net; then
        print_status $GREEN "✅ ip_set_hash_net module loaded successfully"
    else
        print_status $RED "❌ Failed to load ip_set_hash_net module"
        return 1
    fi
    
    return 0
}

# Function to configure persistent module loading
configure_persistent_modules() {
    print_status $BLUE "🔧 Configuring persistent module loading..."
    
    local distro=$(detect_distro)
    local modules_file=""
    
    case $distro in
        "ubuntu"|"debian"|"linuxmint")
            modules_file="/etc/modules"
            ;;
        "centos"|"rhel"|"fedora"|"rocky"|"alma")
            modules_file="/etc/modules-load.d/ipset.conf"
            ;;
        "arch"|"manjaro")
            modules_file="/etc/modules-load.d/ipset.conf"
            ;;
        *)
            print_status $YELLOW "⚠️ Manual configuration required for this distribution"
            return 0
            ;;
    esac
    
    # Add modules to the file
    if [ ! -f "$modules_file" ]; then
        touch "$modules_file"
    fi
    
    # Check if modules are already added
    if ! grep -q "ip_set" "$modules_file"; then
        echo "ip_set" >> "$modules_file"
        print_status $GREEN "✅ Added ip_set to $modules_file"
    fi
    
    if ! grep -q "ip_set_hash_net" "$modules_file"; then
        echo "ip_set_hash_net" >> "$modules_file"
        print_status $GREEN "✅ Added ip_set_hash_net to $modules_file"
    fi
    
    print_status $GREEN "✅ Persistent module loading configured"
}

# Function to test ipset functionality
test_ipset() {
    print_status $BLUE "🧪 Testing ipset functionality..."
    
    # Create test ipset
    if ipset create test_set hash:net family inet hashsize 1024 maxelem 65536 2>/dev/null; then
        print_status $GREEN "✅ Successfully created test ipset"
        
        # Add test entry
        if ipset add test_set 192.168.1.0/24 2>/dev/null; then
            print_status $GREEN "✅ Successfully added test entry"
            
            # List test ipset
            if ipset list test_set >/dev/null 2>&1; then
                print_status $GREEN "✅ Successfully listed ipset"
                
                # Remove test ipset
                if ipset destroy test_set 2>/dev/null; then
                    print_status $GREEN "✅ Successfully removed test ipset"
                    return 0
                else
                    print_status $RED "❌ Failed to remove test ipset"
                    return 1
                fi
            else
                print_status $RED "❌ Failed to list ipset"
                return 1
            fi
        else
            print_status $RED "❌ Failed to add test entry"
            ipset destroy test_set 2>/dev/null
            return 1
        fi
    else
        print_status $RED "❌ Failed to create test ipset"
        return 1
    fi
}

# Function to show installation summary
show_summary() {
    print_status $GREEN "🎉 ipset installation completed successfully!"
    echo ""
    echo "📋 Installed packages:"
    echo "  ✅ ipset: $(ipset --version 2>/dev/null | head -1 || echo 'N/A')"
    echo "  ✅ iptables: $(iptables --version 2>/dev/null | head -1 || echo 'N/A')"
    echo "  ✅ curl: $(curl --version 2>/dev/null | head -1 || echo 'N/A')"
    echo ""
    echo "🔧 Configured items:"
    echo "  ✅ Kernel module loading"
    echo "  ✅ Persistent module loading configuration"
    echo "  ✅ ipset functionality test"
    echo ""
    echo "🚀 Next steps:"
    echo "  1. Run sudo ./setup_ipset.sh to start IPDroper"
    echo "  2. For first-time use, start with option 1"
    echo ""
    echo "💡 Help:"
    echo "  ./setup_ipset.sh --help for detailed help"
    echo ""
}

# Main execution
main() {
    print_status $BLUE "🚀 IPDroper - ipset installer"
    echo "=========================================="
    echo "Installing ipset for country-based IP blocking tool"
    echo ""
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        print_status $RED "❌ This script requires root privileges"
        echo "Please use: sudo ./install_ipset.sh"
        exit 1
    fi
    
    # Detect distribution and install packages
    local distro=$(detect_distro)
    case $distro in
        "ubuntu"|"debian"|"linuxmint")
            install_ipset_debian
            ;;
        "centos"|"rhel"|"fedora"|"rocky"|"alma")
            install_ipset_rhel
            ;;
        "arch"|"manjaro")
            install_ipset_arch
            ;;
        *)
            print_status $RED "❌ Unsupported distribution: $distro"
            echo "Please manually install ipset, iptables, and curl"
            exit 1
            ;;
    esac
    
    # Check kernel support
    if ! check_kernel_support; then
        exit 1
    fi
    
    # Load ipset modules
    if ! load_ipset_modules; then
        exit 1
    fi
    
    # Configure persistent module loading
    configure_persistent_modules
    
    # Test ipset functionality
    if ! test_ipset; then
        print_status $RED "❌ ipset functionality test failed"
        exit 1
    fi
    
    # Show installation summary
    show_summary
}

# Run main function
main "$@"

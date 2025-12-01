#!/bin/bash

# 🖥️ System utility functions

# Source print functions (only if not already sourced)
if [ -z "$PRINT_SH_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/print.sh"
fi

# Check if running on Arch Linux
check_arch() {
    if [ ! -f /etc/arch-release ]; then
        print_error "This script is designed for Arch Linux only!"
        exit 1
    fi
}

# Check if a command exists
check_command() {
    local cmd=$1
    local name=$2
    
    if command -v "$cmd" &> /dev/null; then
        print_ok "$name installed"
        return 0
    else
        print_fail "$name not found"
        return 1
    fi
}

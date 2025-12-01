#!/bin/bash

# 📦 Modular installation script
# Usage: ./install.sh [system|apps|aur]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_DIR="$SCRIPT_DIR/helpers"
PACKAGES_DIR="$SCRIPT_DIR/../packages"

# Load helper functions
source "$HELPERS_DIR/print.sh"
source "$HELPERS_DIR/system.sh"
source "$HELPERS_DIR/packages.sh"
source "$HELPERS_DIR/aur.sh"

# Install system packages
install_system() {
    install_system_packages "$PACKAGES_DIR"
}

# Install applications
install_apps() {
    install_app_packages "$PACKAGES_DIR"
}

# Install AUR packages
install_aur() {
    install_aur_packages "$PACKAGES_DIR"
}

# Main
main() {
    check_arch
    
    case "$1" in
        system)
            install_system
            ;;
        apps)
            install_apps
            ;;
        aur)
            install_aur
            ;;
        *)
            print_error "Usage: $0 [system|apps|aur]"
            exit 1
            ;;
    esac
}

main "$@"

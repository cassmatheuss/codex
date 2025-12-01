#!/bin/bash

# 📥 AUR helper functions

# Source print functions (only if not already sourced)
if [ -z "$PRINT_SH_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/print.sh"
fi

# Install yay (AUR helper)
install_yay() {
    print_info "Installing yay... 🦀"
    
    sudo pacman -S --needed --noconfirm git base-devel
    
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
    
    print_info "yay installed successfully! ✅"
}

# Install paru (AUR helper)
install_paru() {
    print_info "Installing paru... 🚀"
    
    sudo pacman -S --needed --noconfirm git base-devel
    
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    
    print_info "paru installed successfully! ✅"
}

# Choose AUR helper
choose_aur_helper() {
    # Check if running in non-interactive mode (CI/Docker)
    if [ ! -t 0 ] || [ -n "$CI" ] || [ -n "$DEBIAN_FRONTEND" ]; then
        print_info "Non-interactive mode detected, installing yay by default..."
        install_yay
        return
    fi
    
    print_question "Which AUR helper do you want to install?"
    echo "  1) 🦀 yay (Go-based, most popular)"
    echo "  2) 🚀 paru (Rust-based, faster)"
    echo ""
    read -t 10 -p "Enter your choice [1-2] (default: 1): " choice || choice=1
    
    # Use default if empty
    choice=${choice:-1}
    
    case $choice in
        1)
            install_yay
            ;;
        2)
            install_paru
            ;;
        *)
            print_warning "Invalid choice, defaulting to yay"
            install_yay
            ;;
    esac
}

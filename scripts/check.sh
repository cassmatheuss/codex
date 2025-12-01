#!/bin/bash

# 🔍 System and dependencies check script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_DIR="$SCRIPT_DIR/helpers"

# Load helper functions
source "$HELPERS_DIR/print.sh"
source "$HELPERS_DIR/system.sh"

main() {
    echo "🖥️  === System Check ==="
    echo ""
    
    # Operating system
    if [ -f /etc/arch-release ]; then
        print_success "Arch Linux detected"
    else
        print_error "Not Arch Linux"
    fi
    
    echo ""
    echo "🔧 === Main Components ==="
    
    # Essential components
    check_command "hyprland" "Hyprland"
    check_command "zsh" "ZSH"
    check_command "wezterm" "WezTerm"
    check_command "wofi" "Wofi"
    check_command "dunst" "Dunst"
    
    echo ""
    echo "🛠️  === Tools ==="
    
    check_command "git" "Git"
    check_command "nvim" "Neovim"
    check_command "yay" "Yay (AUR helper)" || check_command "paru" "Paru (AUR helper)"
    
    echo ""
    echo "📊 === System Information ==="
    print_debug "Default shell: $SHELL"
    print_debug "User: $USER"
    print_debug "Home: $HOME"
    
    echo ""
}

main "$@"

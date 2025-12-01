#!/bin/bash

# 🚀 Configuration deployment script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_DIR="$SCRIPT_DIR/helpers"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_DIR="$DOTFILES_DIR/config"

# Load helper functions
source "$HELPERS_DIR/print.sh"
source "$HELPERS_DIR/config.sh"

# Main configuration setup
setup_configs() {
    print_info "Deploying dotfiles... 📦"
    
    # Hyprland
    if [ -d "$CONFIG_DIR/hyprland" ]; then
        copy_config "$CONFIG_DIR/hyprland" "$HOME/.config/hypr"
    fi
    
    # ZSH
    if [ -f "$CONFIG_DIR/zsh/.zshrc" ]; then
        copy_config "$CONFIG_DIR/zsh/.zshrc" "$HOME/.zshrc"
    fi
    
    if [ -d "$CONFIG_DIR/zsh" ]; then
        copy_config "$CONFIG_DIR/zsh" "$HOME/.config/zsh"
    fi
    
    # WezTerm
    if [ -f "$CONFIG_DIR/wezterm/wezterm.lua" ]; then
        copy_config "$CONFIG_DIR/wezterm/wezterm.lua" "$HOME/.wezterm.lua"
    fi
    
    if [ -d "$CONFIG_DIR/wezterm" ]; then
        copy_config "$CONFIG_DIR/wezterm" "$HOME/.config/wezterm"
    fi
    
    # Dunst (notifications)
    if [ -d "$CONFIG_DIR/dunst" ]; then
        copy_config "$CONFIG_DIR/dunst" "$HOME/.config/dunst"
    fi
    
    # Wofi (launcher)
    if [ -d "$CONFIG_DIR/wofi" ]; then
        copy_config "$CONFIG_DIR/wofi" "$HOME/.config/wofi"
    fi
    
    print_success "Configurations deployed successfully!"
    print_warning "Configs were COPIED (not symlinked)"
    print_warning "To update, edit files in repo and run 'make install-configs' again"
}

main() {
    setup_configs
}

main "$@"

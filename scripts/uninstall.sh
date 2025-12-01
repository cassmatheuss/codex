#!/bin/bash

# 🔄 Uninstall script - Removes Codex dotfiles and packages safely
# ⚠️  WARNING: This will remove configurations and packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_DIR="$SCRIPT_DIR/helpers"
PACKAGES_DIR="$SCRIPT_DIR/../packages"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Load helper functions
source "$HELPERS_DIR/print.sh"
source "$HELPERS_DIR/system.sh"

# Confirmation prompt
confirm_uninstall() {
    print_warning "⚠️  This script will:"
    echo "  • Remove packages installed by Codex (safely)"
    echo "  • Delete dotfile configurations"
    echo "  • Keep critical system packages intact"
    echo ""
    read -p "Continue? (yes/no): " response
    
    if [[ ! "$response" == "yes" ]]; then
        print_info "Uninstall cancelled."
        exit 0
    fi
}

# Remove configurations - NO BACKUP
remove_configs() {
    print_info "Removing configurations..."
    
    # Remove Hyprland
    if [ -d "$HOME/.config/hypr" ]; then
        rm -rf "$HOME/.config/hypr"
        print_success "Removed: ~/.config/hypr"
    fi
    
    # Remove ZSH
    if [ -f "$HOME/.zshrc" ]; then
        rm -f "$HOME/.zshrc"
        print_success "Removed: ~/.zshrc"
    fi
    
    if [ -d "$HOME/.config/zsh" ]; then
        rm -rf "$HOME/.config/zsh"
        print_success "Removed: ~/.config/zsh"
    fi
    
    # Remove Kitty
    if [ -d "$HOME/.config/kitty" ]; then
        rm -rf "$HOME/.config/kitty"
        print_success "Removed: ~/.config/kitty"
    fi
    
    # Remove Dunst
    if [ -d "$HOME/.config/dunst" ]; then
        rm -rf "$HOME/.config/dunst"
        print_success "Removed: ~/.config/dunst"
    fi
    
    # Remove Wofi
    if [ -d "$HOME/.config/wofi" ]; then
        rm -rf "$HOME/.config/wofi"
        print_success "Removed: ~/.config/wofi"
    fi
    
    print_success "✅ Configurations removed!"
}

# Remove AUR packages - SAFE REMOVAL
remove_aur_packages() {
    print_info "Removing AUR packages..."
    
    if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
        print_warning "No AUR helper found (yay/paru). Skipping AUR packages."
        return 0
    fi
    
    local aur_helper="yay"
    if command -v paru &> /dev/null; then
        aur_helper="paru"
    fi
    
    # Read AUR packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/aur"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "Removing: ${packages[*]}"
        
        for package in "${packages[@]}"; do
            if pacman -Qi "$package" &>/dev/null; then
                print_info "  → Removing: $package"
                $aur_helper -Rns --noconfirm "$package" 2>/dev/null && {
                    print_success "    ✓ $package removed"
                } || {
                    print_warning "    ✗ Failed to remove $package (may be a dependency)"
                }
            fi
        done
    fi
    
    print_success "✅ AUR packages processed!"
}

# Remove apps packages - SAFE REMOVAL
remove_apps_packages() {
    print_info "Removing app packages..."
    
    # Read app packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/apps"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "Removing: ${packages[*]}"
        
        for package in "${packages[@]}"; do
            if pacman -Qi "$package" &>/dev/null; then
                print_info "  → Removing: $package"
                sudo pacman -Rns --noconfirm "$package" 2>/dev/null && {
                    print_success "    ✓ $package removed"
                } || {
                    print_warning "    ✗ Failed to remove $package (may be a dependency)"
                }
            fi
        done
    fi
    
    print_success "✅ App packages processed!"
}

# Remove system packages - VERY SAFE (keeps critical packages)
remove_system_packages() {
    print_info "Removing system packages..."
    print_warning "⚠️  Critical packages will be KEPT to maintain system stability!"
    
    # Critical packages that should NEVER be removed
    local critical_packages=(
        "base"
        "base-devel"
        "linux"
        "linux-firmware"
        "pacman"
        "systemd"
        "sudo"
        "bash"
        "zsh"
        "zsh-completions"
        "networkmanager"
        "network-manager-applet"
        "pipewire"
        "pipewire-alsa"
        "pipewire-pulse"
        "pipewire-jack"
        "wireplumber"
        "git"
        "curl"
        "wget"
        "xdg-desktop-portal-hyprland"
        "qt5-wayland"
        "qt6-wayland"
    )
    
    # Read system packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Check if package is critical
        local is_critical=false
        for critical in "${critical_packages[@]}"; do
            if [[ "$line" == "$critical" ]]; then
                is_critical=true
                print_warning "  ⚠️  KEPT (critical): $line"
                break
            fi
        done
        
        # Only add to removal list if not critical
        if [[ "$is_critical" == false ]]; then
            packages+=("$line")
        fi
    done < "$PACKAGES_DIR/system"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "Removing: ${packages[*]}"
        
        for package in "${packages[@]}"; do
            if pacman -Qi "$package" &>/dev/null; then
                print_info "  → Removing: $package"
                sudo pacman -Rns --noconfirm "$package" 2>/dev/null && {
                    print_success "    ✓ $package removed"
                } || {
                    print_warning "    ✗ Failed to remove $package (may be a dependency)"
                }
            fi
        done
    else
        print_info "All system packages are critical - nothing removed!"
    fi
    
    print_success "✅ System packages processed safely!"
}

# Uninstall all - SAFE VERSION
uninstall_all() {
    confirm_uninstall
    
    check_arch
    
    print_info "Starting uninstall process..."
    
    remove_configs
    remove_aur_packages
    remove_apps_packages
    remove_system_packages
    
    # Clean pacman cache (optional)
    print_info "Cleaning pacman cache..."
    sudo pacman -Sc --noconfirm
    
    # Remove orphaned packages (safe)
    print_info "Removing orphaned packages..."
    orphans=$(pacman -Qtdq 2>/dev/null)
    if [ -n "$orphans" ]; then
        sudo pacman -Rns --noconfirm $orphans 2>/dev/null || true
    fi
    
    print_success "════════════════════════════════════════════════"
    print_success "  ✅ Uninstall completed safely! ✅  "
    print_success "════════════════════════════════════════════════"
    print_info "System critical packages were kept intact."
}

# Uninstall only configs
uninstall_configs() {
    print_info "Removing only configurations..."
    
    read -p "Continue? (yes/no): " response
    if [[ ! "$response" == "yes" ]]; then
        print_info "Cancelled."
        exit 0
    fi
    
    remove_configs
    print_success "✅ Configurations removed!"
}

# Main
main() {
    case "$1" in
        all)
            uninstall_all
            ;;
        configs)
            uninstall_configs
            ;;
        *)
            print_error "Usage: $0 [all|configs]"
            echo ""
            echo "  all      - Remove packages + configs (safely)"
            echo "  configs  - Remove only configs (keep packages)"
            exit 1
            ;;
    esac
}

main "$@"

#!/bin/bash

# 📦 Package management functions

# Source print functions (only if not already sourced)
if [ -z "$PRINT_SH_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/print.sh"
fi

# Read packages from a file (ignore empty lines and comments)
read_packages() {
    local file=$1
    grep -v '^#' "$file" | grep -v '^$' | tr '\n' ' '
}

# Install system packages (official)
install_system_packages() {
    local packages_dir=$1
    print_info "Installing system packages... 📦"
    
    if [ ! -f "$packages_dir/system" ]; then
        print_error "File $packages_dir/system not found!"
        return 1
    fi
    
    local packages=$(read_packages "$packages_dir/system")
    
    if [ -n "$packages" ]; then
        print_info "Packages to install: $packages"
        # Try to install with conflict resolution (replace conflicting packages)
        yes | sudo pacman -S --needed --noconfirm $packages 2>/dev/null || \
        sudo pacman -S --needed --noconfirm --ask=4 $packages
        print_info "System packages installed successfully! ✅"
    else
        print_warning "No system packages to install"
    fi
}

# Install applications
install_app_packages() {
    local packages_dir=$1
    print_info "Installing applications... 🚀"
    
    if [ ! -f "$packages_dir/apps" ]; then
        print_error "File $packages_dir/apps not found!"
        return 1
    fi
    
    local packages=$(read_packages "$packages_dir/apps")
    
    if [ -n "$packages" ]; then
        print_info "Applications to install: $packages"
        # Try to install with conflict resolution
        yes | sudo pacman -S --needed --noconfirm $packages 2>/dev/null || \
        sudo pacman -S --needed --noconfirm --ask=4 $packages
        print_info "Applications installed successfully! ✅"
    else
        print_warning "No applications to install"
    fi
}

# Install AUR packages
install_aur_packages() {
    local packages_dir=$1
    print_info "Installing AUR packages... 📥"
    
    # Check if yay or paru are installed
    if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
        print_warning "Neither yay nor paru found. Let's install one!"
        choose_aur_helper
    fi
    
    if [ ! -f "$packages_dir/aur" ]; then
        print_error "File $packages_dir/aur not found!"
        return 1
    fi
    
    local packages=$(read_packages "$packages_dir/aur")
    
    if [ -n "$packages" ]; then
        print_info "AUR packages to install: $packages"
        
        if command -v yay &> /dev/null; then
            yay -S --needed --noconfirm $packages
        elif command -v paru &> /dev/null; then
            paru -S --needed --noconfirm $packages
        fi
        
        print_info "AUR packages installed successfully! ✅"
    else
        print_warning "No AUR packages to install"
    fi
}

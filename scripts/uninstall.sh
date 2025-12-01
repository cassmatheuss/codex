#!/bin/bash

# 🔄 Uninstall script - Reverts all Codex dotfiles changes
# This script removes all installed packages and configurations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPERS_DIR="$SCRIPT_DIR/helpers"
PACKAGES_DIR="$SCRIPT_DIR/../packages"
CONFIG_DIR="$SCRIPT_DIR/../config"

# Load helper functions
source "$HELPERS_DIR/print.sh"
source "$HELPERS_DIR/system.sh"

# Backup directory for removed configs
BACKUP_DIR="$HOME/.codex-backup-$(date +%Y%m%d-%H%M%S)"

# Confirmation prompt
confirm_uninstall() {
    print_warning "⚠️  ATENÇÃO: Este script irá:"
    echo "  • Remover todos os pacotes instalados pelo Codex"
    echo "  • Remover todas as configurações copiadas"
    echo "  • Fazer backup das configs em: $BACKUP_DIR"
    echo ""
    print_error "Esta ação NÃO pode ser desfeita automaticamente!"
    echo ""
    read -p "Tem certeza que deseja continuar? (sim/não): " response
    
    if [[ ! "$response" =~ ^[Ss][Ii][Mm]$ ]]; then
        print_info "Uninstall cancelado."
        exit 0
    fi
}

# Create backup of current configs
backup_configs() {
    print_info "Criando backup das configurações... 💾"
    mkdir -p "$BACKUP_DIR"
    
    # Backup Hyprland
    if [ -d "$HOME/.config/hypr" ]; then
        cp -r "$HOME/.config/hypr" "$BACKUP_DIR/hypr" 2>/dev/null || true
        print_success "Backup: ~/.config/hypr"
    fi
    
    # Backup ZSH
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc" 2>/dev/null || true
        print_success "Backup: ~/.zshrc"
    fi
    
    if [ -d "$HOME/.config/zsh" ]; then
        cp -r "$HOME/.config/zsh" "$BACKUP_DIR/zsh" 2>/dev/null || true
        print_success "Backup: ~/.config/zsh"
    fi
    
    # Backup WezTerm
    if [ -f "$HOME/.wezterm.lua" ]; then
        cp "$HOME/.wezterm.lua" "$BACKUP_DIR/.wezterm.lua" 2>/dev/null || true
        print_success "Backup: ~/.wezterm.lua"
    fi
    
    if [ -d "$HOME/.config/wezterm" ]; then
        cp -r "$HOME/.config/wezterm" "$BACKUP_DIR/wezterm" 2>/dev/null || true
        print_success "Backup: ~/.config/wezterm"
    fi
    
    # Backup Dunst
    if [ -d "$HOME/.config/dunst" ]; then
        cp -r "$HOME/.config/dunst" "$BACKUP_DIR/dunst" 2>/dev/null || true
        print_success "Backup: ~/.config/dunst"
    fi
    
    # Backup Wofi
    if [ -d "$HOME/.config/wofi" ]; then
        cp -r "$HOME/.config/wofi" "$BACKUP_DIR/wofi" 2>/dev/null || true
        print_success "Backup: ~/.config/wofi"
    fi
    
    print_success "Backup completo em: $BACKUP_DIR"
}

# Remove configurations
remove_configs() {
    print_info "Removendo configurações... 🗑️"
    
    # Remove Hyprland
    if [ -d "$HOME/.config/hypr" ]; then
        rm -rf "$HOME/.config/hypr"
        print_success "Removido: ~/.config/hypr"
    fi
    
    # Remove ZSH
    if [ -f "$HOME/.zshrc" ]; then
        rm -f "$HOME/.zshrc"
        print_success "Removido: ~/.zshrc"
    fi
    
    if [ -d "$HOME/.config/zsh" ]; then
        rm -rf "$HOME/.config/zsh"
        print_success "Removido: ~/.config/zsh"
    fi
    
    # Remove WezTerm
    if [ -f "$HOME/.wezterm.lua" ]; then
        rm -f "$HOME/.wezterm.lua"
        print_success "Removido: ~/.wezterm.lua"
    fi
    
    if [ -d "$HOME/.config/wezterm" ]; then
        rm -rf "$HOME/.config/wezterm"
        print_success "Removido: ~/.config/wezterm"
    fi
    
    # Remove Dunst
    if [ -d "$HOME/.config/dunst" ]; then
        rm -rf "$HOME/.config/dunst"
        print_success "Removido: ~/.config/dunst"
    fi
    
    # Remove Wofi
    if [ -d "$HOME/.config/wofi" ]; then
        rm -rf "$HOME/.config/wofi"
        print_success "Removido: ~/.config/wofi"
    fi
    
    print_success "Configurações removidas!"
}

# Remove AUR packages
remove_aur_packages() {
    print_info "Removendo pacotes do AUR... 📦"
    
    if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
        print_warning "Nenhum AUR helper encontrado (yay/paru). Pulando pacotes AUR."
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
        print_info "Removendo: ${packages[*]}"
        $aur_helper -Rns --noconfirm "${packages[@]}" 2>/dev/null || {
            print_warning "Alguns pacotes AUR podem não ter sido removidos (já removidos ou não instalados)"
        }
    fi
    
    print_success "Pacotes AUR processados!"
}

# Remove apps packages
remove_apps_packages() {
    print_info "Removendo aplicações... 📦"
    
    # Read app packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/apps"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "Removendo: ${packages[*]}"
        sudo pacman -Rns --noconfirm "${packages[@]}" 2>/dev/null || {
            print_warning "Alguns pacotes podem não ter sido removidos (dependências de outros pacotes ou já removidos)"
        }
    fi
    
    print_success "Aplicações processadas!"
}

# Remove system packages
remove_system_packages() {
    print_info "Removendo pacotes do sistema... 📦"
    print_warning "NOTA: Pacotes essenciais do sistema serão mantidos se forem dependências"
    
    # Read system packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/system"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "Tentando remover: ${packages[*]}"
        sudo pacman -Rns --noconfirm "${packages[@]}" 2>/dev/null || {
            print_warning "Alguns pacotes do sistema não foram removidos (dependências ou já removidos)"
        }
    fi
    
    print_success "Pacotes do sistema processados!"
}

# Uninstall all
uninstall_all() {
    confirm_uninstall
    
    check_arch
    
    backup_configs
    remove_configs
    remove_aur_packages
    remove_apps_packages
    remove_system_packages
    
    # Clean pacman cache
    print_info "Limpando cache do pacman... 🧹"
    sudo pacman -Sc --noconfirm
    
    print_success "✅ Uninstall completo!"
    print_info "Backup das configurações: $BACKUP_DIR"
    print_warning "Para restaurar: cp -r $BACKUP_DIR/* ~/"
}

# Uninstall only configs
uninstall_configs() {
    print_warning "Removendo apenas configurações..."
    
    read -p "Fazer backup antes de remover? (sim/não): " response
    if [[ "$response" =~ ^[Ss][Ii][Mm]$ ]]; then
        backup_configs
    fi
    
    remove_configs
    print_success "Configurações removidas!"
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
            echo "  all      - Remove tudo (pacotes + configs)"
            echo "  configs  - Remove apenas configs (mantém pacotes)"
            exit 1
            ;;
    esac
}

main "$@"

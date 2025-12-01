#!/bin/bash

# 🔄 Uninstall script - Removes ALL Codex dotfiles and packages
# ⚠️  WARNING: This script DESTROYS everything without backup!

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
    print_error "⚠️  ATENÇÃO EXTREMA: Este script irá:"
    echo "  • Remover TODOS os pacotes instalados pelo Codex"
    echo "  • DELETAR PERMANENTEMENTE todas as configurações"
    echo "  • LIMPAR todo o cache do pacman"
    echo "  • SEM BACKUP - Tudo será APAGADO DEFINITIVAMENTE!"
    echo ""
    print_error "═══════════════════════════════════════════════════"
    print_error "  ESTA AÇÃO É DESTRUTIVA E IRREVERSÍVEL!  "
    print_error "═══════════════════════════════════════════════════"
    echo ""
    read -p "Tem ABSOLUTA CERTEZA que deseja DESTRUIR tudo? (DELETAR/não): " response
    
    if [[ ! "$response" == "DELETAR" ]]; then
        print_info "Uninstall cancelado."
        exit 0
    fi
    
    print_warning "Última chance! Digite 'SIM TENHO CERTEZA' para continuar:"
    read -p "> " final_response
    
    if [[ ! "$final_response" == "SIM TENHO CERTEZA" ]]; then
        print_info "Uninstall cancelado."
        exit 0
    fi
}

# Remove configurations - NO BACKUP
remove_configs() {
    print_info "💣 DESTRUINDO configurações sem piedade... 🗑️"
    
    # Remove Hyprland
    if [ -d "$HOME/.config/hypr" ]; then
        rm -rf "$HOME/.config/hypr"
        print_success "DELETADO: ~/.config/hypr"
    fi
    
    # Remove ZSH
    if [ -f "$HOME/.zshrc" ]; then
        rm -f "$HOME/.zshrc"
        print_success "DELETADO: ~/.zshrc"
    fi
    
    if [ -d "$HOME/.config/zsh" ]; then
        rm -rf "$HOME/.config/zsh"
        print_success "DELETADO: ~/.config/zsh"
    fi
    
    # Remove WezTerm
    if [ -f "$HOME/.wezterm.lua" ]; then
        rm -f "$HOME/.wezterm.lua"
        print_success "DELETADO: ~/.wezterm.lua"
    fi
    
    if [ -d "$HOME/.config/wezterm" ]; then
        rm -rf "$HOME/.config/wezterm"
        print_success "DELETADO: ~/.config/wezterm"
    fi
    
    # Remove Dunst
    if [ -d "$HOME/.config/dunst" ]; then
        rm -rf "$HOME/.config/dunst"
        print_success "DELETADO: ~/.config/dunst"
    fi
    
    # Remove Wofi
    if [ -d "$HOME/.config/wofi" ]; then
        rm -rf "$HOME/.config/wofi"
        print_success "DELETADO: ~/.config/wofi"
    fi
    
    # Remove any other potential configs
    if [ -d "$HOME/.config/waybar" ]; then
        rm -rf "$HOME/.config/waybar"
        print_success "DELETADO: ~/.config/waybar"
    fi
    
    if [ -d "$HOME/.config/kitty" ]; then
        rm -rf "$HOME/.config/kitty"
        print_success "DELETADO: ~/.config/kitty"
    fi
    
    if [ -d "$HOME/.config/alacritty" ]; then
        rm -rf "$HOME/.config/alacritty"
        print_success "DELETADO: ~/.config/alacritty"
    fi
    
    print_success "✅ Todas as configurações foram OBLITERADAS!"
}

# Remove AUR packages - FORCE REMOVE
remove_aur_packages() {
    print_info "💣 Removendo pacotes do AUR com força bruta... 📦"
    
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
        print_info "DESTRUINDO: ${packages[*]}"
        
        # Try to remove all at once
        $aur_helper -Rdd --noconfirm "${packages[@]}" 2>/dev/null && {
            print_success "✅ Removidos todos de uma vez!"
        } || {
            # Remove one by one
            print_warning "Removendo um por um..."
            for package in "${packages[@]}"; do
                if pacman -Qi "$package" &>/dev/null; then
                    print_info "  → Removendo: $package"
                    $aur_helper -Rdd --noconfirm "$package" 2>/dev/null && {
                        print_success "    ✓ $package DELETADO!"
                    } || {
                        print_error "    ✗ $package não removido"
                    }
                fi
            done
        }
    fi
    
    # Remove AUR helper itself if installed by us
    if command -v yay &> /dev/null; then
        print_info "💣 Removendo yay..."
        sudo pacman -Rdd --noconfirm yay 2>/dev/null || true
    fi
    
    if command -v paru &> /dev/null; then
        print_info "💣 Removendo paru..."
        sudo pacman -Rdd --noconfirm paru 2>/dev/null || true
    fi
    
    print_success "✅ Pacotes AUR ANIQUILADOS!"
}

# Remove apps packages - FORCE REMOVE
remove_apps_packages() {
    print_info "💣 Removendo aplicações com força total... 📦"
    
    # Read app packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/apps"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "DESTRUINDO: ${packages[*]}"
        
        # First try with dependencies removal
        sudo pacman -Rns --noconfirm "${packages[@]}" 2>/dev/null && {
            print_success "✅ Removidos todos de uma vez!"
            return 0
        }
        
        # If that fails, force remove without dependencies
        print_warning "Forçando remoção sem dependências..."
        sudo pacman -Rdd --noconfirm "${packages[@]}" 2>/dev/null && {
            print_success "✅ Removidos com força!"
            return 0
        }
        
        # Remove one by one if batch fails
        print_warning "Removendo um por um..."
        for package in "${packages[@]}"; do
            if pacman -Qi "$package" &>/dev/null; then
                print_info "  → Removendo: $package"
                sudo pacman -Rdd --noconfirm "$package" 2>/dev/null && {
                    print_success "    ✓ $package DELETADO!"
                } || {
                    print_error "    ✗ $package não removido"
                }
            fi
        done
    fi
    
    print_success "✅ Aplicações EXTERMINADAS!"
}

# Remove system packages - FORCE REMOVE
remove_system_packages() {
    print_info "💣 Removendo pacotes do sistema sem misericórdia... 📦"
    print_warning "⚠️  REMOVENDO TUDO, incluindo possíveis dependências críticas!"
    
    # Read system packages
    local packages=()
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        packages+=("$line")
    done < "$PACKAGES_DIR/system"
    
    if [ ${#packages[@]} -gt 0 ]; then
        print_info "ANIQUILANDO: ${packages[*]}"
        
        # Try to remove all at once first with dependencies
        sudo pacman -Rns --noconfirm "${packages[@]}" 2>/dev/null && {
            print_success "✅ Removidos todos de uma vez!"
            return 0
        }
        
        # If that fails, try force remove all at once
        print_warning "Tentativa 1 falhou, forçando remoção em lote..."
        sudo pacman -Rdd --noconfirm "${packages[@]}" 2>/dev/null && {
            print_success "✅ Removidos com força bruta!"
            return 0
        }
        
        # If even that fails, remove one by one
        print_warning "Remoção em lote falhou, removendo um por um..."
        for package in "${packages[@]}"; do
            if pacman -Qi "$package" &>/dev/null; then
                print_info "  → Tentando remover: $package"
                sudo pacman -Rdd --noconfirm "$package" 2>/dev/null && {
                    print_success "    ✓ $package DELETADO!"
                } || {
                    print_warning "    ✗ $package não pôde ser removido (será tentado com cascade)"
                    # Try with cascade to remove dependencies too
                    sudo pacman -Rddsc --noconfirm "$package" 2>/dev/null && {
                        print_success "    ✓ $package DELETADO com cascade!"
                    } || {
                        print_error "    ✗ $package RESISTIU à remoção"
                    }
                }
            fi
        done
    fi
    
    print_success "✅ Pacotes do sistema DEVASTADOS!"
}

# Uninstall all - NUCLEAR OPTION
uninstall_all() {
    confirm_uninstall
    
    check_arch
    
    print_error "🔥🔥🔥 INICIANDO DESTRUIÇÃO TOTAL 🔥🔥🔥"
    
    remove_configs
    remove_aur_packages
    remove_apps_packages
    remove_system_packages
    
    # Clean ALL pacman cache - no mercy
    print_info "💣 OBLITERANDO cache do pacman... 🧹"
    sudo pacman -Scc --noconfirm
    
    # Remove orphaned packages
    print_info "💣 Removendo pacotes órfãos..."
    sudo pacman -Qtdq | sudo pacman -Rns --noconfirm - 2>/dev/null || true
    
    # Clean up package database
    print_info "🧹 Limpando banco de dados de pacotes..."
    sudo pacman-optimize 2>/dev/null || true
    
    # Remove old .backup files
    print_info "🧹 Removendo arquivos .backup..."
    sudo find /etc -type f -name '*.pacsave' -delete 2>/dev/null || true
    sudo find /etc -type f -name '*.pacnew' -delete 2>/dev/null || true
    
    print_success "════════════════════════════════════════════════"
    print_success "  ✅ DESTRUIÇÃO COMPLETA E TOTAL! ✅  "
    print_success "════════════════════════════════════════════════"
    print_error "Tudo foi OBLITERADO sem piedade!"
    print_error "Nenhum backup foi criado - tudo foi DELETADO!"
}

# Uninstall only configs - ALSO NO BACKUP
uninstall_configs() {
    print_error "💣 Removendo APENAS configurações - SEM BACKUP!"
    
    read -p "Tem certeza? Digite 'DELETAR' para confirmar: " response
    if [[ ! "$response" == "DELETAR" ]]; then
        print_info "Cancelado."
        exit 0
    fi
    
    remove_configs
    print_success "✅ Configurações DESTRUÍDAS sem piedade!"
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

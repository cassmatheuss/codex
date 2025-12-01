#!/bin/bash

# ⚙️ Configuration deployment functions

# Source print functions (only if not already sourced)
if [ -z "$PRINT_SH_LOADED" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/print.sh"
fi

# Copy configuration files
copy_config() {
    local source=$1
    local target=$2
    
    # Remove existing file/directory
    if [ -e "$target" ]; then
        rm -rf "$target"
    fi
    
    mkdir -p "$(dirname "$target")"
    
    if [ -d "$source" ]; then
        cp -r "$source" "$target"
        print_info "Directory copied: $source → $target"
    elif [ -f "$source" ]; then
        cp "$source" "$target"
        print_info "File copied: $source → $target"
    else
        print_warning "Source not found: $source"
        return 1
    fi
}

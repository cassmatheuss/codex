#!/bin/bash

# 📢 Print functions

# Mark as loaded
export PRINT_SH_LOADED=1

# Source colors if not already loaded
if [ -z "$GREEN" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    source "$SCRIPT_DIR/colors.sh"
fi

print_info() {
    echo -e "${GREEN}✨ [INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}❌ [ERROR]${NC} $1"
}

print_question() {
    echo -e "${BLUE}🤔 [QUESTION]${NC} $1"
}

print_ok() {
    echo -e "${GREEN}✅${NC} $1"
}

print_fail() {
    echo -e "${RED}❌${NC} $1"
}

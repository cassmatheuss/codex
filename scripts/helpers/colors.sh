#!/bin/bash

# 🎨 Color definitions and output helpers

# Color codes
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export RED='\033[0;31m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export NC='\033[0m' # No Color

# Print functions
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

print_success() {
    echo -e "${GREEN}✅ [SUCCESS]${NC} $1"
}

print_debug() {
    echo -e "${CYAN}🔍 [DEBUG]${NC} $1"
}

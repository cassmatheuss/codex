.PHONY: help install install-system install-apps install-aur install-configs update clean check

SCRIPTS_DIR := scripts
PACKAGES_DIR := packages
CONFIG_DIR := config

GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m

help:
	@echo "$(GREEN)Codex - Dotfiles Manager$(NC)"
	@echo ""
	@echo "Use: make [target]"
	@echo ""
	@echo "Targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

install: install-system install-apps install-aur install-configs
	@echo "$(GREEN)✓ Instalação completa finalizada!$(NC)"

install-system:
	@echo "$(YELLOW)Instalando pacotes do sistema...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh system

install-apps:
	@echo "$(YELLOW)Instalando aplicações...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh apps

install-aur:
	@echo "$(YELLOW)Instalando pacotes do AUR...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh aur

install-configs:
	@echo "$(YELLOW)Instalando configurações...$(NC)"
	@bash $(SCRIPTS_DIR)/configs.sh

check:
	@echo "$(YELLOW)Verificando sistema...$(NC)"
	@bash $(SCRIPTS_DIR)/check.sh

uninstall:
	@echo "$(RED)⚠️  Removendo instalação Codex...$(NC)"
	@bash $(SCRIPTS_DIR)/uninstall.sh all

uninstall-configs:
	@echo "$(YELLOW)Removendo configurações...$(NC)"
	@bash $(SCRIPTS_DIR)/uninstall.sh configs

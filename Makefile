.PHONY: help install install-system install-apps install-aur install-configs update clean check

# Variáveis
SCRIPTS_DIR := scripts
PACKAGES_DIR := packages
CONFIG_DIR := config

# Cores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
RED := \033[0;31m
NC := \033[0m # No Color

help: ## Mostra esta mensagem de ajuda
	@echo "$(GREEN)Codex - Dotfiles Manager$(NC)"
	@echo ""
	@echo "Uso: make [target]"
	@echo ""
	@echo "Targets disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

install: install-system install-apps install-aur install-configs ## Instalação completa
	@echo "$(GREEN)✓ Instalação completa finalizada!$(NC)"

install-system: ## Instala pacotes essenciais do sistema
	@echo "$(YELLOW)Instalando pacotes do sistema...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh system

install-apps: ## Instala aplicações do usuário
	@echo "$(YELLOW)Instalando aplicações...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh apps

install-aur: ## Instala pacotes do AUR
	@echo "$(YELLOW)Instalando pacotes do AUR...$(NC)"
	@bash $(SCRIPTS_DIR)/install.sh aur

install-configs: ## Copia as configurações para o sistema
	@echo "$(YELLOW)Instalando configurações...$(NC)"
	@bash $(SCRIPTS_DIR)/deploy.sh

update: ## Atualiza o sistema e os pacotes
	@echo "$(YELLOW)Atualizando sistema...$(NC)"
	@sudo pacman -Syu --noconfirm

clean: ## Remove arquivos temporários
	@echo "$(YELLOW)Limpando arquivos temporários...$(NC)"
	@sudo pacman -Sc --noconfirm

check: ## Verifica dependências e configurações
	@echo "$(YELLOW)Verificando sistema...$(NC)"
	@bash $(SCRIPTS_DIR)/check.sh

uninstall: ## Remove TUDO (pacotes + configs) - CUIDADO!
	@echo "$(RED)⚠️  Removendo instalação Codex...$(NC)"
	@bash $(SCRIPTS_DIR)/uninstall.sh all

uninstall-configs: ## Remove apenas as configurações
	@echo "$(YELLOW)Removendo configurações...$(NC)"
	@bash $(SCRIPTS_DIR)/uninstall.sh configs

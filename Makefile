# Makefile for reMarkable Template Customization
#
# This Makefile provides a convenient interface for validating, building,
# and deploying custom templates to a reMarkable tablet.
#
# Usage:
#   make               Show available commands (default)
#   make help          Show available commands
#   make validate      Validate all templates
#   make build         Validate templates (preparation for deployment)
#   make deploy        Deploy templates to device
#   make clean         Remove custom templates from device
#
# Variables:
#   DEVICE_IP          IP address of reMarkable device (default: 10.11.99.1)
#   DEVICE_USER        SSH user for device (default: root)
#
# Examples:
#   make deploy                         Deploy to default IP (10.11.99.1)
#   make DEVICE_IP=192.168.1.100 deploy Deploy to custom IP
#

# Configuration
DEVICE_IP ?= 10.11.99.1
DEVICE_USER ?= root
DEVICE_PATH = /usr/share/remarkable/templates

# Directories
SCRIPTS_DIR = scripts
TEMPLATES_DIR = templates
SOURCES_DIR = sources

# Scripts
VALIDATE_SCRIPT = $(SCRIPTS_DIR)/validate-templates.py
DEPLOY_SCRIPT = $(SCRIPTS_DIR)/deploy.sh

# Colors for output
GREEN = \033[0;32m
BLUE = \033[0;34m
YELLOW = \033[1;33m
NC = \033[0m # No Color

# Default target: show help
.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help message
	@echo "$(BLUE)======================================================================$(NC)"
	@echo "$(BLUE)reMarkable Template Customization$(NC)"
	@echo "$(BLUE)======================================================================$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-15s$(NC) %s\n", $$1, $$2}'
	@echo ""
	@echo "Variables:"
	@echo "  $(GREEN)DEVICE_IP$(NC)       Device IP address (current: $(DEVICE_IP))"
	@echo "  $(GREEN)DEVICE_USER$(NC)     SSH username (current: $(DEVICE_USER))"
	@echo ""
	@echo "Examples:"
	@echo "  make validate"
	@echo "  make deploy"
	@echo "  make DEVICE_IP=192.168.1.100 deploy"
	@echo ""

.PHONY: validate
validate: ## Validate all template files and templates.json
	@echo "$(BLUE)Running template validation...$(NC)"
	@chmod +x $(VALIDATE_SCRIPT)
	@uv run python $(VALIDATE_SCRIPT)

.PHONY: build
build: validate ## Validate templates (preparation for deployment)
	@echo "$(GREEN)Build complete - templates are ready for deployment$(NC)"

.PHONY: deploy
deploy: ## Deploy templates to reMarkable device
	@echo "$(BLUE)Deploying templates to $(DEVICE_USER)@$(DEVICE_IP)...$(NC)"
	@chmod +x $(DEPLOY_SCRIPT)
	@$(DEPLOY_SCRIPT) $(DEVICE_IP)

.PHONY: upload
upload: deploy ## Alias for deploy

.PHONY: clean
clean: ## Remove custom templates from device and restore originals
	@echo "$(YELLOW)Removing custom Daily Tracker templates from device...$(NC)"
	@echo "$(YELLOW)This will:"
	@echo "  1. Remove P Daily Tracker.template$(NC)"
	@echo "  2. Remove LS Daily Tracker.template$(NC)"
	@echo "  3. Restore backup of templates.json (if exists)$(NC)"
	@echo ""
	@read -p "Continue? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		ssh $(DEVICE_USER)@$(DEVICE_IP) ' \
			cd $(DEVICE_PATH) && \
			echo "Removing custom template files..." && \
			rm -f "P Daily Tracker.template" && \
			rm -f "LS Daily Tracker.template" && \
			if [ -f templates.json.backup ]; then \
				echo "Restoring templates.json from backup..." && \
				mv templates.json.backup templates.json; \
			else \
				echo "Warning: No templates.json.backup found"; \
				echo "You may need to manually restore templates.json"; \
			fi && \
			echo "Restarting xochitl service..." && \
			systemctl restart xochitl && \
			echo "Done!" \
		'; \
		echo "$(GREEN)Custom templates removed successfully$(NC)"; \
	else \
		echo "$(YELLOW)Clean operation cancelled$(NC)"; \
	fi

.PHONY: backup
backup: ## Create backup of current device templates
	@echo "$(BLUE)Creating backup of device templates...$(NC)"
	@ssh $(DEVICE_USER)@$(DEVICE_IP) "cd $(DEVICE_PATH) && cp templates.json templates.json.backup"
	@echo "$(GREEN)Backup created: templates.json.backup$(NC)"

.PHONY: status
status: ## Show device connection status and template count
	@echo "$(BLUE)Checking device status...$(NC)"
	@echo ""
	@echo "Device: $(DEVICE_USER)@$(DEVICE_IP)"
	@if ssh -o ConnectTimeout=5 -o BatchMode=yes $(DEVICE_USER)@$(DEVICE_IP) "echo 'Connected'" &>/dev/null; then \
		echo "Status: $(GREEN)Connected$(NC)"; \
		echo ""; \
		echo "Local templates:"; \
		@ls -1 $(TEMPLATES_DIR)/*.template 2>/dev/null | wc -l | xargs echo "  Template files:"; \
		echo ""; \
		echo "Device templates:"; \
		ssh $(DEVICE_USER)@$(DEVICE_IP) "ls -1 $(DEVICE_PATH)/*.template 2>/dev/null | wc -l | xargs echo '  Template files:'"; \
		ssh $(DEVICE_USER)@$(DEVICE_IP) "if [ -f $(DEVICE_PATH)/templates.json.backup ]; then echo '  Backup: exists'; else echo '  Backup: none'; fi"; \
	else \
		echo "Status: $(YELLOW)Not connected$(NC)"; \
		echo ""; \
		echo "Please check:"; \
		echo "  1. Device is connected via USB"; \
		echo "  2. Device IP is correct (current: $(DEVICE_IP))"; \
		echo "  3. SSH keys are configured"; \
	fi
	@echo ""

.PHONY: check
check: validate ## Alias for validate

.PHONY: test
test: validate ## Alias for validate

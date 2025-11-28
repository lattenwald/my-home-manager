.DEFAULT_GOAL := update

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: install
install: ## First-time install: bootstrap home-manager via flake
	nix run home-manager -- switch --impure --flake .#myProfile -b backup

.PHONY: update
update: completions ## Apply home-manager configuration
	home-manager switch --impure --flake .#myProfile

.PHONY: completions
completions: ## Generate shell completions for installed tools
	@bash scripts/generate-completions.sh

.PHONY: upgrade
upgrade: completions ## Update flake inputs and apply changes
	nix flake update && home-manager switch --impure --flake .#myProfile && asdf reshim

.PHONY: clean
clean: ## Run garbage collection
	nix-collect-garbage -d

.PHONY: fmt
fmt: ## Format all .nix files with nixpkgs-fmt
	nixpkgs-fmt .

.PHONY: lint
lint: ## Lint all .nix files with statix
	statix check .

.PHONY: news
news: ## Show home-manager news
	home-manager --impure --flake .#myProfile news

# Machine marker targets
.PHONY: gui
gui: ## Mark as GUI machine (enables GUI apps and services)
	@touch ~/.gui-machine
	@echo "✅ Marked as GUI machine (~/.gui-machine created)"
	@echo "➡️  Run 'make update' to apply"

.PHONY: nogui
nogui: ## Mark as non-GUI machine (disables GUI apps and services)
	@rm -f ~/.gui-machine
	@echo "✅ Marked as non-GUI machine (~/.gui-machine removed)"
	@echo "➡️  Run 'make update' to apply"

.PHONY: work
work: ## Mark as work machine (enables work-specific configs)
	@touch ~/.work-machine
	@echo "✅ Marked as work machine (~/.work-machine created)"
	@echo "➡️  Run 'make update' to apply"

.PHONY: nowork
nowork: ## Mark as personal machine (disables work-specific configs)
	@rm -f ~/.work-machine
	@echo "✅ Marked as personal machine (~/.work-machine removed)"
	@echo "➡️  Run 'make update' to apply"

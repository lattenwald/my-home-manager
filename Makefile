.DEFAULT_GOAL := update

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

.PHONY: update
update: ## Apply home-manager configuration
	home-manager switch --flake .#myProfile

.PHONY: clean
clean: ## Run garbage collection
	nix-collect-garbage -d

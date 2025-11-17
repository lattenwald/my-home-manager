.PHONY: update
update:
	home-manager switch --flake .#myProfile

.PHONY: clean
clean:
	nix-collect-garbage -d

#!/usr/bin/env bash
# Declarative completion generation script
# Generates shell completions for installed tools

generate_completion() {
  local binary="$1"
  local command="$2"
  local output="$3"

  if command -v "$binary" >/dev/null 2>&1; then
    local comp_file="$HOME/.zsh/completion/$output"
    local tool_path tool_hash stored_hash

    tool_path="$(command -v "$binary")"
    tool_hash="$(sha256sum "$tool_path" 2>/dev/null | cut -d' ' -f1 || echo 'none')"
    stored_hash=""

    # Check if completion exists and read stored hash
    if [ -f "$comp_file" ]; then
      stored_hash="$(head -n1 "$comp_file" | grep -oP '(?<=# hash: ).*' || echo '')"
    fi

    # Regenerate if hash changed or file missing
    if [ "$tool_hash" != "$stored_hash" ] || [ ! -f "$comp_file" ]; then
      echo "Generating completion for $binary..."
      mkdir -p "$HOME/.zsh/completion"
      {
        echo "# hash: $tool_hash"
        eval "$command"
      } > "$comp_file" 2>/dev/null || {
        echo "Warning: Failed to generate completion for $binary" >&2
      }
    fi
  fi
}

# Generate completions for each tool

# Originally heavy runtime evals (from TASK-003)
generate_completion "stack" "stack --bash-completion-script stack" "_stack"
generate_completion "leetcode" "leetcode completions" "_leetcode"

# Kubernetes ecosystem
generate_completion "kubectl" "kubectl completion zsh" "_kubectl"
generate_completion "helm" "helm completion zsh" "_helm"
generate_completion "k9s" "k9s completion zsh" "_k9s"
generate_completion "flux" "flux completion zsh" "_flux"
generate_completion "kind" "kind completion zsh" "_kind"

# Rust tooling
generate_completion "rustup" "rustup completions zsh" "_rustup"
generate_completion "rustup" "rustup completions zsh cargo" "_cargo"

# Python tooling
generate_completion "uv" "uv generate-shell-completion zsh" "_uv"

# Git tools
generate_completion "delta" "delta --generate-completion zsh" "_delta"
generate_completion "gup" "gup completion zsh" "_gup"

# Custom tools
generate_completion "sub" "sub completion zsh" "_sub"

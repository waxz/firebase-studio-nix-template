#!/usr/bin/env bash
set -euo pipefail

IN_FILE=".idx/dev.nix"

# 1. Remove all existing pkgs lines to prevent duplicates
sed -i '/pkgs.cloudflared/d' "$IN_FILE"

# 2. Add pkgs back in the correct place
sed -i '/packages = /a \
    pkgs.cloudflared' "$IN_FILE"

# 3. Remove the old, badly indented npm-install line
sed -i '/start-tunnel.*/d' "$IN_FILE"

# 4. Add npm-install with the correct indentation
sed -i '/onCreate = {/a \
        start-tunnel = "cloudflared tunnel --url localhost";' "$IN_FILE"

echo "✅ Successfully cleaned up and corrected .idx/dev.nix"

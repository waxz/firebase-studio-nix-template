{ pkgs, 
  environment ? "deno", 
  git_repo ? "",
  rust ? true,
  deno ? true,
  wrangler ? true,
  python ? false,    # ✅ Added missing parameter
  ... 
}: {
  packages = [
    pkgs.git
  ];

  bootstrap = ''
    mkdir -p "$out"
    mkdir -p "$out/.idx"

    # ==================================
    # 1. Handle environment setup
    # ==================================
    
    if [ "${environment}" = "git" ]; then
      if [ -n "${git_repo}" ]; then
        echo "Cloning repository: ${git_repo}"
        git clone "${git_repo}" "$out/repo_temp"
        shopt -s dotglob
        mv "$out/repo_temp"/* "$out/" 2>/dev/null || true
        rm -rf "$out/repo_temp"
        
        if [ ! -f "$out/.idx/dev.nix" ]; then
          cp -rf ${./.}/base/dev.nix "$out/.idx/dev.nix"
        fi
      else
        echo "Error: git_repo is empty but environment is 'git'"
        exit 1
      fi
    else
      echo "Setting up ${environment} environment..."
      cp -rf ${./.}/${environment}/dev.nix "$out/.idx/dev.nix"
      shopt -s dotglob
      cp -rf ${./.}/${environment}/dev/* "$out"
    fi

    chmod -R u+w "$out"

    # ==================================
    # 2. Build packages list based on options
    # ==================================
    
    # ✅ Fixed: removed pkgs.apt (doesn't exist)
    PACKAGES="pkgs.yarn pkgs.cloudflared"
    EXTENSIONS=""

    # Check Deno option
    if [ "${toString deno}" = "1" ] || [ "${toString deno}" = "true" ]; then
      PACKAGES="$PACKAGES pkgs.deno"
      EXTENSIONS="$EXTENSIONS \"denoland.vscode-deno\""
      echo "Adding: deno"
    fi

    # Check Rust option
    if [ "${toString rust}" = "1" ] || [ "${toString rust}" = "true" ]; then
      PACKAGES="$PACKAGES pkgs.rustup pkgs.cargo"
      EXTENSIONS="$EXTENSIONS \"Swellaby.rust-pack\""
      echo "Adding: rust"
    fi

    # Check Wrangler option
    if [ "${toString wrangler}" = "1" ] || [ "${toString wrangler}" = "true" ]; then
      PACKAGES="$PACKAGES pkgs.nodePackages.wrangler"
      echo "Adding: wrangler"
    fi

    # Check Python option
    if [ "${toString python}" = "1" ] || [ "${toString python}" = "true" ]; then
      PACKAGES="$PACKAGES pkgs.python3 pkgs.uv"
      EXTENSIONS="$EXTENSIONS \"ms-python.python\" \"rangav.vscode-thunder-client\""
      echo "Adding: python"
    fi

    # ==================================
    # 3. Update dev.nix with packages
    # ==================================
    
    # ✅ Fixed: Use double quotes and pass both arguments
    cat > "$out/update-nix.sh" << SCRIPT
#!/bin/bash
PACKAGES="\$1"
EXTENSIONS="\$2"

DEV_NIX=".idx/dev.nix"

if [ -f "\$DEV_NIX" ]; then
  # Update packages
  if grep -q "packages = \[" "\$DEV_NIX"; then
    sed -i "s|packages = \[|packages = [\n    \$PACKAGES|" "\$DEV_NIX"
  else
    echo "Warning: Could not find packages line in dev.nix"
  fi
  
  # Update extensions
  if grep -q "extensions = \[" "\$DEV_NIX"; then
    sed -i "s|extensions = \[|extensions = [\n    \$EXTENSIONS|" "\$DEV_NIX"
  else
    echo "Warning: Could not find extensions line in dev.nix"
  fi
  
  # Add onCreate tunnel command
  if grep -q "onCreate = {" "\$DEV_NIX"; then
    sed -i '/onCreate = {/a \        start-tunnel = "cloudflared tunnel --url http://localhost";' "\$DEV_NIX"
  else
    echo "Warning: Could not find onCreate line in dev.nix"
  fi
fi
SCRIPT

    chmod +x "$out/update-nix.sh"
    
    # ✅ Fixed: Pass both PACKAGES and EXTENSIONS
    cd "$out"
    if [ -n "$PACKAGES" ]; then
      bash ./update-nix.sh "$PACKAGES" "$EXTENSIONS"
    fi
    rm -f ./update-nix.sh

    # ==================================
    # 4. Run init.sh if exists
    # ==================================
    
    if [ -f "$out/init.sh" ]; then
      chmod +x "$out/init.sh"
    fi

    echo "Bootstrap complete!"
  '';
}

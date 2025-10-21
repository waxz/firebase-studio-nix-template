{ pkgs, environment ? "deno", ... }: {
  packages = [

  ];
  bootstrap = ''
    mkdir "$out"
    mkdir "$out/.idx"

    cp -rf ${./.}/${environment}/dev.nix "$out/.idx/dev.nix"
    shopt -s dotglob; cp -rf ${./.}/${environment}/dev/* "$out"
    chmod -R u+w "$out"
    cp -rf ${./.}/update-nix.sh "$out"
    chmod +x "$out"/*.sh
    cd "$out" && bash ./update-nix.sh && rm ./update-nix.sh
  '';
}
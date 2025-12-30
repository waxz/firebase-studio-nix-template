{ pkgs, ... }: {
  channel = "stable-23.11";
  
  packages = [
    # Packages will be inserted here by bootstrap
  ];

  idx = {
    extensions = [
    # Extensions will be inserted here by bootstrap
      
    ];
    
    previews = {
      enable = true;
    };
    workspace = {
      # Runs when a workspace is first created with this `dev.nix` file
      onCreate = {

      };
    };
  };


}

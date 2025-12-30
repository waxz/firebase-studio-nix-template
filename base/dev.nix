{ pkgs, ... }: {
  channel = "stable-23.11";
  
  packages = [
    # Packages will be inserted here by bootstrap
  ];

  idx = {
    extensions = [
      
    ];
    
    previews = {
      enable = true;
    };
  };
}

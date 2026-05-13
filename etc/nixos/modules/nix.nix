{ ... }:

{
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      max-jobs = "auto";
      cores = 0; # use all cores
      warn-dirty = false;
    };

    # automatically hardlink identical files
    optimise = {
      automatic = true;
      dates = [ "daily" ];
    };

    # automatically trigger garbage collection
    gc = {
      automatic = true;
      persistent = true;
      dates = "weekly";
    };
  };
  security = {
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
      extraConfig = ''
        Defaults pwfeedback
        Defaults env_keep += "EDITOR PATH DISPLAY"
        Defaults passprompt = "[sudo 󱅞 ]: "
      '';
    };
  };
}

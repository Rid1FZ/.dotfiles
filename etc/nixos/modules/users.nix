{ pkgs, ... }:
{
  users.users.rid1 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "adbusers"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      eza
      bat
      fzf
      ripgrep
      tree-sitter
      delta
      trash-cli
      github-cli
    ];
  };
}

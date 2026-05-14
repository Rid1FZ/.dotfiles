{ pkgs, ... }:
{
  users.users.rid1 = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "adbusers"
    ];

    # The following 2s are needed for podman
    subUidRanges = [
      {
        startUid = 100000;
        count = 65536;
      }
    ];
    subGidRanges = [
      {
        startGid = 100000;
        count = 65536;
      }
    ];
    shell = pkgs.zsh;

    packages = with pkgs; [
      zed-editor
      eza
      bat
      fzf
      ripgrep
      tree-sitter
      delta
      trash-cli
      github-cli
      yt-dlp
      ffmpeg
      atomicparsley
      deno
      lazygit
    ];
  };
}

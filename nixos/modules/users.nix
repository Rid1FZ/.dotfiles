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
      atomicparsley
      bat
      (emacs-pgtk.override {
        withNativeCompilation = true;
        withTreeSitter = true;
        withSQLite3 = true;
      })
      deno
      delta
      eza
      fastfetch
      ffmpeg
      fzf
      gdu
      github-cli
      lazygit
      ripgrep
      trash-cli
      tree-sitter
      yt-dlp
      zed-editor
    ];
  };
}

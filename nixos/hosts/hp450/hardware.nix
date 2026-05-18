{ pkgs, ... }:
{

  # Gnome enables this by default
  services.power-profiles-daemon.enable = false;

  # CPU frequency scaling - battery/charger profiles for Intel laptop
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "auto";
      };
      charger = {
        governor = "performance";
        turbo = "always";
      };
    };
  };

  # Intel thermal management - prevents throttling before hardware kicks in
  services.thermald.enable = true;

  # OOM killer - on 4GB, the kernel will freeze instead of killing processes.
  # earlyoom kills the heaviest process early, keeping the system responsive.
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeSwapThreshold = 5;
  };

  # Compressed swap in RAM.
  # priority = 100 ensures zram is used before falling back to your HDD swap.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
    priority = 100;
  };

  # Adjusts CPU/IO priorities for known apps using a crowdsourced ruleset.
  # Reduces stuttering when browser + compiler + LSP compete for resources.
  services.ananicy = {
    enable = true;
    package = pkgs.ananicy-cpp;
  };

  # Kernel tuning
  boot.kernel.sysctl = {
    # Aggressively use zram before evicting to disk swap (HDD swap is very slow)
    "vm.swappiness" = 100;
    # Keep directory/inode cache in memory longer - reduces HDD seeks
    "vm.vfs_cache_pressure" = 50;
  };
}

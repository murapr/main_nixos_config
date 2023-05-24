# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ stable, inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  age.identityPaths = [ "/home/mur/.ssh/id_ed25519" ];
 
  age.secrets.finsocks = {
  	file = ./secrets/finsocks.age;
  	owner = "shadowsocks";
  	group = "shadowsocks";
  };

  age.secrets.frsocks = {
  	file = ./secrets/frsocks.age;
  	owner = "shadowsocks";
  	group = "shadowsocks";
  };

  age.secrets.cansocks = {
  	file = ./secrets/cansocks.age;
  	owner = "shadowsocks";
  	group = "shadowsocks";
  };

  age.secrets.mur_password = {
  	file = ./secrets/mur_password.age;
  	owner = "mur";
  	group = "users";
  };
  
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-977de39a-347e-4abb-8d18-43337220839f".device = "/dev/disk/by-uuid/977de39a-347e-4abb-8d18-43337220839f";
  boot.initrd.luks.devices."luks-977de39a-347e-4abb-8d18-43337220839f".keyFile = "/crypto_keyfile.bin";

  users.users.shadowsocks = {
    group = "shadowsocks";
    isSystemUser = true;
  };
  users.groups.shadowsocks = {};

  
  users.defaultUserShell = pkgs.fish;

  
  systemd.services.finshadowsocks = {
    enable = true;
    description = "Shadowsocks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
      User="shadowsocks";
    };
    path = with pkgs; [ shadowsocks-libev shadowsocks-v2ray-plugin ];
    script = ''
    password=$(cat "${config.age.secrets.finsocks.path}")
    ss-local -s "fin.dreamykafe.tech" \
    -p 443 \
    -l 1081 \
    -b 0.0.0.0 \
    -k $password \
    -m "xchacha20-ietf-poly1305" \
    --plugin "v2ray-plugin" \
    --plugin-opts "tls;host=fin.dreamykafe.tech;path=/socks;loglevel=debug" \
    -t 300 \
    --reuse-port \
    --fast-open
    '';
  };
  
   systemd.services.franceshadowsocks = {
    enable = true;
    description = "Shadowsocks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
      User="shadowsocks";
      Group="shadowsocks";
    };
    script = ''
     password=$(cat "${config.age.secrets.frsocks.path}")
     ss-local \
        -s "fr.dreamykafe.tech" \
        -p 443 \
        -l 1080 \
        -b 127.0.0.1 \
        -k $password \
        -m "xchacha20-ietf-poly1305" \
        --plugin "v2ray-plugin" \
        --plugin-opts "tls;host=fr.dreamykafe.tech;path=/socks;loglevel=debug" \ 
        -t 300 \
        --reuse-port \
        --fast-open
    '';
    path = with pkgs; [ shadowsocks-libev shadowsocks-v2ray-plugin ];
  };
  
     systemd.services.canadashadowsocks = {
    enable = true;
    description = "Shadowsocks";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "5";
      User="shadowsocks";
      Group="shadowsocks";
    };
    script = ''
     password=$(cat "${config.age.secrets.cansocks.path}")
     ss-local \
        -s "ca.dreamykafe.tech" \
        -p 443 \
        -l 1082 \
        -b 127.0.0.1 \
        -k $password \
        -m "xchacha20-ietf-poly1305" \
        --plugin "v2ray-plugin" \
        --plugin-opts "tls;host=ca.dreamykafe.tech;path=/socks;loglevel=debug" \ 
        -t 300 \
        --reuse-port \
        --fast-open
    '';
    path = with pkgs; [ shadowsocks-libev shadowsocks-v2ray-plugin ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };
  
  # Enable CUPS to print documents.
# services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mur = {
    isNormalUser = true;
    description = "mur";
    extraGroups = [ "networkmanager" "wheel" "adbusers" ];
    passwordFile = config.age.secrets.mur_password.path;
    packages = with pkgs; [
      firefox
      cargo
      rustup
      gnomeExtensions.unite
      gnomeExtensions.appindicator
      gnomeExtensions.dock-from-dash
      gnomeExtensions.pip-on-top
      gnome3.gnome-tweaks
      gnomeExtensions.stocks-extension
      adw-gtk3
      gnomeExtensions.ddterm
      gnomeExtensions.blur-my-shell
      vscodium
      libreoffice
      telegram-desktop
      gnomeExtensions.window-is-ready-remover
      micro
      tor-browser-bundle-bin
      qtox
      gnomeExtensions.simple-system-monitor
      android-tools
      kitty
          ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  git
  tailscale
  any-nix-shell
  inputs.agenix.packages.x86_64-linux.default
  firejail
  ];

  programs.fish.promptInit = ''
    any-nix-shell fish --info-right | source
  '';
  programs.fish.enable = true;
  programs.adb.enable = true;
  programs.java.enable = true;
  programs.steam.enable = true;

  programs.firejail.enable = true;
  
  services.tailscale.enable = true;
  
  services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        ipv6_servers = true;
        require_dnssec = true;
  		server_names = ["cloudflare"];
      };
    };
  
    systemd.services.dnscrypt-proxy2.serviceConfig = {
      StateDirectory = "dnscrypt-proxy";
    };

  networking = {
      nameservers = [ "127.0.0.1" "::1" ];
      networkmanager.dns = "none";
      networkmanager.enable = true;
      hostName = "powerpc";
    };

    
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}

# dotfiles

Personal dotfiles for my CachyOS + Hyprland setup, managed with GNU Stow.

## System

| Component | Details |
|-----------|---------|
| OS | CachyOS (Arch-based) |
| Kernel | Linux cachyos |
| WM | Hyprland (Wayland) |
| Shell | Zsh + Starship |
| Terminal | Kitty |
| Display Manager | SDDM |

## Hardware

| Component | Details |
|-----------|---------|
| Laptop | HP Victus 16 (2023) |
| CPU | Intel Core i7-13700H |
| GPU | NVIDIA GeForce RTX 4060 Max-Q |
| RAM | 16GB DDR5 4800MHz |
| Storage | WD Blue SN580 1TB |
| Display | 16.1" FHD 144Hz IPS |

## Components

| Role | Tool |
|------|------|
| Window Manager | Hyprland |
| Status Bar | Waybar |
| Application Launcher | Wofi |
| Notification Center | SwayNC |
| Session Lock | Hyprlock |
| Power Menu | Wlogout |
| File Manager | Thunar |
| Terminal Emulator | Kitty |
| Shell | Zsh |
| Shell Prompt | Starship |
| Text Editor | Neovim / VS Code |
| Browser | Zen Browser |
| Image Viewer | Imv |
| PDF Reader | Zathura |
| Media Player | VLC |
| Discord | Vesktop |
| System Monitor | Btop |
| Fetch Tool | Fastfetch |
| Wallpaper | AWWW |
| Clipboard Manager | Cliphist |
| Screenshot | Hyprshot + Satty |
| Bluetooth | Blueman |
| Network | NetworkManager + nm-applet |
| Audio | PipeWire + WirePlumber |
| Cursor | Bibata Modern Classic |
| Color Scheme | Catppuccin Mocha |

## Waybar Modules

- Clock and date
- Workspaces
- Prayer times via [prayerbar](https://github.com/Onizuka893/prayerbar) — built from source, not included in this repo
- Power mode switcher (performance 🔥 / balanced ⚡ / low-power 🌿)
- System tray

## Scripts

Located in `scripts/.local/bin/`:

| Script | Purpose |
|--------|---------|
| `power-mode` | Switches ACPI platform profile and signals Waybar to refresh |
| `battery-alert` | Sends notifications at battery thresholds (30%, 20%, 15%, 10%, 5%, and 90% charged) |
| `fan-max` | Toggles fan to maximum speed for sustained loads |
| `screenshot-region` | Region screenshot piped to Satty for annotation |

## Structure

Managed with [GNU Stow](https://www.gnu.org/software/stow/). Each folder is a stow package that mirrors the home directory structure.

```
Dotfiles/
├── btop/
├── gtk/
├── hypr/
├── kitty/
├── mangohud/
├── sddm/
├── scripts/
├── starship/
├── waybar/
├── wlogout/
├── wofi/
├── xdg/
├── zathura/
└── zsh/
```

## Installation

### Dependencies

```bash
sudo pacman -S stow hyprland waybar wofi swaync hyprlock wlogout kitty zsh starship \
    btop fastfetch awww cliphist wl-clipboard hyprshot satty imv zathura \
    zathura-pdf-mupdf thunar tumbler ffmpegthumbnailer network-manager-applet \
    blueman brightnessctl pipewire pipewire-pulse wireplumber vesktop
```

### Stow

```bash
git clone git@github.com:readeroaltrades/dotfiles.git ~/Dotfiles
cd ~/Dotfiles
stow hypr waybar kitty wofi wlogout starship btop sddm mangohud gtk zathura xdg zsh scripts
```

### SDDM Theme

The SDDM theme is stored in `sddm/.config/sddm/themes/pixel-dusk-city/`. After stowing, point SDDM to it:

`/etc/sddm.conf.d/theme.conf`:
```ini
[Theme]
Current=pixel-dusk-city
ThemeDir=/home/YOUR_USERNAME/.config/sddm/themes
```

Then fix permissions so SDDM (running as root) can read the theme:
```bash
chmod 755 /home/YOUR_USERNAME
chmod -R 755 ~/.config/sddm
```

### Prayerbar

Prayerbar is a compiled Rust binary and is not included in this repo. Build it from source:

```bash
git clone https://github.com/Onizuka893/prayerbar.git
cd prayerbar
cargo build --release
cp target/release/prayerbar ~/.local/bin/
```

### Manual System Configuration

The following system files require manual changes after a fresh install. Refer to the relevant documentation for the specific lines to change:

- `/etc/tlp.conf` — battery optimization
- `/etc/pacman.conf` — enable multilib for Steam
- `/etc/mkinitcpio.conf` — initramfs hooks
- `/etc/sudoers.d/` — passwordless sudo for power-mode
- `/boot/loader/loader.conf` — set timeout to 0
- `/boot/loader/entries/linux-cachyos.conf` — remove quiet/splash
- `/etc/hosts` — telemetry blocks

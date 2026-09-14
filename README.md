# OCEANUS

> NixOS declarativo, Wayland-first, dois monitores.  
> Estação científica oceânica retro-futurista.

```
OCEANUS RESEARCH NETWORK
──────────────────────────────────────
HABITAT SYSTEM 03
BIOLOGICAL / OCEANOGRAPHIC

NixOS  ·  Flakes  ·  Mango  ·  Noctalia
```

---


## Stack

| Componente | Tecnologia |
|---|---|
| OS | NixOS (unstable) |
| Compositor | [Mango](https://github.com/DreamMaoMao/mango) |
| Shell / Bar | [Noctalia](https://github.com/Noctalia-dev/noctalia-shell) |
| Extras | [QuickShell](https://github.com/outfoxxed/quickshell) |
| Login | SDDM Qt6 + [SilentSDDM](https://github.com/uiriansan/SilentSDDM) |
| Terminal | [Ghostty](https://ghostty.org) |
| Shell | Fish + Starship |
| Música | MPD + RMPC + CAVA |

---

## Estrutura

```
nixos-config/
├── flake.nix
│
├── hosts/
│   └── desktop/
│       ├── default.nix            ← entry point da máquina
│       └── hardware-configuration.nix   ← gerado pelo nixos-generate-config
│
├── modules/
│   ├── boot.nix
│   ├── networking.nix
│   ├── audio.nix
│   ├── graphics.nix
│   ├── gaming.nix
│   ├── portals.nix
│   ├── services.nix
│   └── packages.nix
│
├── desktop/
│   ├── mango/
│   │   ├── config.conf
│   │   ├── float.conf
│   │   └── scripts/
│   ├── noctalia/
│   │   ├── bar-oceanus.toml
│   │   └── palettes/oceanus.toml
│   └── sddm/
│       └── sddm.nix
│
├── apps/
│   ├── mpd/mpd.conf
│   ├── ghostty/config
│   └── starship/starship.toml
│
└── assets/
    ├── wallpapers/
    └── sddm/
```

---

## Instalação

### 1. Preparar hardware

```bash
# Identificar monitores
wlr-randr

# Anotar os nomes — ex: DP-1, HDMI-A-1
# Editar desktop/mango/config.conf → seção "Monitor rules"
```

### 2. Gerar hardware config

```bash
sudo nixos-generate-config --show-hardware-config > hosts/desktop/hardware-configuration.nix
```

### 3. Ajustar host

Editar [`hosts/desktop/default.nix`](hosts/desktop/default.nix):

```nix
networking.hostName = "oceanus";          # seu hostname
users.users.usuario = { ... };            # seu username
time.timeZone = "America/Sao_Paulo";
i18n.defaultLocale = "pt_BR.UTF-8";
```

### 4. Ajustar GPU

Editar [`modules/graphics.nix`](modules/graphics.nix) e descomentar o bloco da sua GPU.

### 5. Build

```bash
nixos-rebuild build --flake .#desktop
```

### 6. Instalar

```bash
sudo nixos-rebuild switch --flake .#desktop
```

---

## Dotfiles

Após o rebuild, copiar os dotfiles para o lugar correto:

```bash
# Mango
mkdir -p ~/.config/mango/scripts
cp desktop/mango/config.conf ~/.config/mango/
cp desktop/mango/float.conf  ~/.config/mango/
cp desktop/mango/scripts/*.sh ~/.config/mango/scripts/
chmod +x ~/.config/mango/scripts/*.sh

# Ghostty
mkdir -p ~/.config/ghostty
cp apps/ghostty/config ~/.config/ghostty/config

# Starship
mkdir -p ~/.config
cp apps/starship/starship.toml ~/.config/starship.toml

# MPD
mkdir -p ~/.config/mpd ~/Music/Playlists
cp apps/mpd/mpd.conf ~/.config/mpd/mpd.conf
```

---

## Paleta OCEANUS

| Nome | Hex | Uso |
|---|---|---|
| Abyss | `#07141A` | Fundo principal |
| Deep Blue | `#0B2029` | Superfícies |
| Petrol | `#10343A` | Variante de superfície |
| Ocean | `#164B55` | Hover / focus |
| Moss | `#394B36` | Verde escuro |
| Fern | `#526B4B` | Verde médio / sucesso |
| Seaweed | `#2E5547` | Teal |
| Parchment | `#D8D1B8` | Texto principal |
| Bone | `#E3DDC9` | Texto sobre superfície |
| Mist | `#AAB7AF` | Texto secundário |
| Seafoam | `#8EBFAF` | Acento primário |
| Copper | `#B9784A` | Acento secundário |
| Amber | `#C79B52` | Aviso / destaque |
| Oxide | `#8D5C4C` | Erro |

---

## Fases

- **Fase 1** ✓ Sistema mínimo — Mango + Noctalia + dois monitores
- **Fase 2** Window management — ajustes de tags, layouts, floating
- **Fase 3** Noctalia — bar, launcher, control center com estética OCEANUS
- **Fase 4** Identidade — fontes, GTK/Qt, ícones, cursor, wallpapers, SDDM, Plymouth
- **Fase 5** Extras — MPD visualização, CAVA, QuickShell widgets

---

## Base técnica

Fundação: [`mikuri12/my-nixos-config`](https://github.com/mikuri12/my-nixos-config)  
Identidade: OCEANUS — própria.

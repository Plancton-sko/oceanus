# OCEANUS

> NixOS declarativo, Wayland-first, dois monitores.  
> Estação científica oceânica retro-futurista.

```
OCEANUS RESEARCH NETWORK
─────────────────────────────────────────────────────────────
HOST: oceanus | COMPOSITOR: Mango | SHELL: Noctalia
PALETA: Oceanus Base / Oceano / Floresta / Pinturas Clássicas / Matugen
─────────────────────────────────────────────────────────────
```

---

## Estrutura do Repositório

```
nixos-config/
├── flake.nix                  # Flake com NixOS + Home Manager
├── hosts/
│   └── oceanus/
│       ├── default.nix        # Módulo do host oceanus
│       ├── home.nix           # Home Manager (dotfiles declarativos)
│       └── hardware-configuration.nix
├── modules/                   # Módulos NixOS de sistema
│   ├── boot.nix
│   ├── networking.nix
│   ├── audio.nix
│   ├── graphics.nix
│   ├── gaming.nix
│   ├── portals.nix
│   ├── services.nix
│   └── packages.nix
├── desktop/                   # Configurações do ambiente desktop
│   ├── mango/                 # Compositor Mango + scripts
│   ├── noctalia/              # Shell / Bar / Paletas
│   ├── sddm/                  # Display Manager
│   └── themes/                # Presets de temas (Oceanus, Oceano, Floresta, Pinturas)
├── apps/                      # Aplicações do usuário
│   ├── ghostty/               # Terminal Ghostty
│   ├── starship/              # Prompt Starship
│   ├── mpd/                   # Music Player Daemon
│   ├── rmpc/                  # Cliente MPD
│   └── matugen/               # Gerador dinâmico de cores por wallpaper
└── assets/                    # Papéis de parede e ilustrações
```

---

## Como Instalar (100% Declarativo)

1. **Clonar este repositório**:
   ```bash
   cd ~/dev/rice/rice_teste/my-nixos-config
   ```

2. **Gerar o hardware-configuration.nix da sua máquina**:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/oceanus/hardware-configuration.nix
   ```

3. **Executar a reconstrução declarativa do NixOS + Home Manager**:
   ```bash
   sudo nixos-rebuild switch --flake .#oceanus
   ```

> **Zero passos manuais!** O Home Manager vincula automaticamente todos os dotfiles (`mango`, `noctalia`, `ghostty`, `starship`, `mpd`, `matugen`, `themes`) para `~/.config/`.

---

## Temas & Gerenciamento Visual

- **Alternar Temas**:
  Execute o script de seleção de temas (ou abra via Wofi):
  ```bash
  bash ~/.config/desktop/mango/scripts/theme-select.sh
  ```
  *Opções:* `OCEANUS Base`, `Oceano`, `Floresta`, `Pinturas Clássicas` ou `Matugen (Dinâmico)`.

- **Trocar Wallpaper + Matugen Dinâmico**:
  ```bash
  bash ~/.config/desktop/mango/scripts/set-wallpaper.sh /caminho/para/imagem.jpg dynamic
  ```

---

## Principais Atalhos do Teclado

| Atalho | Ação |
|---|---|
| `Super + Space` | Launcher (Noctalia) |
| `Super + S` | Control Center (Noctalia) |
| `Super + Return` | Terminal (Ghostty) |
| `Super + E` | File Manager TUI (Yazi) |
| `Super + Shift + W` | Navegador (Brave) |
| `Super + O` | Overview de janelas |
| `Super + Shift + O` | Overlay do Mango |
| `Alt + H / J / K / L` | Foco de janela (Vi-style) |
| `Super + Shift + H / J / K / L` | Mover janela |
| `Alt + Shift + ← / →` | Mover foco entre monitores (`DP-3` / `HDMI-A-1`) |
| `Super + Alt + ← / →` | Mover janela para outro monitor |
| `Super + 1..9` | Trocar workspace/tag |
| `Super + Shift + 1..9` | Mover janela para workspace/tag |

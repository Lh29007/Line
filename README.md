# LINE - Line is Not an Emulator

> **Wine inversé pour Linux sur Windows**  
> Exécutez des binaires Linux (.deb, AppImage, ELF) sur Windows via WSL

```
██╗     ██╗███╗   ██╗███████╗
██║     ██║████╗  ██║██╔════╝
██║     ██║██╔██╗ ██║█████╗  
██║     ██║██║╚██╗██║██╔══╝  
███████╗██║██║ ╚████║███████╗
╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
```

## Features

- 📦 **Installe** des `.deb`, `.appimage`, et binaires ELF
- 🚀 **Exécute** via WSL (vrai environnement Linux)
- 🗑️ **Gère** les packages (liste, suppression)
- ⚡ **CLI simple** : `line install`, `line run`, `line list`
- 🔧 **Sans admin** : fonctionne dans l'espace utilisateur

## Quick Start

```powershell
# Installer un binaire Linux
line install ./checkra1n

# Lister les packages installés
line list

# Exécuter via WSL
line run checkra1n --version
```

## Installation

### One-liner (recommandé)

```powershell
iwr -useb https://github.com/Lh29007/Line/releases/latest/download/setup.ps1 | iex
```

### Manuelle

```powershell
git clone https://github.com/Lh29007/Line.git $env:USERPROFILE\Desktop\line
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\Desktop\line\setup.ps1"
```

## Commandes

| Commande | Description |
|----------|-------------|
| `install <fichier>` | Installer un .deb, .appimage ou binaire |
| `run <package> [args]` | Exécuter un package via WSL |
| `list` | Lister les packages installés |
| `remove <package>` | Supprimer un package |

## Structure

```
📁 line/
├── 📄 line.ps1        # CLI principal
├── 📄 line.bat        # Launcher Windows
├── 📄 SysInfo.ps1     # Monitoring système
├── 📄 SysInfo.vbs     # Lanceur silencieux SysInfo
├── 📄 SysInfo.bat     # Launcher SysInfo
└── 📄 setup.ps1       # Création raccourcis
```

## License

MIT

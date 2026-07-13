# 🚀 LINE GUI - PowerShell Edition (Sans dépendances!)

## ✨ Pas besoin de...
- ❌ .NET SDK
- ❌ Visual Studio
- ❌ Droits Admin
- ❌ Installation
- ❌ Compilation

## ⚡ Juste PowerShell (natif Windows)

---

## 🚀 DÉMARRAGE (2 secondes)

### Méthode 1️⃣ - Double-clic (le plus simple!)
```
Double-clic sur: line-gui.bat
```

### Méthode 2️⃣ - PowerShell
```powershell
cd C:\Users\aurel\Desktop\line
.\line-gui.ps1
```

### Méthode 3️⃣ - Raccourci clavier
```
Win+X → Terminal → 
cd C:\Users\aurel\Desktop\line && .\line-gui.ps1
```

---

## 📋 MENU PRINCIPAL

```
1. 📦 Installer un package (.deb/.appimage/.bin)
2. 📋 Lister tous les packages
3. ▶️  Exécuter un package
4. 🗑️  Supprimer un package
5. 📁 Ouvrir le dossier packages
6. 🧹 Nettoyer le cache
7. ℹ️  À propos
0. ❌ Quitter
```

---

## 🎯 UTILISATION SIMPLE

### Installer un package
```
1. Choisir: 1
2. Entrer le chemin: C:\Téléchargements\app.deb
3. Confirmer
✅ Package installé dans packages/deb/
```

### Lister les packages
```
Choisir: 2
Voir tous les packages avec leur type et chemin
```

### Exécuter un package
```
1. Choisir: 3
2. Sélectionner le numéro du package
✅ Application lancée
```

### Supprimer un package
```
1. Choisir: 4
2. Sélectionner le numéro
3. Confirmer (O/n)
✅ Package supprimé
```

---

## 📁 STOCKAGE

```
C:\Users\aurel\Desktop\line\
├── packages/
│   ├── deb/        ← Paquets .deb
│   ├── appimage/   ← AppImages
│   └── bin/        ← Binaires
├── cache/          ← Cache temporaire
├── config/         ← Configuration
└── logs/           ← Logs (futur)
```

---

## 💾 FORMATS SUPPORTÉS

| Format | Type | Support |
|--------|------|---------|
| .deb | Paquet Debian | ✅ Installer/lister |
| .appimage | App portable | ✅ Installer/exécuter |
| .exe | Exécutable Windows | ✅ Installer/exécuter |
| .bin | Binaire Linux | ✅ Installer/exécuter |

---

## 🔧 CARACTÉRISTIQUES

✅ Interface interactive claire  
✅ Gestion d'erreurs  
✅ Confirmation avant suppression  
✅ Statistiques en temps réel  
✅ Coloration syntaxe  
✅ Navigation facile  
✅ Aucune dépendance externe  

---

## ⚡ AVANTAGES

🟢 **Zéro installation**
- Pas besoin de .NET
- Pas besoin de compilation
- Fonctionne immédiatement

🟢 **Sans admin**
- Installez dans votre dossier utilisateur
- Aucun accès système requis
- Totalement sécurisé

🟢 **Pur PowerShell**
- Natif Windows 10/11
- Aucune dépendance externe
- 15KB seulement

🟢 **Simple & rapide**
- Interface intuitive
- Pas de configuration
- 2 secondes de lancement

---

## 🎮 COMMANDES CLAVIER

| Action | Entrée |
|--------|--------|
| Installer | `1` |
| Lister | `2` |
| Exécuter | `3` |
| Supprimer | `4` |
| Dossier | `5` |
| Cache | `6` |
| About | `7` |
| Quitter | `0` |

Puis appuyer sur **Entrée**

---

## 📊 EXEMPLE DE SESSION

```
╔════════════════════════════════════════════╗
║  🚀 LINE GUI                               ║
╚════════════════════════════════════════════╝

📊 STATISTIQUES:
  Paquets total: 0 | .deb: 0 | AppImage: 0 | Binaires: 0

1. 📦 Installer un package
2. 📋 Lister tous les packages
...
0. ❌ Quitter

Votre choix (0-7): 1

📦 INSTALLER UN PACKAGE

Chemin du fichier (.deb/.appimage/.bin/.exe): C:\Téléchargements\app.deb

Fichier: app.deb
Type: .deb
Nom du package: app

Installation en tant que package .deb...
✅ Package installé avec succès!

Appuyer sur Entrée pour continuer
```

---

## 🆘 DÉPANNAGE

### L'app ne se lance pas
```powershell
# Vérifier PowerShell
$PSVersionTable.PSVersion

# Relancer avec debug
.\line-gui.ps1 -Debug
```

### "Fichier non trouvé"
→ Vérifier le chemin exact du fichier

### "Impossible de supprimer"
→ Fermer les applications utilisant le package d'abord

### Rien ne s'affiche
→ Essayer: `.\line-gui.bat` au lieu de `.\line-gui.ps1`

---

## 🚀 COMPARAISON VERSIONS

| Critère | PowerShell | WPF (C#) |
|---------|-----------|---------|
| Installation | ❌ Aucune | ✅ .NET 8 requiert |
| Admin requis | ❌ Non | ⚠️ Premiers lancement |
| Taille | 15 KB | 100-150 MB |
| Lancement | ~1s | ~2-3s |
| Interface | Terminal | Windows moderne |
| Dépendances | ❌ Aucune | ⚠️ .NET Framework |

**Choix**: Utiliser PowerShell pour la **rapidité et la simplicité**! 🎯

---

## 📚 FICHIERS ASSOCIÉS

- `line.ps1` - Backend CLI (alternative)
- `line-gui.ps1` - GUI PowerShell (CELUI-CI)
- `GUI_QUICKSTART.md` - Documentation générale
- `STATUS.md` - État du projet

---

## ✅ PRÊT?

```bash
1. Double-clic: line-gui.bat
2. OU: .\line-gui.ps1
3. OU: cd C:\Users\aurel\Desktop\line && .\line-gui.ps1
```

**C'est tout! Aucune configuration, aucune installation, juste PowerShell!** 🚀

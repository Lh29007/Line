# 🖥️ LINE GUI - Interface graphique Windows

## Caractéristiques

**Une interface WPF moderne et intuitive pour LINE**

- 🎨 Design sombre professionnel (Dark theme)
- ⚡ Réactif et rapide
- 📦 Gestion complète des packages
- 🎯 Ergonomie optimale
- ✨ Thème bleu Microsoft moderne

---

## 🚀 Installation & Compilation

### Prérequis
- Windows 10/11
- .NET 8 SDK (avec support WPF)

### Compiler la GUI

**Option 1 - Double-clic (simpliste)**
```bash
build-gui.bat
```

**Option 2 - Commande**
```bash
cd C:\Users\aurel\Desktop\line
dotnet build GUI -c Release
dotnet publish GUI -c Release -o bin
```

### Résultat
```
C:\Users\aurel\Desktop\line\bin\LINE.exe
```

---

## 🎯 Fonctionnalités

### Installation
1. **Sélectionner un fichier** → "Parcourir..."
2. **Choisir** .deb, .appimage ou binaire
3. **Installer** → Bouton "Installer"
4. ✅ Package installé automatiquement

### Gestion des packages
- 📋 **Lister** tous les packages installés
- ▶️ **Exécuter** un package (double-clic ou bouton)
- 🗑️ **Supprimer** un package avec confirmation
- 🔄 **Rafraîchir** la liste

### Actions rapides
- **Rafraîchir** - Met à jour la liste
- **Ouvrir le dossier** - Accès direct aux packages
- **Nettoyer le cache** - Libère de l'espace

### Statistiques
- Nombre total de packages
- Packages .deb installés
- AppImages installées
- Binaires installés

---

## 💻 Interface détaillée

### En-tête (Header)
```
🚀 LINE - Line is Not an Emulator
Wine inversé pour exécuter du Linux sur Windows
```

### Panneau gauche (Actions)
```
📦 Installer un package
   [Parcourir...] [Installer]
   Status: ✅ Prêt

⚡ Actions rapides
   [🔄 Rafraîchir]
   [📁 Ouvrir le dossier]
   [🗑️ Nettoyer le cache]

📊 Statistiques
   Paquets: X
   .deb: X
   AppImages: X
   Binaires: X
```

### Panneau droit (Liste des packages)
```
📦 Package1
   .deb - Paquet Debian
   C:\...\packages\deb\Package1
   [▶️ Exécuter] [🗑️ Supprimer]

🐧 Package2
   AppImage - Application portable Linux
   [▶️ Exécuter] [🗑️ Supprimer]

⚙️ Package3
   Binaire - Exécutable
   [▶️ Exécuter] [🗑️ Supprimer]
```

### Pied de page (Footer)
```
LINE v0.1.0 Beta | ... | ❌ Sans WSL • ❌ Sans Admin • ✓ Pur Windows
```

---

## 🎨 Palette de couleurs

| Couleur | Utilisation |
|---------|-------------|
| #0078d4 | Texte principal, bordures, accents |
| #1e1e1e | Fond principal (très sombre) |
| #2d2d2d | Bordures, panels |
| #28a745 | Bouton Installer (vert) |
| #dc3545 | Bouton Supprimer (rouge) |
| #17a2b8 | Bouton Ouvrir dossier (cyan) |
| #fd7e14 | Bouton Nettoyer (orange) |
| #a0a0a0 | Texte secondaire (gris) |

---

## ⌨️ Raccourcis

- **Double-clic sur package** → Exécuter
- **Clic sur bouton Exécuter** → Lancer l'app
- **Clic sur bouton Supprimer** → Supprimer (avec confirmation)

---

## 🆘 Dépannage

### "EXE not found"
Compiler d'abord:
```bash
.\build-gui.bat
```

### "Application not launching"
- Vérifier que le package est complètement installé
- Utiliser "Ouvrir le dossier" pour voir les fichiers
- Vérifier qu'il y a un exécutable

### "WPF not found"
Installer les libs WPF:
```bash
dotnet workload install wpf-windows
```

---

## 📝 Utilisation typique

1. **Lancer LINE.exe**
2. **Cliquer "Parcourir..."**
3. **Sélectionner** app.deb / app.appimage / binary
4. **Cliquer "Installer"**
5. ✅ **Le package apparaît dans la liste**
6. **Double-clic pour exécuter** ou **Bouton "Exécuter"**

---

## 🚀 Améliorations futures

- [ ] Recherche/filtrage des packages
- [ ] Barre de progression pour l'installation
- [ ] Logs détaillés de l'installation
- [ ] Téléchargement depuis URLs
- [ ] Thèmes personnalisables
- [ ] Gestionnaire de dépôts
- [ ] Support du drag & drop
- [ ] Notifications système

---

## 📦 Architecture

```
GUI/
├── MainWindow.xaml           ← Interface (design)
├── MainWindow.xaml.cs        ← Logique (C#)
├── App.xaml                  ← Configuration app
├── App.xaml.cs               ← Point d'entrée
└── Models/
    └── PackageItem.cs        ← Modèle de données
```

---

**LINE GUI v0.1.0 Beta**  
Interface WPF pour LINE  
Prêt à compiler et utiliser! 🎉

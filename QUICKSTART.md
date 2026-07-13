# 🚀 LINE - Démarrage rapide

## 5 minutes pour commencer

### 1️⃣ Compiler

```powershell
cd C:\Users\aurel\Desktop\line

# Option A - Double-clic sur build.bat
# Option B - Commande:
dotnet publish -c Release -o bin
```

### 2️⃣ Tester

```bash
cd bin
.\line.exe --help
.\line.exe --version
```

### 3️⃣ Utiliser

```bash
# Installer une AppImage
.\line.exe install C:\path\to\app.appimage

# Lancer
.\line.exe run app

# Lister
.\line.exe list
```

---

## 📋 Fichiers importants

| Fichier | Rôle |
|---------|------|
| `src/Line.cs` | Code source principal |
| `line.csproj` | Configuration du projet |
| `build.bat` | Script de compilation |
| `line.bat` | Launcher Windows |
| `README.md` | Documentation complète |

---

## ✨ Fonctionnalités

### ✅ Implémentées
- Installation .deb
- Installation .appimage
- Installation binaires
- Gestion des packages
- Exécution des apps

### 🔄 À venir
- Meilleure extraction .deb
- Résolution des dépendances
- Support des permissions Unix
- Interface GUI
- Gestionnaire de repos

---

## 🎯 Prochaines étapes

1. **Compiler** → `dotnet publish -c Release -o bin`
2. **Tester** → `line.exe --help`
3. **Ajouter des features** → Modifier `src/Line.cs`
4. **Partager** → Partager avec la communauté!

---

## 📞 Besoin d'aide?

Consulte `README.md` pour:
- Installation détaillée
- Exemples d'utilisation
- Architecture complète
- Dépannage

---

**LINE v0.1.0 Beta - Prêt à développer! 🚀**

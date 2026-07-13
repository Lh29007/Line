using System;
using System.Diagnostics;
using System.IO;
using System.Collections.Generic;
using System.IO.Compression;
using System.Text.Json;
using System.Linq;

namespace LINE.Core
{
    /// <summary>
    /// LINE - Line is Not an Emulator
    /// Un Wine inversé pour exécuter des binaires Linux sur Windows sans WSL
    /// </summary>
    public class LineManager
    {
        public static string BaseDir { get; private set; }
        public static string PackagesDir { get; private set; }
        public static string CacheDir { get; private set; }
        public static string ConfigDir { get; private set; }

        static LineManager()
        {
            BaseDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Desktop", "line");
            PackagesDir = Path.Combine(BaseDir, "packages");
            CacheDir = Path.Combine(BaseDir, "cache");
            ConfigDir = Path.Combine(BaseDir, "config");

            EnsureDirectories();
        }

        static void EnsureDirectories()
        {
            Directory.CreateDirectory(BaseDir);
            Directory.CreateDirectory(PackagesDir);
            Directory.CreateDirectory(Path.Combine(PackagesDir, "deb"));
            Directory.CreateDirectory(Path.Combine(PackagesDir, "appimage"));
            Directory.CreateDirectory(Path.Combine(PackagesDir, "bin"));
            Directory.CreateDirectory(CacheDir);
            Directory.CreateDirectory(ConfigDir);
        }

        public static void PrintBanner()
        {
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine(@"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║   LINE - Line is Not an Emulator                       ║
║   Wine inversé pour Linux sur Windows                  ║
║   v0.1.0 Beta                                          ║
║                                                        ║
║   Exécutez .deb, .appimage, binaires Linux            ║
║   Sans WSL • Sans Admin • Pur Windows                  ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
");
            Console.ResetColor();
        }

        public static void Main(string[] args)
        {
            PrintBanner();

            if (args.Length == 0)
            {
                ShowHelp();
                return;
            }

            string command = args[0].ToLower();
            string[] cmdArgs = args.Skip(1).ToArray();

            try
            {
                switch (command)
                {
                    case "install":
                        InstallPackage(cmdArgs);
                        break;
                    case "run":
                        RunPackage(cmdArgs);
                        break;
                    case "list":
                        ListPackages();
                        break;
                    case "remove":
                        RemovePackage(cmdArgs);
                        break;
                    case "exec":
                        ExecuteBinary(cmdArgs);
                        break;
                    case "--version":
                    case "-v":
                        Console.WriteLine("LINE v0.1.0 Beta");
                        break;
                    case "--help":
                    case "-h":
                        ShowHelp();
                        break;
                    default:
                        Console.WriteLine($"Commande inconnue: {command}");
                        ShowHelp();
                        break;
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine($"❌ Erreur: {ex.Message}");
                Console.ResetColor();
            }
        }

        static void InstallPackage(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Usage: line install <fichier.deb|fichier.appimage|binaire>");
                return;
            }

            string filePath = args[0];

            if (!File.Exists(filePath))
            {
                Console.WriteLine($"❌ Fichier non trouvé: {filePath}");
                return;
            }

            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine($"📦 Installation de: {Path.GetFileName(filePath)}");
            Console.ResetColor();

            if (filePath.EndsWith(".deb"))
                InstallDeb(filePath);
            else if (filePath.EndsWith(".appimage"))
                InstallAppImage(filePath);
            else if (File.Exists(filePath) && IsExecutable(filePath))
                InstallBinary(filePath);
            else
                Console.WriteLine("❌ Format non reconnu (.deb, .appimage ou exécutable)");
        }

        static void InstallDeb(string debFile)
        {
            string packageName = Path.GetFileNameWithoutExtension(debFile);
            string extractDir = Path.Combine(CacheDir, packageName);

            Console.WriteLine($"[*] Extraction du fichier .deb...");
            try
            {
                // Les .deb sont des archives ar
                // On les traite comme des ZIP pour simplifier
                ZipFile.ExtractToDirectory(debFile, extractDir, true);
                
                string targetDir = Path.Combine(PackagesDir, "deb", packageName);
                Directory.CreateDirectory(targetDir);

                // Copier les fichiers extraits
                foreach (string file in Directory.GetFiles(extractDir, "*", SearchOption.AllDirectories))
                {
                    string relative = Path.GetRelativePath(extractDir, file);
                    string dest = Path.Combine(targetDir, relative);
                    Directory.CreateDirectory(Path.GetDirectoryName(dest));
                    File.Copy(file, dest, true);
                }

                Console.ForegroundColor = ConsoleColor.Green;
                Console.WriteLine($"✅ Paquet .deb installé: {targetDir}");
                Console.ResetColor();

                // Nettoyer le cache
                Directory.Delete(extractDir, true);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erreur lors de l'installation: {ex.Message}");
            }
        }

        static void InstallAppImage(string appImageFile)
        {
            string appName = Path.GetFileNameWithoutExtension(appImageFile);
            string targetDir = Path.Combine(PackagesDir, "appimage", appName);

            Directory.CreateDirectory(targetDir);

            Console.WriteLine($"[*] Installation AppImage...");
            
            // Les AppImage peuvent être montées ou exécutées directement
            string targetPath = Path.Combine(targetDir, Path.GetFileName(appImageFile));
            File.Copy(appImageFile, targetPath, true);

            // Créer un launcher script
            string launcherPath = Path.Combine(targetDir, "run.bat");
            string launcher = $@"@echo off
REM Launcher pour {appName}
cd /d ""{targetDir}""
""{targetPath}"" %*
";
            File.WriteAllText(launcherPath, launcher);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"✅ AppImage installé: {targetDir}");
            Console.WriteLine($"   Lancer avec: line run {appName}");
            Console.ResetColor();
        }

        static void InstallBinary(string binaryFile)
        {
            string binaryName = Path.GetFileNameWithoutExtension(binaryFile);
            string targetDir = Path.Combine(PackagesDir, "bin", binaryName);

            Directory.CreateDirectory(targetDir);

            Console.WriteLine($"[*] Installation binaire...");
            
            string targetPath = Path.Combine(targetDir, Path.GetFileName(binaryFile));
            File.Copy(binaryFile, targetPath, true);

            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine($"✅ Binaire installé: {targetDir}");
            Console.WriteLine($"   Lancer avec: line run {binaryName}");
            Console.ResetColor();
        }

        static void RunPackage(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Usage: line run <nom_package> [arguments]");
                return;
            }

            string packageName = args[0];
            string[] execArgs = args.Skip(1).ToArray();

            Console.WriteLine($"🚀 Exécution de: {packageName}");

            // Chercher le package
            string appImagePath = Path.Combine(PackagesDir, "appimage", packageName, Path.GetFileName(
                Directory.GetFiles(Path.Combine(PackagesDir, "appimage", packageName), "*.appimage", SearchOption.TopDirectoryOnly).FirstOrDefault() ?? ""
            ));

            if (File.Exists(appImagePath))
            {
                ExecuteAppImage(appImagePath, execArgs);
                return;
            }

            string binPath = Directory.GetFiles(
                Path.Combine(PackagesDir, "bin", packageName), "*", SearchOption.AllDirectories
            ).FirstOrDefault();

            if (!string.IsNullOrEmpty(binPath))
            {
                ExecuteBinaryDirect(binPath, execArgs);
                return;
            }

            Console.WriteLine($"❌ Package non trouvé: {packageName}");
        }

        static void ExecuteBinary(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Usage: line exec <binaire> [arguments]");
                return;
            }

            string binaryPath = args[0];
            string[] execArgs = args.Skip(1).ToArray();

            ExecuteBinaryDirect(binaryPath, execArgs);
        }

        static void ExecuteBinaryDirect(string binaryPath, string[] args)
        {
            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = binaryPath,
                    Arguments = string.Join(" ", args),
                    UseShellExecute = true,
                    CreateNoWindow = false
                };

                using (var process = Process.Start(psi))
                {
                    process.WaitForExit();
                    if (process.ExitCode != 0)
                        Console.WriteLine($"⚠️  Code de sortie: {process.ExitCode}");
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erreur: {ex.Message}");
            }
        }

        static void ExecuteAppImage(string appImagePath, string[] args)
        {
            try
            {
                var psi = new ProcessStartInfo
                {
                    FileName = appImagePath,
                    Arguments = string.Join(" ", args),
                    UseShellExecute = true,
                    CreateNoWindow = false
                };

                using (var process = Process.Start(psi))
                {
                    process.WaitForExit();
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Erreur: {ex.Message}");
            }
        }

        static void ListPackages()
        {
            Console.WriteLine("\n📦 Packages installés:\n");

            var debPackages = Directory.GetDirectories(Path.Combine(PackagesDir, "deb"));
            if (debPackages.Length > 0)
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("Paquets .deb:");
                Console.ResetColor();
                foreach (var pkg in debPackages)
                    Console.WriteLine($"  • {Path.GetFileName(pkg)}");
                Console.WriteLine();
            }

            var appImages = Directory.GetDirectories(Path.Combine(PackagesDir, "appimage"));
            if (appImages.Length > 0)
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("AppImages:");
                Console.ResetColor();
                foreach (var pkg in appImages)
                    Console.WriteLine($"  • {Path.GetFileName(pkg)}");
                Console.WriteLine();
            }

            var binaries = Directory.GetDirectories(Path.Combine(PackagesDir, "bin"));
            if (binaries.Length > 0)
            {
                Console.ForegroundColor = ConsoleColor.Yellow;
                Console.WriteLine("Binaires:");
                Console.ResetColor();
                foreach (var pkg in binaries)
                    Console.WriteLine($"  • {Path.GetFileName(pkg)}");
                Console.WriteLine();
            }

            if (debPackages.Length == 0 && appImages.Length == 0 && binaries.Length == 0)
                Console.WriteLine("Aucun package installé");
        }

        static void RemovePackage(string[] args)
        {
            if (args.Length == 0)
            {
                Console.WriteLine("Usage: line remove <nom_package>");
                return;
            }

            string packageName = args[0];
            bool found = false;

            // Chercher dans deb
            string debPath = Path.Combine(PackagesDir, "deb", packageName);
            if (Directory.Exists(debPath))
            {
                Directory.Delete(debPath, true);
                Console.WriteLine($"✅ Paquet .deb supprimé: {packageName}");
                found = true;
            }

            // Chercher dans appimage
            string appPath = Path.Combine(PackagesDir, "appimage", packageName);
            if (Directory.Exists(appPath))
            {
                Directory.Delete(appPath, true);
                Console.WriteLine($"✅ AppImage supprimée: {packageName}");
                found = true;
            }

            // Chercher dans bin
            string binPath = Path.Combine(PackagesDir, "bin", packageName);
            if (Directory.Exists(binPath))
            {
                Directory.Delete(binPath, true);
                Console.WriteLine($"✅ Binaire supprimé: {packageName}");
                found = true;
            }

            if (!found)
                Console.WriteLine($"❌ Package non trouvé: {packageName}");
        }

        static void ShowHelp()
        {
            Console.WriteLine(@"
Commandes disponibles:

  install <fichier>        Installer un .deb, .appimage ou binaire
  run <package> [args]     Exécuter un package installé
  exec <binaire> [args]    Exécuter un binaire directement
  list                     Lister les packages installés
  remove <package>         Supprimer un package
  --help, -h               Afficher cette aide
  --version, -v            Afficher la version

Exemples:
  line install ./app.deb
  line install ./app.appimage
  line run monapp
  line list
  line remove monapp
");
        }

        static bool IsExecutable(string filePath)
        {
            try
            {
                byte[] header = new byte[2];
                using (var fs = new FileStream(filePath, FileMode.Open, FileAccess.Read))
                {
                    fs.Read(header, 0, 2);
                }
                // Vérifier le magic number des exécutables
                return (header[0] == 0x4D && header[1] == 0x5A) || // MZ (Windows)
                       (header[0] == 0x7F && header[1] == 0x45);   // ELF (Linux)
            }
            catch
            {
                return false;
            }
        }
    }
}

using System.Windows;
using System.Windows.Controls;
using System.IO;
using System.Linq;
using System.Collections.ObjectModel;
using System.Diagnostics;
using Microsoft.Win32;

namespace LINE.GUI
{
    public partial class MainWindow : Window
    {
        private string BaseDir { get; set; }
        private string PackagesDir { get; set; }
        private string DebDir { get; set; }
        private string AppImageDir { get; set; }
        private string BinDir { get; set; }
        private ObservableCollection<PackageItem> Packages { get; set; }

        public MainWindow()
        {
            InitializeComponent();
            
            BaseDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), "Desktop", "line");
            PackagesDir = Path.Combine(BaseDir, "packages");
            DebDir = Path.Combine(PackagesDir, "deb");
            AppImageDir = Path.Combine(PackagesDir, "appimage");
            BinDir = Path.Combine(PackagesDir, "bin");

            EnsureDirectories();
            
            Packages = new ObservableCollection<PackageItem>();
            PackagesListBox.ItemsSource = Packages;
            
            RefreshPackageList();
        }

        void EnsureDirectories()
        {
            Directory.CreateDirectory(BaseDir);
            Directory.CreateDirectory(PackagesDir);
            Directory.CreateDirectory(DebDir);
            Directory.CreateDirectory(AppImageDir);
            Directory.CreateDirectory(BinDir);
        }

        void RefreshPackageList()
        {
            Packages.Clear();

            // Charger .deb packages
            if (Directory.Exists(DebDir))
            {
                foreach (var dir in Directory.GetDirectories(DebDir))
                {
                    string name = Path.GetFileName(dir);
                    Packages.Add(new PackageItem 
                    { 
                        Icon = "📦", 
                        Name = name, 
                        Type = ".deb - Paquet Debian",
                        Path = dir 
                    });
                }
            }

            // Charger AppImages
            if (Directory.Exists(AppImageDir))
            {
                foreach (var dir in Directory.GetDirectories(AppImageDir))
                {
                    string name = Path.GetFileName(dir);
                    Packages.Add(new PackageItem 
                    { 
                        Icon = "🐧", 
                        Name = name, 
                        Type = "AppImage - Application portable Linux",
                        Path = dir 
                    });
                }
            }

            // Charger Binaires
            if (Directory.Exists(BinDir))
            {
                foreach (var dir in Directory.GetDirectories(BinDir))
                {
                    string name = Path.GetFileName(dir);
                    Packages.Add(new PackageItem 
                    { 
                        Icon = "⚙️", 
                        Name = name, 
                        Type = "Binaire - Exécutable",
                        Path = dir 
                    });
                }
            }

            UpdateStats();
        }

        void UpdateStats()
        {
            int total = Packages.Count;
            int deb = Directory.Exists(DebDir) ? Directory.GetDirectories(DebDir).Length : 0;
            int appImage = Directory.Exists(AppImageDir) ? Directory.GetDirectories(AppImageDir).Length : 0;
            int bin = Directory.Exists(BinDir) ? Directory.GetDirectories(BinDir).Length : 0;

            PackageCountText.Text = total.ToString();
            DebCountText.Text = deb.ToString();
            AppImageCountText.Text = appImage.ToString();
            BinaryCountText.Text = bin.ToString();
        }

        void BrowseButton_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog dialog = new OpenFileDialog
            {
                Filter = "Tous les packages (*.deb;*.appimage;*.exe;*.bin)|*.deb;*.appimage;*.exe;*.bin|" +
                        "Paquets Debian (*.deb)|*.deb|" +
                        "AppImages (*.appimage)|*.appimage|" +
                        "Tous les fichiers (*.*)|*.*",
                Title = "Sélectionner un package à installer"
            };

            if (dialog.ShowDialog() == true)
            {
                FilePathTextBox.Text = dialog.FileName;
                InstallStatus.Text = $"Prêt à installer: {Path.GetFileName(dialog.FileName)}";
            }
        }

        void InstallButton_Click(object sender, RoutedEventArgs e)
        {
            if (string.IsNullOrEmpty(FilePathTextBox.Text))
            {
                InstallStatus.Text = "⚠️  Veuillez sélectionner un fichier";
                InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red);
                return;
            }

            try
            {
                string filePath = FilePathTextBox.Text;
                InstallStatus.Text = "⏳ Installation en cours...";
                InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Yellow);

                string fileName = Path.GetFileName(filePath);
                string fileExt = Path.GetExtension(filePath).ToLower();

                if (fileExt == ".deb")
                    InstallDeb(filePath);
                else if (fileExt == ".appimage")
                    InstallAppImage(filePath);
                else
                    InstallBinary(filePath);

                InstallStatus.Text = "✅ Installation réussie!";
                InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.LimeGreen);
                FilePathTextBox.Clear();

                RefreshPackageList();
            }
            catch (Exception ex)
            {
                InstallStatus.Text = $"❌ Erreur: {ex.Message}";
                InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red);
            }
        }

        void InstallDeb(string debFile)
        {
            string packageName = Path.GetFileNameWithoutExtension(debFile);
            string targetDir = Path.Combine(DebDir, packageName);

            Directory.CreateDirectory(targetDir);
            File.Copy(debFile, Path.Combine(targetDir, Path.GetFileName(debFile)), true);
        }

        void InstallAppImage(string appImageFile)
        {
            string appName = Path.GetFileNameWithoutExtension(appImageFile);
            string targetDir = Path.Combine(AppImageDir, appName);

            Directory.CreateDirectory(targetDir);
            File.Copy(appImageFile, Path.Combine(targetDir, Path.GetFileName(appImageFile)), true);
        }

        void InstallBinary(string binaryFile)
        {
            string binaryName = Path.GetFileNameWithoutExtension(binaryFile);
            string targetDir = Path.Combine(BinDir, binaryName);

            Directory.CreateDirectory(targetDir);
            File.Copy(binaryFile, Path.Combine(targetDir, Path.GetFileName(binaryFile)), true);
        }

        void RefreshButton_Click(object sender, RoutedEventArgs e)
        {
            RefreshPackageList();
            InstallStatus.Text = "✅ Rafraîchi";
            InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.LimeGreen);
        }

        void OpenFolderButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                Process.Start(new ProcessStartInfo 
                { 
                    FileName = "explorer.exe", 
                    Arguments = PackagesDir,
                    UseShellExecute = true
                });
            }
            catch { }
        }

        void CleanCacheButton_Click(object sender, RoutedEventArgs e)
        {
            string cacheDir = Path.Combine(BaseDir, "cache");
            if (Directory.Exists(cacheDir))
            {
                try
                {
                    Directory.Delete(cacheDir, true);
                    Directory.CreateDirectory(cacheDir);
                    InstallStatus.Text = "✅ Cache nettoyé";
                    InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.LimeGreen);
                }
                catch (Exception ex)
                {
                    InstallStatus.Text = $"❌ Erreur: {ex.Message}";
                    InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red);
                }
            }
        }

        void RunPackageButton_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag is string packageName)
            {
                try
                {
                    // Chercher dans AppImage
                    string appImageDir = Path.Combine(AppImageDir, packageName);
                    var appImageFiles = Directory.GetFiles(appImageDir, "*.appimage", SearchOption.TopDirectoryOnly);
                    if (appImageFiles.Length > 0)
                    {
                        Process.Start(new ProcessStartInfo { FileName = appImageFiles[0], UseShellExecute = true });
                        return;
                    }

                    // Chercher dans Binaire
                    string binDir = Path.Combine(BinDir, packageName);
                    var binFiles = Directory.GetFiles(binDir).Where(f => 
                        f.EndsWith(".exe") || f.EndsWith(".bin") || 
                        !Path.HasExtension(f)).FirstOrDefault();
                    if (!string.IsNullOrEmpty(binFiles))
                    {
                        Process.Start(new ProcessStartInfo { FileName = binFiles, UseShellExecute = true });
                        return;
                    }

                    InstallStatus.Text = $"⚠️  Impossible de lancer {packageName}";
                    InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Orange);
                }
                catch (Exception ex)
                {
                    InstallStatus.Text = $"❌ Erreur: {ex.Message}";
                    InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red);
                }
            }
        }

        void DeletePackageButton_Click(object sender, RoutedEventArgs e)
        {
            var button = sender as Button;
            if (button?.Tag is string packageName)
            {
                if (MessageBox.Show($"Supprimer {packageName}?", "Confirmation", MessageBoxButton.YesNo) == MessageBoxResult.Yes)
                {
                    try
                    {
                        string debPath = Path.Combine(DebDir, packageName);
                        if (Directory.Exists(debPath))
                            Directory.Delete(debPath, true);

                        string appPath = Path.Combine(AppImageDir, packageName);
                        if (Directory.Exists(appPath))
                            Directory.Delete(appPath, true);

                        string binPath = Path.Combine(BinDir, packageName);
                        if (Directory.Exists(binPath))
                            Directory.Delete(binPath, true);

                        RefreshPackageList();
                        InstallStatus.Text = $"✅ {packageName} supprimé";
                        InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.LimeGreen);
                    }
                    catch (Exception ex)
                    {
                        InstallStatus.Text = $"❌ Erreur: {ex.Message}";
                        InstallStatus.Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red);
                    }
                }
            }
        }
    }

    public class PackageItem
    {
        public string Icon { get; set; } = "";
        public string Name { get; set; } = "";
        public string Type { get; set; } = "";
        public string Path { get; set; } = "";
    }
}

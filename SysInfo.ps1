Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# Get system icons
[System.Windows.Forms.Application]::EnableVisualStyles()

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="SysInfo" Height="520" Width="420" ResizeMode="NoResize"
        WindowStartupLocation="CenterScreen" Topmost="True"
        Background="#1E1E2E" FontFamily="Segoe UI" FontSize="13">
    <Window.Resources>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="#CDD6F4"/>
        </Style>
        <Style TargetType="Label">
            <Setter Property="Foreground" Value="#CDD6F4"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>
        <Style TargetType="ProgressBar">
            <Setter Property="Height" Value="18"/>
            <Setter Property="Margin" Value="0,4,0,8"/>
        </Style>
    </Window.Resources>
    <Border Margin="10" CornerRadius="10" Background="#181825" Padding="15">
        <StackPanel>
            <TextBlock Text="System Info" FontSize="22" FontWeight="Bold" Foreground="#CBA6F7" TextAlignment="Center" Margin="0,0,0,15"/>

            <Label Content="CPU"/><TextBlock Name="cpuText" Margin="10,0,0,5"/>
            <ProgressBar Name="cpuBar" Maximum="100" Foreground="#F38BA8"/>

            <Label Content="RAM"/><TextBlock Name="ramText" Margin="10,0,0,5"/>
            <ProgressBar Name="ramBar" Maximum="100" Foreground="#A6E3A1"/>

            <Label Content="Disque C:"/><TextBlock Name="diskText" Margin="10,0,0,5"/>
            <ProgressBar Name="diskBar" Maximum="100" Foreground="#F9E2AF"/>

            <Label Content="R�seau"/><TextBlock Name="netText" Margin="10,0,0,5"/>

            <Label Content="Syst�me"/><TextBlock Name="osText" Margin="10,0,0,0"/>

            <Button Name="refreshBtn" Content="Refresh" Margin="0,15,0,0" Height="32"
                    HorizontalAlignment="Center" Width="120"
                    Background="#CBA6F7" Foreground="#1E1E2E" FontWeight="Bold"
                    BorderThickness="0" Cursor="Hand">
                <Button.Triggers>
                    <EventTrigger RoutedEvent="Button.Click"><BeginStoryboard><Storyboard/></BeginStoryboard></EventTrigger>
                </Button.Triggers>
            </Button>
            <TextBlock Name="footerText" FontSize="10" Foreground="#585B70" TextAlignment="Center" Margin="0,8,0,0"/>
        </StackPanel>
    </Border>
</Window>
'@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader] $xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)
$cpuText = $window.FindName("cpuText")
$cpuBar = $window.FindName("cpuBar")
$ramText = $window.FindName("ramText")
$ramBar = $window.FindName("ramBar")
$diskText = $window.FindName("diskText")
$diskBar = $window.FindName("diskBar")
$netText = $window.FindName("netText")
$osText = $window.FindName("osText")
$footerText = $window.FindName("footerText")
$refreshBtn = $window.FindName("refreshBtn")

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(2)

function UpdateInfo {
    # CPU
    $cpuCounter = Get-CimInstance Win32_Processor
    $cpuName = $cpuCounter.Name.Trim()
    $cpuLoad = $cpuCounter.LoadPercentage
    if (-not $cpuLoad) { $cpuLoad = 0 }
    $cpuText.Text = "$cpuName - ${cpuLoad}%"
    $cpuBar.Value = $cpuLoad

    # RAM
    $os = Get-CimInstance Win32_OperatingSystem
    $ramTotal = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
    $ramFree = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
    $ramUsed = [math]::Round($ramTotal - $ramFree, 1)
    $ramPct = [math]::Round($ramUsed / $ramTotal * 100, 1)
    $ramText.Text = "${ramUsed} GB / ${ramTotal} GB (${ramPct}%)"
    $ramBar.Value = $ramPct

    # Disk
    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskTotal = [math]::Round($disk.Size / 1GB, 1)
    $diskFree = [math]::Round($disk.FreeSpace / 1GB, 1)
    $diskUsed = [math]::Round($diskTotal - $diskFree, 1)
    $diskPct = [math]::Round($diskUsed / $diskTotal * 100, 1)
    $diskText.Text = "${diskUsed} GB / ${diskTotal} GB (${diskPct}%)"
    $diskBar.Value = $diskPct

    # Network
    $adapters = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -and $_.Speed }
    if ($adapters) {
        $netInfo = ($adapters | ForEach-Object { "$($_.NetConnectionID) - $([math]::Round($_.Speed/1e6)) Mbps" }) -join ", "
        $netText.Text = $netInfo
    } else {
        $netText.Text = "Aucun"
    }

    # OS
    $osInfo = Get-CimInstance Win32_OperatingSystem
    $osText.Text = "$($osInfo.Caption) - Build $($osInfo.BuildNumber)"
    $footerText.Text = "Mis � jour : $(Get-Date -Format 'HH:mm:ss')"
}

$refreshBtn.Add_Click({ UpdateInfo })
$timer.Add_Tick({ UpdateInfo })
UpdateInfo
$timer.Start()
$window.ShowDialog() | Out-Null
$timer.Stop()

Add-Type -AssemblyName System.speech
Add-Type -AssemblyName PresentationCore, PresentationFramework

$global:Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$global:FirstSpeak = $True
$global:GameSelected = 3
$global:GameLaunching = 3
$global:GameInstalled = 3
$global:GameUninstalled = 3

function ShowSettingsWindow() {

$Xaml = @"
<Grid xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation">
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Speak What / Where" Margin="112,12,0,0" Name="lblWhatWhere" FontWeight="Bold"/>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="177" Margin="160,46,0,0" Name="CmbGameSelection" IsDropDownOpen="False" IsTabStop="True" Height="22" AllowDrop="True">
<ComboBoxItem Content="Never"/>
<ComboBoxItem Content="Desktop"/>
<ComboBoxItem Content="Fullscreen"/>
<ComboBoxItem Content="Desktop + Fullscreen"/>
</ComboBox>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="177" Margin="160,86,0,0" Name="CmbGameLaunching" IsDropDownOpen="False" IsTabStop="True" Height="22" AllowDrop="True">
<ComboBoxItem Content="Never"/>
<ComboBoxItem Content="Desktop"/>
<ComboBoxItem Content="Fullscreen"/>
<ComboBoxItem Content="Desktop + Fullscreen"/>
</ComboBox>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="177" Margin="160,126,0,0" Name="CmbGameInstalled" IsDropDownOpen="False" IsTabStop="True" Height="22" AllowDrop="True">
<ComboBoxItem Content="Never"/>
<ComboBoxItem Content="Desktop"/>
<ComboBoxItem Content="Fullscreen"/>
<ComboBoxItem Content="Desktop + Fullscreen"/>
</ComboBox>
<ComboBox HorizontalAlignment="Left" VerticalAlignment="Top" Width="177" Margin="160,166,0,0" Name="CmbGameUninstalled" IsDropDownOpen="False" IsTabStop="True" Height="22" AllowDrop="True">
<ComboBoxItem Content="Never"/>
<ComboBoxItem Content="Desktop"/>
<ComboBoxItem Content="Fullscreen"/>
<ComboBoxItem Content="Desktop + Fullscreen"/>
</ComboBox>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Game Selection:" Margin="15,46,0,0" Name="LblGameSelection"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Game Launching:" Margin="15,86,0,0" Name="LblGameLaunching"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Game Installed:" Margin="15,126,0,0" Name="LblGameInstalled"/>
<Label HorizontalAlignment="Left" VerticalAlignment="Top" Content="Game Uninstalled:" Margin="15,166,0,0" Name="LblCmbGameUninstalled"/>
<Button Content="Ok" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="143,216,0,0" Name="ButOk" IsDefault="True"/>
</Grid>
"@

	#parse the xaml for controls
	$Controls = [Windows.Markup.XamlReader]::Parse($Xaml)

	#make variables for each control in powershell
	[xml]$xml = $Xaml
	$xml.FirstChild.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name $_.Name -Value $Controls.FindName($_.Name) }

	#window options
	$CreationOptions = New-Object Playnite.SDK.WindowCreationOptions
	$CreationOptions.ShowMaximizeButton = $False
	$CreationOptions.ShowMinimizeButton = $False

	#create window needs to be global as i needed to access it from butokclick
	$global:Window = $PlayniteApi.Dialogs.CreateWindow($CreationOptions)
	$global:Window.Content = $Controls
	$global:Window.Width = 380;
	$global:Window.Height = 280;
	$global:Window.Title = "Game Speak Settings"

	#set the owner so we can center it using startup location
	$global:Window.Owner = $PlayniteApi.Dialogs.GetCurrentAppWindow()
	$global:Window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterOwner
	$global:Window.ResizeMode = [System.Windows.ResizeMode]::NoResize

	#handler for pressing ok 
	$ButOk.Add_Click({CmbOkClicked $this $_})

	#set current values to combobox
	$CmbGameSelection.SelectedIndex = $global:GameSelected
	$CmbGameLaunching.SelectedIndex = $global:GameLaunching
	$CmbGameInstalled.SelectedIndex = $global:GameInstalled
	$CmbGameUninstalled.SelectedIndex = $global:GameUninstalled

	#show the dialog
	$global:Window.ShowDialog()

	#get the variables from the controls
	$global:GameSelected = $CmbGameSelection.SelectedIndex 
	$global:GameLaunching = $CmbGameLaunching.SelectedIndex
	$global:GameInstalled = $CmbGameInstalled.SelectedIndex
	$global:GameUninstalled = $CmbGameUninstalled.SelectedIndex

	#immediatly save settings just in case playnite might ever crash
	SaveSettings
}

function CmbOkClicked() {
	param (
		$Sender,
		$RoutedEventArgs
	)

	#close it when pressing ok
	$global:Window.DialogResult = $True;
}

#there seems to be a bug upon application launch where
#gameselected can happen before applicationstarted
#so we can not load the settings in applicationstarted
#as that could be too late if gameselected happens first
function global:CheckFirstRun() {
	if ($global:FirstSpeak)
	{
		LoadSettings
		$global:FirstSpeak = $False
	}
}

function global:DoSpeak() {
	param(
		$Text,
		$SpeakOption
	)

	$DesktopMode = ($PlayniteApi.ApplicationInfo.Mode -eq "Desktop")
	$DoPlay = (($DesktopMode -and (($SpeakOption -eq 1) -or ($SpeakOption -eq 3))) -or
		(($DesktopMode -eq $False) -and (($SpeakOption -eq 2) -or ($SpeakOption -eq 3))))
	if ($DoPlay)
	{
		$global:Speak.SpeakAsyncCancelAll()
		$global:Speak.SpeakAsync($Text)
	}
}

function global:GetMainMenuItems() {
	param($menuArgs)

	$menuItem1 = New-Object Playnite.SDK.Plugins.ScriptMainMenuItem
	$menuItem1.Description = "Game Speak Settings"
	$menuItem1.FunctionName = "SettingsMenu"
	$menuItem1.MenuSection = "@Game Speak"

	return $menuItem1
}

function global:LoadSettings()
{
	#just in case user deleted it
	New-Item -ItemType Directory -Path $CurrentExtensionDataPath -Force
	$SettingsFile = Join-Path -Path $CurrentExtensionDataPath -ChildPath "Settings.dat"
	if (Test-Path $SettingsFile)
	{
		$Content = Get-Content -Path $SettingsFile
		if ($Content.Count -eq 4)
		{
			$global:GameSelected = [int]$Content[0]
			$global:GameInstalled = [int]$Content[1]
			$global:GameUninstalled = [int]$Content[2]
			$global:GameLaunching = [int]$Content[3]
		}
	}
}

function global:SaveSettings()
{
	#just in case user deleted it
	New-Item -ItemType Directory -Path $CurrentExtensionDataPath -Force
	$SettingsFile = Join-Path -Path $CurrentExtensionDataPath -ChildPath "Settings.dat"
	Set-Content -Path $SettingsFile -Value ([string]$global:GameSelected + "`r`n" +
		[string]$global:GameInstalled + "`r`n" +
		[string]$global:GameUninstalled + "`r`n" +
		[string]$global:GameLaunching)
}

function global:SettingsMenu()
{
	ShowSettingsWindow
}

function global:OnApplicationStarted()
{
}

function global:OnApplicationStopped()
{
	$global:Speak.SpeakAsyncCancelAll()
}

function global:OnLibraryUpdated()
{
}

function global:OnGameStarting()
{
	param(
		$game
	)

	CheckFirstRun
	DoSpeak ("Launching " + $game.Name) $global:GameLaunching
}

function global:OnGameStarted()
{
	param(
		$game
	)
}

function global:OnGameStopped()
{
	param(
		$game,
		$elapsedSeconds
	)
}

function global:OnGameInstalled()
{
	param(
		$game
	)

	CheckFirstRun
	DoSpeak ("Installed " + $game.Name) $global:GameInstalled
}

function global:OnGameUninstalled()
{
	param(
		$game
	)

	CheckFirstRun
	DoSpeak ("Uninstalled " + $game.Name) $global:GameUninstalled
}

function global:OnGameSelected()
{
	param(
		$arguments
	)

	CheckFirstRun
	if ($arguments.NewValue.Count -eq 1) {
		$arguments.NewValue | ForEach-Object {
			DoSpeak $_.Name $global:GameSelected
		}
	}
}
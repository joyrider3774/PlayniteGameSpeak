Add-Type -AssemblyName System.speech
$global:Speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$global:FirstSpeak = $True

# -------------------- settings form -------------------------
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$FrmSettings                     = New-Object system.Windows.Forms.Form
$FrmSettings.ClientSize          = New-Object System.Drawing.Point(390,198)
$FrmSettings.text                = "Playnite Game Speak Settings"
$FrmSettings.TopMost             = $false
$FrmSettings.StartPosition       = [System.Windows.Forms.FormStartPosition]::CenterParent;
$FrmSettings.FormBorderStyle     = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$FrmSettings.MinimizeBox         = $false
$FrmSettings.MaximizeBox         = $false

$Groupbox1                       = New-Object system.Windows.Forms.Groupbox
$Groupbox1.height                = 132
$Groupbox1.width                 = 366
$Groupbox1.text                  = "Speak what / where"
$Groupbox1.location              = New-Object System.Drawing.Point(9,13)

$lblGameName                     = New-Object system.Windows.Forms.Label
$lblGameName.text                = "Game selection:"
$lblGameName.AutoSize            = $true
$lblGameName.width               = 25
$lblGameName.height              = 10
$lblGameName.location            = New-Object System.Drawing.Point(20,25)
#$lblGameName.Font                = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblGameLaunching                = New-Object system.Windows.Forms.Label
$LblGameLaunching.text           = "Game launching:"
$LblGameLaunching.AutoSize       = $true
$LblGameLaunching.width          = 25
$LblGameLaunching.height         = 10
$LblGameLaunching.location       = New-Object System.Drawing.Point(20,50)
#$LblGameLaunching.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblGameInstalled                = New-Object system.Windows.Forms.Label
$LblGameInstalled.text           = "Game installed:"
$LblGameInstalled.AutoSize       = $true
$LblGameInstalled.width          = 25
$LblGameInstalled.height         = 10
$LblGameInstalled.location       = New-Object System.Drawing.Point(20,75)
#$LblGameInstalled.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$LblGameUinstalled               = New-Object system.Windows.Forms.Label
$LblGameUinstalled.text          = "Game uninstalled:"
$LblGameUinstalled.AutoSize      = $true
$LblGameUinstalled.width         = 25
$LblGameUinstalled.height        = 10
$LblGameUinstalled.location      = New-Object System.Drawing.Point(20,100)
#$LblGameUinstalled.Font          = New-Object System.Drawing.Font('Microsoft Sans Serif',10)

$CmbGameSelection                = New-Object system.Windows.Forms.ComboBox
$CmbGameSelection.width          = 190
$CmbGameSelection.height         = 20
@('Never','Desktop','Fullscreen','Desktop + Fullscreen') | ForEach-Object {[void] $CmbGameSelection.Items.Add($_)}
$CmbGameSelection.location       = New-Object System.Drawing.Point(160,20)
#$CmbGameSelection.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$CmbGameSelection.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$CmbGameLaunching                = New-Object system.Windows.Forms.ComboBox
$CmbGameLaunching.width          = 190
$CmbGameLaunching.height         = 20
@('Never','Desktop','Fullscreen','Desktop + Fullscreen') | ForEach-Object {[void] $CmbGameLaunching.Items.Add($_)}
$CmbGameLaunching.location       = New-Object System.Drawing.Point(160,45)
#$CmbGameLaunching.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$CmbGameLaunching.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$CmbGameInstalled                = New-Object system.Windows.Forms.ComboBox
$CmbGameInstalled.width          = 190
$CmbGameInstalled.height         = 20
@('Never','Desktop','Fullscreen','Desktop + Fullscreen') | ForEach-Object {[void] $CmbGameInstalled.Items.Add($_)}
$CmbGameInstalled.location       = New-Object System.Drawing.Point(160,70)
#$CmbGameInstalled.Font           = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$CmbGameInstalled.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$CmbGameUninstalled              = New-Object system.Windows.Forms.ComboBox
$CmbGameUninstalled.width        = 190
$CmbGameUninstalled.height       = 20
@('Never','Desktop','Fullscreen','Desktop + Fullscreen') | ForEach-Object {[void] $CmbGameUninstalled.Items.Add($_)}
$CmbGameUninstalled.location     = New-Object System.Drawing.Point(160,95)
#$CmbGameUninstalled.Font         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$CmbGameUninstalled.DropDownStyle  = [System.Windows.Forms.ComboBoxStyle]::DropDownList

$ButSave                         = New-Object system.Windows.Forms.Button
$ButSave.text                    = "Ok"
$ButSave.width                   = 80
$ButSave.height                  = 30
$ButSave.location                = New-Object System.Drawing.Point(155,157)
#$ButSave.Font                    = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$ButSave.DialogResult            = [System.Windows.Forms.DialogResult]::Ok

$FrmSettings.controls.AddRange(@($Groupbox1,$ButSave))
$Groupbox1.controls.AddRange(@($lblGameName,$LblGameLaunching,$LblGameInstalled,$LblGameUinstalled,$CmbGameSelection,$CmbGameLaunching,$CmbGameInstalled,$CmbGameUninstalled))

# -------------------- end settings form -------------------------

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
			$CmbGameSelection.SelectedIndex = [int]$Content[0]
			$CmbGameInstalled.SelectedIndex = [int]$Content[1]
			$CmbGameUninstalled.SelectedIndex = [int]$Content[2]
			$CmbGameLaunching.SelectedIndex = [int]$Content[3]
		}
	}
}

function global:SaveSettings()
{
	#just in case user deleted it
	New-Item -ItemType Directory -Path $CurrentExtensionDataPath -Force
	$SettingsFile = Join-Path -Path $CurrentExtensionDataPath -ChildPath "Settings.dat"
	Set-Content -Path $SettingsFile -Value ([string]$CmbGameSelection.SelectedIndex + "`r`n" +
		[string]$CmbGameInstalled.SelectedIndex + "`r`n" +
		[string]$CmbGameUninstalled.SelectedIndex + "`r`n" +
		[string]$CmbGameLaunching.SelectedIndex)
}

function global:SettingsMenu()
{
	$FrmSettings.ShowDialog()
	SaveSettings
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
	DoSpeak ("Launching " + $game.Name) $CmbGameLaunching.SelectedIndex
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
	DoSpeak ("Installed " + $game.Name) $CmbGameInstalled.SelectedIndex
}

function global:OnGameUninstalled()
{
	param(
		$game
	)

	CheckFirstRun
	DoSpeak ("Uninstalled " + $game.Name) $CmbGameUninstalled.SelectedIndex
}

function global:OnGameSelected()
{
	param(
		$arguments
	)

	CheckFirstRun
	if ($arguments.NewValue.Count -eq 1) {
		$arguments.NewValue | ForEach-Object {
			DoSpeak $_.Name $CmbGameSelection.SelectedIndex
		}
	}
}
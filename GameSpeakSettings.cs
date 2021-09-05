using Playnite.SDK;
using Playnite.SDK.Data;
using System;
using System.Collections.Generic;

namespace GameSpeak
{
    public class GameSpeakSettings
    {
        public int SpeakGameSelected { get; set; } = 3;
        public int SpeakGameLaunching { get; set; } = 3;
        public int SpeakGameInstalled { get; set; } = 3;
        public int SpeakGameUnInstalled { get; set; } = 3;
        public int SpeakApplicationStopped { get; set; } = 3;
        public int SpeakApplicationStarted { get; set; } = 3;
        public int SpeakLibraryUpdated { get; set; } = 3;

        public string SpeakGameSelectedText { get; set; } = "[game]";
        public string SpeakGameLaunchingText { get; set; } = "Launching [game]";
        public string SpeakGameInstalledText { get; set; } = "Installed [game]";
        public string SpeakGameUnInstalledText { get; set; } = "Uninstalled [game]";
        public string SpeakApplicationStoppedText { get; set; } = "Goodbye";
        public string SpeakApplicationStartedText { get; set; } = "Welcome to Playnite";
        public string SpeakLibraryUpdatedText { get; set; } = "Library updated";
    }

    public class GameSpeakSettingsViewModel : ObservableObject, ISettings
    {
        private static readonly ILogger logger = LogManager.GetLogger();
        private readonly GameSpeak plugin;
        private GameSpeakSettings editingClone { get; set; }

        private GameSpeakSettings settings;
        public GameSpeakSettings Settings
        {
            get => settings;
            set
            {
                settings = value;
                OnPropertyChanged();
            }
        }

        public GameSpeakSettingsViewModel(GameSpeak plugin)
        {
            try
            {                
                // Injecting your plugin instance is required for Save/Load method because Playnite saves data to a location based on what plugin requested the operation.
                this.plugin = plugin;

                // Load saved settings.
                var savedSettings = plugin.LoadPluginSettings<GameSpeakSettings>();

                // LoadPluginSettings returns null if not saved data is available.
                if (savedSettings != null)
                {
                    Settings = savedSettings;
                }
                else
                {
                    Settings = new GameSpeakSettings();
                }
            }
            catch (Exception E)
            {
                logger.Error(E, "GameSpeakSettings()");
                plugin.PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public void BeginEdit()
        {
            // Code executed when settings view is opened and user starts editing values.
            try
            {
                editingClone = Serialization.GetClone(Settings);
            }
            catch (Exception E)
            {
                logger.Error(E, "BeginEdit()");
                plugin.PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public void CancelEdit()
        {
            // Code executed when user decides to cancel any changes made since BeginEdit was called.
            // This method should revert any changes made to Option1 and Option2.
            Settings = editingClone;
        }

        public void EndEdit()
        {
            // Code executed when user decides to confirm changes made since BeginEdit was called.
            try
            {
                plugin.SavePluginSettings(Settings);
            }
            catch (Exception E)
            {
                logger.Error(E, "EndEdit()");
                plugin.PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public bool VerifySettings(out List<string> errors)
        {
            // Code execute when user decides to confirm changes made since BeginEdit was called.
            // Executed before EndEdit is called and EndEdit is not called if false is returned.
            // List of errors is presented to user if verification fails.
            errors = new List<string>();
            return true;
        }
    }
}
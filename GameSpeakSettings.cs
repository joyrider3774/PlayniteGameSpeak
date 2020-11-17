using Newtonsoft.Json;
using Playnite.SDK;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GameSpeak
{
    public class GameSpeakSettings : ISettings
    {
        private readonly GameSpeak plugin;
        private GameSpeakSettings EditDataSettings;

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


        // Parameterless constructor must exist if you want to use LoadPluginSettings method.
        public GameSpeakSettings()
        {
        }

        public GameSpeakSettings(GameSpeak plugin)
        {
            // Injecting your plugin instance is required for Save/Load method because Playnite saves data to a location based on what plugin requested the operation.
            this.plugin = plugin;

            // Load saved settings.
            var savedSettings = plugin.LoadPluginSettings<GameSpeakSettings>();

            // LoadPluginSettings returns null if not saved data is available.
            if (savedSettings != null)
            {
                RestoreSettings(savedSettings);
            }
        }

        public void BeginEdit()
        {
            // Code executed when settings view is opened and user starts editing values.
            EditDataSettings = new GameSpeakSettings(plugin);
        }

        public void CancelEdit()
        {
            // Code executed when user decides to cancel any changes made since BeginEdit was called.
            // This method should revert any changes made to Option1 and Option2.
            RestoreSettings(EditDataSettings);
        }

        public void EndEdit()
        {
            // Code executed when user decides to confirm changes made since BeginEdit was called.
            // This method should save settings made to Option1 and Option2.
            plugin.SavePluginSettings(this);
        }

        public bool VerifySettings(out List<string> errors)
        {
            // Code execute when user decides to confirm changes made since BeginEdit was called.
            // Executed before EndEdit is called and EndEdit is not called if false is returned.
            // List of errors is presented to user if verification fails.
            errors = new List<string>();
            return true;
        }


        private void RestoreSettings(GameSpeakSettings source)
        {
            SpeakGameInstalled = source.SpeakGameInstalled;
            SpeakGameLaunching = source.SpeakGameLaunching;
            SpeakGameSelected = source.SpeakGameSelected;
            SpeakGameUnInstalled = source.SpeakGameUnInstalled;
            SpeakApplicationStopped = source.SpeakApplicationStopped;
            SpeakApplicationStarted = source.SpeakApplicationStarted;
            SpeakLibraryUpdated = source.SpeakLibraryUpdated;


            SpeakGameSelectedText = source.SpeakGameSelectedText;
            SpeakGameLaunchingText = source.SpeakGameLaunchingText;
            SpeakGameInstalledText = source.SpeakGameInstalledText;
            SpeakGameUnInstalledText = source.SpeakGameUnInstalledText;
            SpeakApplicationStoppedText = source.SpeakApplicationStoppedText;
            SpeakApplicationStartedText = source.SpeakApplicationStartedText;
            SpeakLibraryUpdatedText = source.SpeakLibraryUpdatedText;
    }
    }
}
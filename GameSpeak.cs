using Playnite.SDK;
using Playnite.SDK.Models;
using Playnite.SDK.Plugins;
using System;
using System.Windows.Controls;
using Playnite.SDK.Events;
using System.IO;
using System.Reflection;

namespace GameSpeak
{
    public class GameSpeak : GenericPlugin
    {
        private static readonly ILogger logger = LogManager.GetLogger();

        private readonly System.Speech.Synthesis.SpeechSynthesizer Speak;

        private GameSpeakSettingsViewModel Settings { get; set; }

        public override Guid Id { get; } = Guid.Parse("9287cd5b-1397-4f57-9c76-9729ebca9b80");
        
        public static string pluginFolder;

        public GameSpeak(IPlayniteAPI api) : base(api)
        {
            try
            {
                Settings = new GameSpeakSettingsViewModel(this);
                Properties = new GenericPluginProperties
                {
                    HasSettings = true
                };

                Speak = new System.Speech.Synthesis.SpeechSynthesizer();

                pluginFolder = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);

                Localization.SetPluginLanguage(pluginFolder, api.ApplicationSettings.Language);
            }
            catch (Exception E)
            {
                logger.Error(E, "GameSpeak()");
                PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public void DoSpeak(string aValue, int aSpeakOption, bool aAsync)
        {
            try
            {
                bool DesktopMode = PlayniteApi.ApplicationInfo.Mode == ApplicationMode.Desktop;
                bool DoPlay = ((DesktopMode && ((aSpeakOption == 1) || (aSpeakOption == 3))) ||
                    (!DesktopMode && ((aSpeakOption == 2) || (aSpeakOption == 3))));
                if (DoPlay && (aValue.Length > 0))
                {
                    Speak.SpeakAsyncCancelAll();
                    if (aAsync)
                    {
                        Speak.SpeakAsync(aValue);
                    }
                    else
                    {
                        Speak.Speak(aValue);
                    }
                }
            }
            catch (Exception E)
            {
                logger.Error(E, "DoSpeak");
                PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public override void OnGameInstalled(OnGameInstalledEventArgs args)
        {
            // Add code to be executed when game is finished installing.
            DoSpeak(Settings.Settings.SpeakGameInstalledText.Replace("[game]", args.Game.Name), Settings.Settings.SpeakGameInstalled, true);
        }

        public override void OnGameSelected(OnGameSelectedEventArgs args)
        {
            if (args.NewValue.Count == 1) {
                DoSpeak(Settings.Settings.SpeakGameSelectedText.Replace("[game]", args.NewValue[0].Name), Settings.Settings.SpeakGameSelected, true);  
            }
        }

        public override void OnGameStarted(OnGameStartedEventArgs args)
        {
            // Add code to be executed when game is started running.
            //needs to be sync or it won't speak out full text
        }

        public override void OnGameStarting(OnGameStartingEventArgs args)
        {
            // Add code to be executed when game is preparing to be started.
            DoSpeak(Settings.Settings.SpeakGameLaunchingText.Replace("[game]", args.Game.Name), Settings.Settings.SpeakGameLaunching, true);
        }

        public override void OnGameStopped(OnGameStoppedEventArgs args)
        {
            // Add code to be executed when game is preparing to be started.
        }

        public override void OnGameUninstalled(OnGameUninstalledEventArgs args)
        {
            // Add code to be executed when game is uninstalled.
            DoSpeak(Settings.Settings.SpeakGameUnInstalledText.Replace("[game]", args.Game.Name), Settings.Settings.SpeakGameUnInstalled, true);
        }

        public override void OnApplicationStarted(OnApplicationStartedEventArgs args)
        {
            // Add code to be executed when Playnite is initialized.
            DoSpeak(Settings.Settings.SpeakApplicationStartedText, Settings.Settings.SpeakApplicationStarted, true);
        }

        public override void OnApplicationStopped(OnApplicationStoppedEventArgs args)
        {
            // Add code to be executed when Playnite is shutting down.
            //needs to be sync or won't speak out full text before quiting            
            DoSpeak(Settings.Settings.SpeakApplicationStoppedText, Settings.Settings.SpeakApplicationStopped, false);
            try
            {
                Speak.SpeakAsyncCancelAll();
                Speak.Dispose();
            }
            catch (Exception E)
            {
                logger.Error(E, "OnApplicationStopped");
                PlayniteApi.Dialogs.ShowErrorMessage(E.ToString(), Constants.AppName);
            }
        }

        public override void OnLibraryUpdated(OnLibraryUpdatedEventArgs args)
        {
            // Add code to be executed when library is updated.
            DoSpeak(Settings.Settings.SpeakLibraryUpdatedText, Settings.Settings.SpeakApplicationStopped, true);
        }

        public override ISettings GetSettings(bool firstRunSettings)
        {
            return Settings;
        }

        public override UserControl GetSettingsView(bool firstRunSettings)
        {
            return new GameSpeakSettingsView();
        }
    }
}
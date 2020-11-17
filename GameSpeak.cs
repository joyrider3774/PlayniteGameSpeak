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
    public class GameSpeak : Plugin
    {
        private static readonly ILogger logger = LogManager.GetLogger();

        private readonly System.Speech.Synthesis.SpeechSynthesizer Speak;
        
        public GameSpeakSettingsView SettingsView;

        private GameSpeakSettings Settings { get; set; }

        public override Guid Id { get; } = Guid.Parse("9287cd5b-1397-4f57-9c76-9729ebca9b80");
        
        public static string pluginFolder;
        
        public GameSpeak(IPlayniteAPI api) : base(api)
        {
            try
            {
                Settings = new GameSpeakSettings(this);

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

        public override void OnGameInstalled(Game game)
        {
            // Add code to be executed when game is finished installing.
            DoSpeak(Settings.SpeakGameInstalledText.Replace("[game]", game.Name), Settings.SpeakGameInstalled, true);
        }

        public override void OnGameSelected(GameSelectionEventArgs args)
        {
            if (args.NewValue.Count == 1) {
                DoSpeak(Settings.SpeakGameSelectedText.Replace("[game]", args.NewValue[0].Name), Settings.SpeakGameSelected, true);  
            }
        }

        public override void OnGameStarted(Game game)
        {
            // Add code to be executed when game is started running.
            //needs to be sync or it won't speak out full text
        }

        public override void OnGameStarting(Game game)
        {
            // Add code to be executed when game is preparing to be started.
            DoSpeak(Settings.SpeakGameLaunchingText.Replace("[game]", game.Name), Settings.SpeakGameLaunching, true);
        }

        public override void OnGameStopped(Game game, long elapsedSeconds)
        {
            // Add code to be executed when game is preparing to be started.
        }

        public override void OnGameUninstalled(Game game)
        {
            // Add code to be executed when game is uninstalled.
            DoSpeak(Settings.SpeakGameUnInstalledText.Replace("[game]", game.Name), Settings.SpeakGameUnInstalled, true);
        }

        public override void OnApplicationStarted()
        {
            // Add code to be executed when Playnite is initialized.
            DoSpeak(Settings.SpeakApplicationStartedText, Settings.SpeakApplicationStarted, true);
        }

        public override void OnApplicationStopped()
        {
            // Add code to be executed when Playnite is shutting down.
            //needs to be sync or won't speak out full text before quiting            
            DoSpeak(Settings.SpeakApplicationStoppedText, Settings.SpeakApplicationStopped, false);
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

        public override void OnLibraryUpdated()
        {
            // Add code to be executed when library is updated.
            DoSpeak(Settings.SpeakLibraryUpdatedText, Settings.SpeakApplicationStopped, true);
        }

        public override ISettings GetSettings(bool firstRunSettings)
        {
            return Settings;
        }

        public override UserControl GetSettingsView(bool firstRunSettings)
        {
            SettingsView = new GameSpeakSettingsView();
            return SettingsView;
        }
    }
}
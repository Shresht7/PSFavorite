using System;
using System.IO;
using System.Linq;
using System.Threading;
using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Subsystem;
using System.Management.Automation.Subsystem.Prediction;

namespace PSFavorite
{
    public class PSFavoritePredictor : ICommandPredictor
    {
        private readonly Guid _guid;

        internal PSFavoritePredictor(string guid)
        {
            _guid = new Guid(guid);
        }

        /// <summary>
        /// Gets the unique identifier for a subsystem implementation.
        /// </summary>
        public Guid Id => _guid;

        /// <summary>
        /// Gets the name of a subsystem implementation.
        /// </summary>
        public string Name => "Favorite";

        /// <summary>
        /// Gets the description of a subsystem implementation.
        /// </summary>
        public string Description => "A predictor that uses a list of favorite commands to provide suggestions.";

        /// A fixed GUID to identify the predictor. This should be unique to avoid conflicts with other predictors.
        internal const string Identifier = "843b51d0-55c8-4c1a-8116-f0728d419306";

        #region "Favorites"

        /// <summary>
        /// The file path of the favorite commands file.
        /// For Windows, the default path is "%LocalAppData%\PSFavorite\Favorites.txt" and for Linux/macOS, the default path is "$HOME/.local/share/PSFavorite/Favorites.txt".
        /// The file is expected to contain one favorite command per line, and an optional description after a '#' character.
        /// </summary>
        private static string _FavoritesFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "PSFavorite", "Favorites.txt");

        /// <summary>
        /// A cached list of favorite commands.
        /// Can be updated by calling LoadFavoritesIfExists, which is triggered during initialization.
        /// </summary>
        private static string[] _favorites = Array.Empty<string>();

        /// <summary>
        /// An object used for locking access to the favorites array to ensure thread safety.
        /// This is necessary because the predictor may be called from multiple threads concurrently, and we want to avoid race conditions
        /// when loading or accessing the favorites.
        /// </summary>
        private static readonly object _favoritesLock = new object();

        /// <summary>
        /// Initialize the predictor with an explicit favorites path.
        /// Safe to call from PowerShell after the module's configuration is resolved.
        /// </summary>
        /// <param name="favoritesPath">Full path to the favorites file.</param>
        public static void Initialize(string favoritesPath)
        {
            if (!string.IsNullOrWhiteSpace(favoritesPath))
            {
                _FavoritesFilePath = favoritesPath;
            }

            LoadFavoritesIfExists();
        }

        /// <summary>
        /// Load the favorites from the file if it exists. If any error occurs, set favorites to an empty array.
        /// </summary>
        private static void LoadFavoritesIfExists()
        {
            try
            {
                // Check if the favorites file exists. If it does, read all lines and update the _favorites array.
                if (File.Exists(_FavoritesFilePath))
                {
                    lock (_favoritesLock)
                    {
                        _favorites = File.ReadAllLines(_FavoritesFilePath);
                    }
                }
                // ...otherwise, if the file does not exist, set _favorites to an empty array.
                else
                {
                    lock (_favoritesLock)
                    {
                        _favorites = Array.Empty<string>();
                    }
                }
            }
            // If any exception occurs during file access (e.g., file is locked, permission issues, etc.),
            // catch the exception and set _favorites to an empty array to avoid crashing the predictor.
            catch
            {
                lock (_favoritesLock)
                {
                    _favorites = Array.Empty<string>();
                }
            }
        }

        #endregion

        #region "Suggestions"

        /// <summary>
        /// Get the predictive suggestions. It indicates the start of a suggestion rendering session.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="context">The <see cref="PredictionContext"/> object to be used for prediction.</param>
        /// <param name="cancellationToken">The cancellation token to cancel the prediction.</param>
        /// <returns>An instance of <see cref="SuggestionPackage"/>.</returns>
        public SuggestionPackage GetSuggestion(PredictionClient client, PredictionContext context, CancellationToken cancellationToken)
        {
            // Do not provide any suggestions if the input is empty.
            string input = context.InputAst.Extent.Text;
            if (string.IsNullOrWhiteSpace(input))
            {
                return default;
            }
            
            string[] favoritesSnapshot;
            lock (_favoritesLock)
            {
                favoritesSnapshot = _favorites;
            }

            if (favoritesSnapshot is null || favoritesSnapshot.Length == 0)
            {
                return default;
            }

            List<PredictiveSuggestion> suggestions = favoritesSnapshot
                .Select(line => (Line: line, Score: DetermineScore(input, line)))               // Determine the score for each line.
                .Where(tuple => tuple.Score >= ScoreThreshold)                                  // Filter out the lines below the score threshold.
                .OrderByDescending(tuple => tuple.Score)                                        // Order the list by the score in descending order.
                .Select(tuple => new PredictiveSuggestion(tuple.Line, GetTooltip(tuple.Line)))  // Create a PredictiveSuggestion object for selected line.
                .ToList();                                                                      // Convert to a list of PredictiveSuggestion objects.

            // Return the list of suggestions.
            return new SuggestionPackage(suggestions);
        }

        /// <summary>
        /// The suggestions with a score lower than this threshold will be filtered out.
        /// </summary>
        private const int ScoreThreshold = 50;

        /// <summary>
        /// Determine the score indicating how well the input matches the favorite's line
        /// </summary>
        /// <param name="input">The input string</param>
        /// <param name="line">The line from the favorite's file</param>
        /// <returns>The score indicating how well the input matches the favorite's line</returns>
        private static int DetermineScore(string input, string line)
        {
            int score = 0;

            // If the input matches the start of the line exactly, add 10000 score to make it the top suggestion.
            if (line.StartsWith(input, StringComparison.OrdinalIgnoreCase))
            {
                score += 10000;
            }

            // If the input appears in the line, in the exact same order, add 1000 score.
            if (line.Contains(input, StringComparison.OrdinalIgnoreCase))
            {
                score += 1000;
            }

            // If the input words appear in the line somewhere, add 25 points.
            string[] inputWords = input.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            foreach (string word in inputWords)
            {
                if (line.Contains(word, StringComparison.OrdinalIgnoreCase))
                {
                    score += 25;
                }
            }

            return score;
        }

        /// <summary>
        /// Get the tooltip for the suggestion.
        /// </summary>
        /// <param name="line">The line from the favorite's file</param>
        /// <returns>The tooltip for the suggestion</returns>
        /// <remarks>
        /// The tooltip is the part of the line after the first '#' character.
        /// </remarks>
        /// <example>
        /// If the line is "Get-Process # Get the list of processes", the tooltip is "Get the list of processes".
        /// </example>
        private static string GetTooltip(string line)
        {
            string[] s = line.Split('#');
            if (s.Length > 1)
            {
                return s[1].Trim();
            }
            else
            {
                return string.Empty;
            }
        }

        #endregion

        #region "interface methods for processing feedback"

        /// <summary>
        /// Gets a value indicating whether the predictor accepts a specific kind of feedback.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="feedback">A specific type of feedback.</param>
        /// <returns>True or false, to indicate whether the specific feedback is accepted.</returns>
        public bool CanAcceptFeedback(PredictionClient client, PredictorFeedbackKind feedback) => false;

        /// <summary>
        /// One or more suggestions provided by the predictor were displayed to the user.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="session">The mini-session where the displayed suggestions came from.</param>
        /// <param name="countOrIndex">
        /// When the value is greater than 0, it's the number of displayed suggestions from the list
        /// returned in <paramref name="session"/>, starting from the index 0. When the value is
        /// less than or equal to 0, it means a single suggestion from the list got displayed, and
        /// the index is the absolute value.
        /// </param>
        public void OnSuggestionDisplayed(PredictionClient client, uint session, int countOrIndex) { }

        /// <summary>
        /// The suggestion provided by the predictor was accepted.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="session">Represents the mini-session where the accepted suggestion came from.</param>
        /// <param name="acceptedSuggestion">The accepted suggestion text.</param>
        public void OnSuggestionAccepted(PredictionClient client, uint session, string acceptedSuggestion) { }

        /// <summary>
        /// A command line was accepted to execute.
        /// The predictor can start processing early as needed with the latest history.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="history">History command lines provided as references for prediction.</param>
        public void OnCommandLineAccepted(PredictionClient client, IReadOnlyList<string> history) { }

        /// <summary>
        /// A command line was done execution.
        /// </summary>
        /// <param name="client">Represents the client that initiates the call.</param>
        /// <param name="commandLine">The last accepted command line.</param>
        /// <param name="success">Shows whether the execution was successful.</param>
        public void OnCommandLineExecuted(PredictionClient client, string commandLine, bool success) { }

        #endregion

        /// <summary>
        /// Explicitly unregister the predictor from the PSReadLine subsystem.
        /// Safe to call multiple times; silently ignores if not currently registered.
        /// </summary>
        public static void Unregister()
        {
            try
            {
                SubsystemManager.UnregisterSubsystem(SubsystemKind.CommandPredictor, new Guid(Identifier));
            }
            catch (InvalidOperationException)
            {
                // Predictor was already unregistered or never registered; no-op.
            }
        }
    }

    /// <summary>
    /// Register the predictor on module loading and unregister it on module un-loading.
    /// </summary>
    public class Init : IModuleAssemblyInitializer, IModuleAssemblyCleanup
    {
        /// <summary>
        /// Gets called when assembly is loaded.
        /// </summary>
        public void OnImport()
        {
            var predictor = new PSFavoritePredictor(PSFavoritePredictor.Identifier);
            try
            {
                SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, predictor);
            }
            catch (InvalidOperationException ex) when (ex.Message.Contains("already registered"))
            {
                // The predictor may already be registered (e.g., repeated module import in the same process).
                // Treat duplicate registration as a no-op to make initialization idempotent.
            }
        }

        /// <summary>
        /// Gets called when the binary module is unloaded.
        /// </summary>
        public void OnRemove(PSModuleInfo psModuleInfo)
        {
            PSFavoritePredictor.Unregister();
        }
    }
}

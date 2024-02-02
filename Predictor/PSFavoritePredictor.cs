﻿using System.Management.Automation;
using System.Management.Automation.Subsystem;
using System.Management.Automation.Subsystem.Prediction;

namespace PowerShell.Sample
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

        /// <summary>
        /// The file path of the favorite commands file.
        /// </summary>
        private static readonly string _FavoritesFilePath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "PSFavorite", "Favorites.txt");

        /// <summary>
        /// A list of favorite commands.
        /// </summary>
        private readonly string[] favorites = File.ReadAllLines(_FavoritesFilePath);

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

            // Generate the list of predictive suggestions.
            List<PredictiveSuggestion> suggestions = favorites
                .Select(line => new Tuple<string, int>(line, DetermineScore(input, line))) // Determine the score for each line.
                .Where(tuple => tuple.Item2 >= ScoreThreshold) // Filter out the lines below the score threshold.
                .OrderByDescending(tuple => tuple.Item2) // Order the list by the score in descending order.
                .Select(tuple => new PredictiveSuggestion(tuple.Item1, tuple.Item2.ToString())) // Create a PredictiveSuggestion object for selected line.
                .ToList(); // Convert to a list of PredictiveSuggestion objects.

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
        private int DetermineScore(string input, string line)
        {
            int score = 0;

            // If the input is an exact match, give it a score of 10000 to make it the top suggestion.
            if (line == input)
            {
                score += 10000;
            }

            // If the input is contained in the line verbatim, give it a score of 1000
            if (line.Contains(input, StringComparison.OrdinalIgnoreCase))
            {
                score += 1000;
            }

            // If the input words are somewhere in the line, give it a score of 25 for each word.
            string[] inputs = input.Split(' ');
            string[] lines = line.Split(' ');
            foreach (string word in inputs)
            {
                if (lines.Contains(word))
                {
                    score += 25;
                }
            }

            // If the input characters are somewhere in the line, give it a score of 1 for each character.
            char[] chars = line.ToCharArray();
            foreach (char c in input.ToCharArray())
            {
                if (chars.Contains(c))
                {
                    score += 1;
                }
            }


            return score;
        }

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

        #endregion;
    }

    /// <summary>
    /// Register the predictor on module loading and unregister it on module un-loading.
    /// </summary>
    public class Init : IModuleAssemblyInitializer, IModuleAssemblyCleanup
    {
        private const string Identifier = "843b51d0-55c8-4c1a-8116-f0728d419306";

        /// <summary>
        /// Gets called when assembly is loaded.
        /// </summary>
        public void OnImport()
        {
            var predictor = new PSFavoritePredictor(Identifier);
            SubsystemManager.RegisterSubsystem(SubsystemKind.CommandPredictor, predictor);
        }

        /// <summary>
        /// Gets called when the binary module is unloaded.
        /// </summary>
        public void OnRemove(PSModuleInfo psModuleInfo)
        {
            SubsystemManager.UnregisterSubsystem(SubsystemKind.CommandPredictor, new Guid(Identifier));
        }
    }
}

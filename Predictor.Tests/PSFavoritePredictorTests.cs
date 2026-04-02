using System.Reflection;
using Xunit;

using Predictor = PSFavorite.PSFavoritePredictor;

namespace PSFavoritePredictor.Tests;

public class PSFavoritePredictorTests
{
    #region Metadata

    [Fact]
    public void Metadata_UsesConfiguredGuidAndStaticValues()
    {
        Guid expectedId = Guid.NewGuid();

        ConstructorInfo? ctor = typeof(Predictor).GetConstructor(
            BindingFlags.Instance | BindingFlags.NonPublic,
            binder: null,
            types: [typeof(string)],
            modifiers: null);

        Assert.NotNull(ctor);

        var predictor = (Predictor)ctor!.Invoke([expectedId.ToString()]);

        Assert.Equal(expectedId, predictor.Id);
        Assert.Equal("Favorite", predictor.Name);
        Assert.Equal("A predictor that uses a list of favorite commands to provide suggestions.", predictor.Description);
    }

    #endregion

    #region Initialize and Reload

    [Fact]
    public void Initialize_LoadsFavoritesFromFile()
    {
        string temp = Path.GetTempFileName();

        try
        {
            string[] lines = ["Get-ChildItem # List files", "Get-Date # Show date"];
            File.WriteAllLines(temp, lines);

            Predictor.Initialize(temp);

            var field = typeof(Predictor).GetField("_favorites", BindingFlags.Static | BindingFlags.NonPublic);
            Assert.NotNull(field);
            var favorites = (Predictor.FavoriteEntry[]?)field!.GetValue(null);

            Assert.NotNull(favorites);
            Assert.Equal(lines, favorites!.Select(f => f.Line));
        }
        finally
        {
            if (File.Exists(temp)) File.Delete(temp);
        }
    }

    [Fact]
    public void Reload_UpdatesFavoritesAfterFileChange()
    {
        string temp = Path.GetTempFileName();
        try
        {
            string[] initial = ["CmdA # a"];
            File.WriteAllLines(temp, initial);
            Predictor.Initialize(temp);

            // overwrite with new content
            string[] updated = ["CmdB # b", "CmdC # c"];
            File.WriteAllLines(temp, updated);

            Predictor.Reload();

            var field = typeof(Predictor).GetField("_favorites", BindingFlags.Static | BindingFlags.NonPublic);
            Assert.NotNull(field);
            var favorites = (Predictor.FavoriteEntry[]?)field!.GetValue(null);

            Assert.NotNull(favorites);
            Assert.Equal(updated, favorites!.Select(f => f.Line));
        }
        finally
        {
            if (File.Exists(temp)) File.Delete(temp);
        }
    }

    #endregion

    #region ParseFavoriteLine

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void ParseFavoriteLine_ReturnsEmpty_ForBlankInput(string? line)
    {
        var (command, tooltip) = Predictor.ParseFavoriteLine(line!);

        Assert.Equal(string.Empty, command);
        Assert.Equal(string.Empty, tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_CommentOnlyLine_ReturnsEmptyCommandAndTooltip()
    {
        string line = "# only comment";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal(string.Empty, command);
        Assert.Equal("only comment", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_ReturnsTrimmedLine_WhenNoCommentExists()
    {
        string line = "  Get-Date  ";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Get-Date", command);
        Assert.Equal(string.Empty, tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_ReturnsCommandAndTooltip()
    {
        string line = "Get-ChildItem # List files";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Get-ChildItem", command);
        Assert.Equal("List files", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_PreservesHashInsideStringLiteral()
    {
        string line = "Write-Host \"#tag\" # Display tag";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Write-Host \"#tag\"", command);
        Assert.Equal("Display tag", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_HandlesQuotedHashVariants()
    {
        string line = "Write-Output \"a#b\"; Write-Output \"c\" # trailing";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Write-Output \"a#b\"; Write-Output \"c\"", command);
        Assert.Equal("trailing", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_MultipleHashes_TrimsHashes()
    {
        string line = "Cmd ## multiple hashes";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Cmd", command);
        Assert.Equal("multiple hashes", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_TrimsWhitespaceAroundCommand()
    {
        string line = "   Cmd   #  tip  ";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Cmd", command);
        Assert.Equal("tip", tooltip);
    }

    [Fact]
    public void ParseFavoriteLine_TrimsWhitespaceAroundComment()
    {
        string line = "Cmd    #   spaced   ";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Cmd", command);
        Assert.Equal("spaced", tooltip);
    }

    #endregion
}

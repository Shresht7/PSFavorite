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
            var favorites = (string[]?)field!.GetValue(null);

            Assert.NotNull(favorites);
            Assert.Equal(lines, favorites!);
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
            var favorites = (string[]?)field!.GetValue(null);

            Assert.NotNull(favorites);
            Assert.Equal(updated, favorites!);
        }
        finally
        {
            if (File.Exists(temp)) File.Delete(temp);
        }
    }

    #endregion

    #region ParseFavoriteLine

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
    public void ParseFavoriteLine_ReturnsTrimmedLine_WhenNoCommentExists()
    {
        string line = "  Get-Date  ";

        (string command, string tooltip) = Predictor.ParseFavoriteLine(line);

        Assert.Equal("Get-Date", command);
        Assert.Equal(string.Empty, tooltip);
    }

    #endregion

    #region Tooltips

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("   ")]
    public void GetTooltip_ReturnsEmpty_ForBlankInput(string? line)
    {
        string tooltip = Predictor.GetTooltip(line!);

        Assert.Equal(string.Empty, tooltip);
    }

    [Fact]
    public void GetTooltip_ExtractsTrailingComment()
    {
        string line = "Get-Process # List running processes";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal("List running processes", tooltip);
    }

    [Fact]
    public void GetTooltip_IgnoresHashInsideStringLiteral()
    {
        string line = "Write-Host \"#tag\" # Display tag";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal("Display tag", tooltip);
    }

    [Fact]
    public void GetTooltip_ReturnsEmpty_WhenNoCommentExists()
    {
        string line = "Get-Date";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal(string.Empty, tooltip);
    }

    [Fact]
    public void GetTooltip_TrimsMultipleHashes()
    {
        string line = "Cmd ## multiple hashes";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal("multiple hashes", tooltip);
    }

    [Fact]
    public void GetTooltip_HandlesCommentOnlyLine()
    {
        string line = "# only comment";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal("only comment", tooltip);
    }

    [Fact]
    public void GetTooltip_TrimsWhitespaceAroundComment()
    {
        string line = "Cmd    #   spaced   ";

        string tooltip = Predictor.GetTooltip(line);

        Assert.Equal("spaced", tooltip);
    }

    #endregion
}

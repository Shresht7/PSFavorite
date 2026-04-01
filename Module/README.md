# `PSFavorite`

This module allows you to mark commands as **favorites**. Your favorite commands will appear as suggestions in the PSReadLine Predictor Views.

Favorites do not replace history, they complement it. The history tracks _everything_ you've done, and favorites track the things that you've _deemed important_.

![demo](./demo.gif)

---

## 📘 Usage


Write a command and press <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>*</kbd> to mark it as _favorite_.

![screenshot](./add-to-favorites.png)

> `Note:` Add a helpful comment to describe the command for future reference.

**Alternatively**, use the `Add-PSFavorite` cmdlet

```powershell
PS C:\> "Get-Command | Get-Random | Get-Help    # Get help about a random command" | Add-PSFavorite
```

> `Note:` Remember to wrap the expressions in quotes!

Your _favorite commands_ will start appearing as suggestions in the **PSReadLine Predictor View**.

### 🌟 Favorites File

The favorites file is where your favorite commands are stored. By default, it is located at:

- Windows: `$Env:LOCALAPPDATA\PSFavorite\Favorites.txt`
- Linux/macOS: `$HOME/.local/share/PSFavorite/Favorites.txt`

You can get the current path to the favorites file using the `Get-PSFavoritePath` cmdlet:

```powershell
Get-PSFavoritePath
```

Favorites are stored in a simple text format, one command per line along with an optional comment description.

```pwsh
Get-ChildItem -Filter *.md    # List all Markdown files in the current directory
Get-Process | Where-Object CPU -gt 25 # Get processes consuming more than 25 CPU units
git reset --hard HEAD~1    # Undo the last Git commit, discarding changes
```

### 📜 Cmdlets

- [`Add-PSFavorite`](./Module/Public/Add-PSFavorite.ps1) - Add a command to your favorites list.
- [`Get-PSFavorite`](./Module/Public/Get-PSFavorite.ps1) - Get the list of your favorite commands.
- [`Remove-PSFavorite`](./Module/Public/Remove-PSFavorite.ps1) - Remove a command from your favorites list.
- [`Get-PSFavoritePath`](./Module/Public/Get-PSFavoritePath.ps1) - Get the path to the favorites file.
- [`Optimize-PSFavorite`](./Module/Public/Optimize-PSFavorite.ps1) - Optimize the favorites file by removing duplicates and sorting entries.
- [`Initialize-PSFavorite`](./Module/Public/Initialize-PSFavorite.ps1) - Initialize the favorites file and directory.

---

## 📄 Requirements

- PowerShell v7.2.0 or higher
- PSReadLine v2.2.2 or higher

`PSReadLine` should be installed by default in PowerShell 7+, but if not, you can install it using:

```powershell
Install-Module -Name PSReadLine
```

PSReadLine must allow plugins as a `-PredictionSource`. (i.e. `Plugin` or `HistoryAndPlugin`)

```powershell
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
```

To enable the `List` view:

```powershell
Set-PSReadLineOption -PredictionViewStyle ListView
```

## 📦 Installation

### 1. Install the Module

```powershell
Install-Module -Name PSFavorite
```

### 2. Import the Module

```powershell
Import-Module -Name PSFavorite
```

### 3. Initialize the Favorites File

```powershell
Initialize-PSFavorite # Initialize PSFavorite with the default configuration
```

or alternatively, to configure the path and keybind:

```powershell
Initialize-PSFavorite -Path "C:\MyFavorites.txt" -KeyBind "Ctrl+Shift+F"
```

> [!NOTE]
> Add this to your `$PROFILE` if you wish to enable this for every session.

## 🪓 Uninstallation

1. Close **all** PowerShell instances
2. Launch a PowerShell session with no profile. `pwsh -NoProfile`
3. Uninstall the Module. `Uninstall-Module -Name PSFavorite -Force`
4. Close PowerShell

---

## 💽 Development

### 📜 Scripts

- [`Build.ps1`](./Build.ps1) - Builds the C# predictor and copies the DLL to the Module directory.

```pwsh
./Build.ps1 -Configuration Release
```
> [!WARNING]
> If the dll is locked by PowerShell, you may need to kill all PowerShell processes that have it loaded and run the build script again.
> This is always a pain during development, but I haven't found a good workaround for it yet.

### 🧪 Testing

This module uses [Pester](https://pester.dev/) for testing the [PowerShell Module](./Module/Tests/). To test the module, first build it and then run the following command.

```pwsh
./Build.ps1 # To build the module and predictor DLL
Invoke-Pester -Path ./Module/Tests -Verbose # Run all Pester tests in the Module/Tests directory
```

The C# predictor includes a small `xUnit` test project. To run the .NET tests (after restore) run:

```pwsh
dotnet test # Run all .NET tests in the solution
```

### 🚢 Publishing

#### Version

Ensure the `ModuleVersion` in [`Module/PSFavorite.psd1`](./Module/PSFavorite.psd1) and `<Version>` in [`Predictor/PSFavoritePredictor.csproj`](./Predictor/PSFavoritePredictor.csproj) is updated before creating a release.

Create a git tag for the release and push it to GitHub.

```pwsh
git tag -a v1.0.0 -m "Release version 1.0.0"
git push --tags
```

#### Publish to PowerShell Gallery

To publish the module to the PowerShell Gallery, you can use the `Publish-Module` cmdlet using an API key from your PowerShell Gallery account.

```pwsh
Publish-Module -Path ./Module -NuGetApiKey YOUR_API_KEY
```
> I did consider GitHub Actions for CI/CD, but since this is a personal project and I don't plan on frequent releases, ~~not to mention all the horror-stories~~, I decided to keep it simple with manual publishing for now.

## 📕 Reference

- https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-cmdline-predictor

---

## 📃 License

This project is licensed under the [MIT License](./LICENSE). Please read the [LICENSE](./LICENSE) for more details.

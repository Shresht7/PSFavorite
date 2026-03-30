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

---

## 📄 Requirements

- PowerShell v7.2.0 or higher
- PSReadLine v2.2.2 or higher

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

### 🧪 Testing

This module uses [Pester](https://pester.dev/) for testing. To test the module, first build it and then run the following command.

```pwsh
./Build.ps1
Import-Module ./Module/PSFavorite.psd1 -Force
Invoke-Pester -Path ./Module/Tests
```

### 🚢 Publishing

The module is automatically published to the PowerShell Gallery when a new **Release** is created on GitHub. 

Ensure the `ModuleVersion` in `Module/PSFavorite.psd1` is updated before creating a release.

## 📕 Reference

- https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-cmdline-predictor

---

## 📃 License

This project is licensed under the [MIT License](./LICENSE). Please read the [LICENSE](./LICENSE) for more details.

# `PSFavorite`

This module allows you to mark commands as **favorites**. Your favorite commands will appear as suggestions in the PSReadLine Predictor Views.

---

## 📘 Usage


Write a command and press <kbd>Ctrl</kbd> + <kbd>Shift</kbd> + <kbd>*</kbd> to mark it as _favorite_.

> `Note:` Add a helpful comment to describe the command for future reference.

**Alternatively**, use the `Add-Favorite` cmdlet

```powershell
PS C:\> "Get-Command | Get-Random | Get-Help    # Get help about a random command" | Add-Favorite
```

> `Note:` Remember to wrap the expressions in quotes!

Your _favorite commands_ will start appearing as suggestions in the **PSReadLine Predictor View**.

<!-- TODO: Add Screenshot or GIF -->

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

### 🏗️ Setup

1. Clone the repository

```powershell
git clone
# or
gh repo clone
```

2. ⚠️ TODO ⚠️

3. Import the module

```powershell
Import-Module -Name PSFavorite
```

### 📜 Scripts

- [`Build.ps1`](./Build.ps1) - Builds the PowerShell module

## 📕 Reference

- https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/create-cmdline-predictor?view=powershell-7.3

---

## 📃 License

[MIT](./LICENSE)

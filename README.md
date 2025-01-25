# ArchFlow.nvim

**ArchFlow.nvim** is a Neovim plugin designed to simplify and accelerate Flutter development by automating the creation of architecture-based feature structures. The plugin supports popular design patterns and state management libraries.
- [ArchFlow.nvim](https://github.com/migbyte-0/archflow-nvim) - A plugin that auto-generates Flutter folder structures and boilerplate for multiple architectures (MVC, MVVM, Clean Architecture, etc.).
---

## Features

- **Architecture Selection**: Supports `MVC`, `MVVM`, and `Clean Architecture`.
- **State Management Options**: Choose between `Provider`, `Riverpod`, `BLoC`, and `GetX`.
- **Feature Automation**: Automatically creates the folder structure and boilerplate files for a new feature.
- **Recent Features Navigation**: Quickly access recently created features with an integrated file navigator.

---

## Installation

Use your preferred plugin manager. For example, with **lazy.nvim**:

```lua
{
  "migbyte-0/archflow.nvim",
  config = function()
    require("archflow").setup()
  end,
}

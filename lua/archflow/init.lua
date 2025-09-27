--[[
-- init.lua
--
-- Main entry point for the ArchFlow Neovim plugin.
-- This file is responsible for two primary tasks:
-- 1. Providing the `setup()` function that users call to configure the plugin.
-- 2. Exposing the main `generate_feature()` command.
--]]

local config_module = require("archflow.config")
local ui = require("archflow.ui")

local M = {}

-- Store the merged configuration globally within the plugin's scope.
M.config = config_module.options

--- The main setup function for the plugin.
--- Users will call this from their Neovim config to customize the plugin.
---@param opts table|nil User-provided configuration options to override the defaults.
function M.setup(opts)
  -- Merge user-provided options over the default configuration.
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Set up the user command.
  vim.api.nvim_create_user_command("ArchFlow", function()
    M.generate_feature()
  end, {
    desc = "Generate a new Flutter feature using ArchFlow",
  })
end

--- The primary function that kicks off the feature generation UI.
--- This can be mapped to a keybinding for easy access.
function M.generate_feature()
  -- Pass the current configuration to the UI module to start the process.
  ui.start_generation(M.config)
end

return M

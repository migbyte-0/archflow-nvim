--[[
-- config.lua
--
-- This module holds the default configuration for the ArchFlow plugin.
-- Users can override these settings in their personal Neovim configuration
-- by calling the setup() function with their desired values.
--]]

local M = {}

--- Default configuration table.
M.options = {
  --- The base path relative to the project root where new features will be created.
  -- @type string
  feature_path = "lib/features",

  --- The base path relative to the project root for test files.
  -- @type string
  test_path = "test/features",

  --- Customizable folder names for different state management solutions.
  -- @type table<string, string>
  dir_names = {
    bloc = "bloc",
    cubit = "cubit",
    getx = "controller",
    provider = "provider",
    riverpod = "provider",
  },

  --- Path to a directory containing the user's custom templates.
  --- If set, the plugin will look for a template here first before
  --- falling back to its own default templates.
  -- @type string | nil
  custom_template_path = nil,
}

return M

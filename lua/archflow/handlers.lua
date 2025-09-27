--[[
-- handlers.lua
--
-- This module contains the specific logic for generating files for each
-- state management solution (BLoC, Provider, etc.). Each handler is responsible
-- for creating the necessary source and (optionally) test files.
--]]

local utils = require("archflow.utils")

local M = {}

---Creates a directory path, including all parent directories.
---@param path string The directory path to create.
local function create_directory(path)
  vim.fn.mkdir(path, "p")
end

---Creates a file with the given content.
---@param path string The file path.
---@param content string The content to write.
local function create_file(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

---A generic function to create a source file and an optional test file from templates.
---@param config table The plugin's configuration.
---@param file_creation_params table Parameters for file creation:
---  {
---    base_path: string,         -- e.g., "/path/to/project/lib/features/my_feature"
---    test_base_path: string,    -- e.g., "/path/to/project/test/features/my_feature"
---    template_vars: table,      -- { featureName, className }
---    create_test: boolean,      -- Whether to create a test file
---    source_template: string,   -- e.g., "bloc/bloc"
---    test_template: string,     -- e.g., "bloc/bloc_test"
---    source_suffix: string,     -- e.g., "_bloc.dart"
---    test_suffix: string,       -- e.g., "_bloc_test.dart"
---  }
local function create_source_and_test(config, p)
  -- Create source file
  local source_content = utils.read_template(config, p.source_template)
  local rendered_source = utils.render_template(source_content, p.template_vars)
  create_file(p.base_path .. "/" .. p.template_vars.featureName .. p.source_suffix, rendered_source)

  -- Create test file if requested
  if p.create_test then
    local test_content = utils.read_template(config, p.test_template)
    if test_content ~= "" then
      create_directory(p.test_base_path)
      local rendered_test = utils.render_template(test_content, p.template_vars)
      create_file(p.test_base_path .. "/" .. p.template_vars.featureName .. p.test_suffix, rendered_test)
    end
  end
end

--- Handler for BLoC file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_bloc_files(config, p)
  -- BLoC file
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "bloc/bloc", test_template = "bloc/bloc_test",
    source_suffix = "_bloc.dart", test_suffix = "_bloc_test.dart",
  })

  -- Event file (no test)
  local event_content = utils.read_template(config, "bloc/event")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_event.dart", utils.render_template(event_content, p.vars))

  -- State file (no test)
  local state_content = utils.read_template(config, "bloc/state")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_state.dart", utils.render_template(state_content, p.vars))

  return {
    p.sm_folder .. "/" .. p.vars.featureName .. "_bloc.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_event.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_state.dart",
  }
end

--- Handler for Provider file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_provider_files(config, p)
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "provider/provider", test_template = "provider/provider_test",
    source_suffix = "_provider.dart", test_suffix = "_provider_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_provider.dart" }
end

-- Handlers for Cubit, GetX, and Riverpod would follow the exact same pattern.
-- For brevity, they are omitted but would be implemented similarly to create_provider_files.

return M

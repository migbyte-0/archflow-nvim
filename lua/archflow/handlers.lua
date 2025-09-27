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
---@param p table Parameters for file creation.
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

--- ADDED: Handler for Cubit file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_cubit_files(config, p)
  -- Cubit file
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "cubit/cubit", test_template = "cubit/cubit_test",
    source_suffix = "_cubit.dart", test_suffix = "_cubit_test.dart",
  })

  -- State file (no test)
  local state_content = utils.read_template(config, "cubit/state")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_state.dart", utils.render_template(state_content, p.vars))

  return {
    p.sm_folder .. "/" .. p.vars.featureName .. "_cubit.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_state.dart",
  }
end

--- ADDED: Handler for GetX file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_getx_files(config, p)
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "getx/controller", test_template = "getx/controller_test",
    source_suffix = "_controller.dart", test_suffix = "_controller_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_controller.dart" }
end

--- ADDED: Handler for Riverpod file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_riverpod_files(config, p)
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "riverpod/provider", test_template = "riverpod/provider_test",
    source_suffix = "_provider.dart", test_suffix = "_provider_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_provider.dart" }
end

--- ADDED: Handler for MobX file generation.
---@param config table The plugin's configuration.
---@param p table The generation parameters.
function M.create_mobx_files(config, p)
  create_source_and_test(config, {
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "mobx/store", test_template = "mobx/store_test",
    source_suffix = "_store.dart", test_suffix = "_store_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_store.dart" }
end

return M

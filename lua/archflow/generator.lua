--[[
-- generator.lua
--
-- This module is the core engine of the plugin. It orchestrates the process
-- of generating a new feature by:
-- 1. Finding the project root.
-- 2. Checking for existing features to prevent overwrites.
-- 3. Creating the necessary directory structure.
-- 4. Dispatching to the correct handler to generate state management files.
-- 5. Creating a barrel export file for the new feature.
--]]

local utils = require("archflow.utils")
local handlers = require("archflow.handlers")

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

--- Main function to generate Clean Architecture files for a feature.
---@param config table The plugin's current configuration.
---@param feature_name string The snake_case name of the feature.
---@param state_management string The chosen state management solution.
---@param create_test boolean Whether to generate test files.
function M.generate_clean_architecture(config, feature_name, state_management, create_test)
  local project_root = utils.find_project_root()
  if not project_root then return end

  -- ADDED: Get the project name for test file templates.
  local project_name = utils.get_project_name(project_root)
  if not project_name then return end

  local feature_base_path = project_root .. "/" .. config.feature_path .. "/" .. feature_name
  local test_base_path = project_root .. "/" .. config.test_path .. "/" .. feature_name

  -- Check if feature already exists to prevent accidental overwrites.
  if vim.fn.isdirectory(feature_base_path) == 1 then
    local choice = vim.ui.input({ prompt = "Feature '" .. feature_name .. "' already exists. Overwrite? (y/n): ", default = "n" })
    if not choice or choice:lower() ~= "y" then
      return utils.notify("Feature generation cancelled.", vim.log.levels.WARN)
    end
  end

  utils.notify("Generating feature: " .. feature_name)

  local class_name = utils.to_pascal_case(feature_name)
  local sm_folder = config.dir_names[state_management] or "state"

  -- Define the directory structure for Clean Architecture.
  local directories = {
    "data/datasources", "data/models", "data/repositories",
    "domain/entities", "domain/repositories", "domain/usecases",
    "presentation/screens", "presentation/widgets",
    "presentation/" .. sm_folder,
  }

  local export_paths = {}

  -- Create all directories and placeholder files.
  for _, dir in ipairs(directories) do
    local full_dir_path = feature_base_path .. "/" .. dir
    create_directory(full_dir_path)

    if dir ~= "presentation/" .. sm_folder then
      local simple_name = dir:match("[^/]+$")
      local file_base_name = feature_name .. "_" .. simple_name
      create_file(full_dir_path .. "/" .. file_base_name .. ".dart", "// Placeholder for " .. file_base_name)
      table.insert(export_paths, dir .. "/" .. file_base_name .. ".dart")
    end
  end

  -- UPDATED: Complete handler map.
  local handler_map = {
    bloc = handlers.create_bloc_files,
    provider = handlers.create_provider_files,
    cubit = handlers.create_cubit_files,
    getx = handlers.create_getx_files,
    riverpod = handlers.create_riverpod_files,
    mobx = handlers.create_mobx_files,
  }

  local handler = handler_map[state_management]
  if handler then
    local handler_params = {
      base_path = feature_base_path .. "/presentation/" .. sm_folder,
      test_base_path = test_base_path .. "/presentation/" .. sm_folder,
      -- ADDED: Pass the projectName to the template variables.
      vars = { featureName = feature_name, className = class_name, projectName = project_name },
      create_test = create_test,
      sm_folder = "presentation/" .. sm_folder,
    }
    local generated_files = handler(config, handler_params)
    vim.list_extend(export_paths, generated_files)
  else
    return utils.notify("Handler not found for: " .. state_management, vim.log.levels.ERROR)
  end

  -- Create the main barrel export file for the feature.
  local export_file_path = feature_base_path .. "/" .. feature_name .. ".dart"
  local export_content = table.concat(vim.tbl_map(function(p) return "export '" .. p .. "';" end, export_paths), "\n")
  create_file(export_file_path, export_content)

  utils.notify("Successfully generated feature '" .. feature_name .. "'!", vim.log.levels.INFO)
end

return M

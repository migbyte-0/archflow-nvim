-- ~/.config/nvim/lua/local/archflow-nvim/lua/archflow/generator.lua

local utils = require("archflow.utils")
local handlers = require("archflow.handlers")

local M = {}

local function create_directory(path)
  vim.fn.mkdir(path, "p")
end

local function create_file(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

---
--- Generator for MVC and MVVM Architectures
---
function M.generate_mvc_mvvm(config, architecture, feature_name, state_management, create_test)
  local project_root = utils.find_project_root()
  if not project_root then return end

  local project_name = utils.get_project_name(project_root)
  if not project_name then return end

  local feature_base_path = project_root .. "/" .. config.feature_path .. "/" .. feature_name

  if vim.fn.isdirectory(feature_base_path) == 1 then
    local choice = vim.ui.input({ prompt = "Feature '" .. feature_name .. "' already exists. Overwrite? (y/n): ", default = "n" })
    if not choice or choice:lower() ~= "y" then
      return utils.notify("Feature generation cancelled.", vim.log.levels.WARN)
    end
  end

  utils.notify("Generating " .. architecture:upper() .. " feature: " .. feature_name)

  local class_name = utils.to_pascal_case(feature_name)
  local vars = { featureName = feature_name, className = class_name, projectName = project_name }
  
  local logic_dir_name = (architecture == "mvc") and "controller" or "viewmodel"
  
  local dirs_to_create = { "model", "view", logic_dir_name }
  for _, dir in ipairs(dirs_to_create) do
    create_directory(feature_base_path .. "/" .. dir)
  end

  local model_template = utils.get_template("shared/model")
  create_file(feature_base_path .. "/model/" .. feature_name .. "_model.dart", utils.render_template(model_template, vars))
  
  local view_template = utils.get_template("shared/view")
  create_file(feature_base_path .. "/view/" .. feature_name .. "_view.dart", utils.render_template(view_template, vars))

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
    local test_base_path = project_root .. "/" .. config.test_path .. "/" .. feature_name .. "/" .. logic_dir_name
    local handler_params = {
      base_path = feature_base_path .. "/" .. logic_dir_name,
      test_base_path = test_base_path,
      vars = vars,
      create_test = create_test,
      sm_folder = logic_dir_name,
    }
    handler(config, handler_params)
  else
    return utils.notify("Handler not found for: " .. state_management, vim.log.levels.ERROR)
  end

  utils.notify("Successfully generated " .. architecture:upper() .. " feature '" .. feature_name .. "'!", vim.log.levels.INFO)
end

---
--- Generator for Clean Architecture
---
function M.generate_clean_architecture(config, feature_name, state_management, create_test)
  local project_root = utils.find_project_root()
  if not project_root then return end

  local project_name = utils.get_project_name(project_root)
  if not project_name then return end

  local feature_base_path = project_root .. "/" .. config.feature_path .. "/" .. feature_name
  local test_base_path = project_root .. "/" .. config.test_path .. "/" .. feature_name

  if vim.fn.isdirectory(feature_base_path) == 1 then
    local choice = vim.ui.input({ prompt = "Feature '" .. feature_name .. "' already exists. Overwrite? (y/n): ", default = "n" })
    if not choice or choice:lower() ~= "y" then
      return utils.notify("Feature generation cancelled.", vim.log.levels.WARN)
    end
  end

  utils.notify("Generating Clean Architecture feature: " .. feature_name)

  local class_name = utils.to_pascal_case(feature_name)
  local sm_folder = config.dir_names[state_management] or "state"
  local vars = { featureName = feature_name, className = class_name, projectName = project_name }

  local directories = {
    "data/datasources", "data/models", "data/repositories",
    "domain/entities", "domain/repositories", "domain/usecases",
    "presentation/screens", "presentation/widgets",
    "presentation/" .. sm_folder,
  }

  local export_paths = {}

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
      vars = vars,
      create_test = create_test,
      sm_folder = "presentation/" .. sm_folder,
    }
    local generated_files = handler(config, handler_params)
    vim.list_extend(export_paths, generated_files)
  else
    return utils.notify("Handler not found for: " .. state_management, vim.log.levels.ERROR)
  end

  local export_file_path = feature_base_path .. "/" .. feature_name .. ".dart"
  local export_content = table.concat(vim.tbl_map(function(p) return "export '" .. p .. "';" end, export_paths), "\n")
  create_file(export_file_path, export_content)

  utils.notify("Successfully generated Clean Architecture feature '" .. feature_name .. "'!", vim.log.levels.INFO)
end

return M

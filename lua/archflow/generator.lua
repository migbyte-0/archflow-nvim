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
--- NEW FUNCTION to handle both MVC and MVVM generation.
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
  
  -- Determine the directory name for the logic part (Controller or ViewModel)
  local logic_dir_name = (architecture == "mvc") and "controller" or "viewmodel"
  
  -- Create the directory structure
  local dirs_to_create = { "model", "view", logic_dir_name }
  for _, dir in ipairs(dirs_to_create) do
    create_directory(feature_base_path .. "/" .. dir)
  end

  -- Generate Model file
  local model_template = utils.get_template("shared/model")
  create_file(feature_base_path .. "/model/" .. feature_name .. "_model.dart", utils.render_template(model_template, vars))
  
  -- Generate View file
  local view_template = utils.get_template("shared/view")
  create_file(feature_base_path .. "/view/" .. feature_name .. "_view.dart", utils.render_template(view_template, vars))

  -- Dispatch to the correct state management handler to create the Controller/ViewModel
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
      sm_folder = logic_dir_name, -- This is not used for barrel files in MVC/MVVM
    }
    handler(config, handler_params) -- Call the handler
  else
    return utils.notify("Handler not found for: " .. state_management, vim.log.levels.ERROR)
  end

  utils.notify("Successfully generated " .. architecture:upper() .. " feature '" .. feature_name .. "'!", vim.log.levels.INFO)
end

-- The Clean Architecture function remains the same.
function M.generate_clean_architecture(config, feature_name, state_management, create_test)
  -- ... (your existing clean architecture code)
end

return M

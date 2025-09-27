-- A significantly improved and refactored module for generating Flutter features.

local M = {}

--------------------------------------------------------------------------------
-- 1. UTILS & HELPERS
--------------------------------------------------------------------------------

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "ArchFlow" })
end

local function create_directory(path)
  vim.fn.mkdir(path, "p")
end

local function create_file(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

local function to_pascal_case(str)
  return (str:gsub("_?(.?)", function(c) return c:upper() end):gsub("^%l", string.upper))
end

local function render_template(template_content, vars)
  return template_content:gsub("{{(.-)}}", function(key)
    return tostring(vars[key] or "")
  end)
end

-- NEW HELPER: Gets the root path of the plugin.
local function get_plugin_path()
  -- This finds the path of the currently running script and goes up to the root
  return debug.getinfo(2, "S").source:match("@?(.*[/\\])") .. "../"
end

-- NEW HELPER: Reads content from a template file.
local function read_template(template_path)
  local full_path = get_plugin_path() .. "templates/" .. template_path .. ".dart.template"
  local file = io.open(full_path, "r")
  if not file then
    vim.notify("Template not found: " .. full_path, vim.log.levels.ERROR)
    return ""
  end
  local content = file:read("*a")
  file:close()
  return content
end


--------------------------------------------------------------------------------
-- 2. STATE-MANAGEMENT HANDLERS
--------------------------------------------------------------------------------

-- UPDATED HANDLER: Now reads from templates/provider/provider.dart.template
local function create_provider_files(dir_path, feature_name, class_name)
  local vars = { className = class_name }
  local template_content = read_template("provider/provider")
  local rendered_content = render_template(template_content, vars)

  create_file(dir_path .. "/" .. feature_name .. "_provider.dart", rendered_content)
  return { "presentation/provider/" .. feature_name .. "_provider.dart" }
end

-- UPDATED HANDLER: Now reads from templates/bloc/*.dart.template
local function create_bloc_files(dir_path, feature_name, class_name)
  local vars = { featureName = feature_name, className = class_name }

  -- BLoC: bloc.dart
  local bloc_template = read_template("bloc/bloc")
  local bloc_content = render_template(bloc_template, vars)
  create_file(dir_path .. "/" .. feature_name .. "_bloc.dart", bloc_content)

  -- BLoC: event.dart
  local event_template = read_template("bloc/event")
  local event_content = render_template(event_template, vars)
  create_file(dir_path .. "/" .. feature_name .. "_event.dart", event_content)

  -- BLoC: state.dart
  local state_template = read_template("bloc/state")
  local state_content = render_template(state_template, vars)
  create_file(dir_path .. "/" .. feature_name .. "_state.dart", state_content)

  return {
    "presentation/bloc/" .. feature_name .. "_bloc.dart",
    "presentation/bloc/" .. feature_name .. "_event.dart",
    "presentation/bloc/" .. feature_name .. "_state.dart",
  }
end
-- ... Add other handlers for Cubit, Riverpod, GetX in the same updated style


---
--- DISPATCH TABLE for State Management
---
local state_handlers = {
  provider = { generator = create_provider_files, folder = "provider" },
  bloc = { generator = create_bloc_files, folder = "bloc" },
  -- cubit = { generator = create_cubit_files, folder = "cubit" },
  -- riverpod = { generator = create_riverpod_file, folder = "provider" },
  -- getx = { generator = create_getx_file, folder = "controller" },
}


--------------------------------------------------------------------------------
-- 4. CLEAN ARCHITECTURE GENERATION (This section remains the same)
--------------------------------------------------------------------------------
local function generate_clean_architecture_files(base_path, feature_name, state_management)
  -- ... no changes needed here ...
  local feature_base_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_base_path)

  local class_name = to_pascal_case(feature_name)
  local handler_info = state_handlers[state_management]
  if not handler_info then
    return notify("State management handler not found for: " .. state_management, vim.log.levels.ERROR)
  end

  local directories = {
    "data/datasources",
    "data/models",
    "data/repositories",
    "domain/entities",
    "domain/repositories",
    "domain/usecases",
    "presentation/screens",
    "presentation/widgets",
    "presentation/" .. handler_info.folder, -- Dynamic folder name
  }

  local export_paths = {}

  for _, dir in ipairs(directories) do
    local dir_path = feature_base_path .. "/" .. dir
    create_directory(dir_path)

    if dir == "presentation/" .. handler_info.folder then
      local generated_files = handler_info.generator(dir_path, feature_name, class_name)
      vim.list_extend(export_paths, generated_files)
    else
      local simple_name = dir:match("[^/]+$")
      local file_base_name = feature_name .. "_" .. simple_name
      local file_path = dir_path .. "/" .. file_base_name .. ".dart"
      create_file(file_path, "// Placeholder for " .. file_base_name)
      table.insert(export_paths, dir .. "/" .. file_base_name .. ".dart")
    end
  end

  local export_file_path = feature_base_path .. "/" .. feature_name .. ".dart"
  local export_content = table.concat(vim.tbl_map(function(p) return "export '" .. p .. "';" end, export_paths), "\n")
  create_file(export_file_path, export_content)

  notify("Clean Architecture feature '" .. feature_name .. "' created with " .. state_management)
end

--------------------------------------------------------------------------------
-- 5. MAIN ENTRY FUNCTION (This section remains the same)
--------------------------------------------------------------------------------

function M.generate_feature()
  -- ... no changes needed here ...
  local base_path = vim.fn.getcwd()

  local arch_options = { "Clean Architecture", "MVC", "MVVM" }
  local arch_choice = vim.ui.select(arch_options, { prompt = "Select architecture:" })
  if not arch_choice then return notify("Feature generation cancelled.", vim.log.levels.WARN) end

  local sm_options = { "Provider", "BLoC", "Cubit", "Riverpod", "GetX" }
  local sm_choice = vim.ui.select(sm_options, { prompt = "Select state management:" })
  if not sm_choice then return notify("Feature generation cancelled.", vim.log.levels.WARN) end

  local architecture = arch_choice:lower():gsub(" ", "_")
  local state_management = sm_choice:lower()

  vim.ui.input({ prompt = "Enter feature name:" }, function(feature_name)
    if not feature_name or feature_name == "" then
      return notify("Feature name cannot be empty.", vim.log.levels.ERROR)
    end

    feature_name = feature_name:lower():gsub("%s+", "_"):gsub("[^%w_]", "")

    if architecture == "clean_architecture" then
      generate_clean_architecture_files(base_path, feature_name, state_management)
    else
      notify(architecture .. " generation is not fully implemented in this example.")
    end
  end)
end

--------------------------------------------------------------------------------
-- 6. SETUP FUNCTION (This section remains the same)
--------------------------------------------------------------------------------

function M.setup()
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "[A]rchFlow: [F]eature Generate" })
end

return M


-- A significantly improved and refactored module for generating Flutter features.

local M = {}

--------------------------------------------------------------------------------
-- 1. UTILS & HELPERS
--    - Uses vim.fn and vim.notify for better integration.
--------------------------------------------------------------------------------

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "ArchFlow" })
end

---Creates a directory path, including all parent directories.
---@param path string The directory path to create.
local function create_directory(path)
  -- Use Neovim's native, cross-platform mkdir function.
  vim.fn.mkdir(path, "p")
end

---Creates a file with the given content.
---@param path string The file path.
---@param content string The content to write.
local function create_file(path, content)
  -- Use vim.fn.writefile for a more direct approach.
  vim.fn.writefile(vim.split(content, "\n"), path)
end

---Converts snake_case or lowerCamelCase to UpperCamelCase (PascalCase).
---e.g. "my_feature" -> "MyFeature"
---@param str string
---@return string
local function to_pascal_case(str)
  return (str:gsub("_?(.?)", function(c) return c:upper() end):gsub("^%l", string.upper))
end

---Simple template renderer.
---@param template_content string The content with placeholders like {{name}}.
---@param vars table A table of key-value pairs for substitution.
---@return string
local function render_template(template_content, vars)
  return template_content:gsub("{{(.-)}}", function(key)
    return tostring(vars[key] or "")
  end)
end


--------------------------------------------------------------------------------
-- 2. STATE-MANAGEMENT HANDLERS
--    - Each function is now a self-contained handler.
--    - This section can be moved to its own file for even better organization.
--------------------------------------------------------------------------------

-- For brevity, I'll only show the structure for a couple.
-- Assume you have template files like `templates/bloc/bloc.dart.template`.

local function create_provider_files(dir_path, feature_name, class_name)
  local content = [[
import 'package:flutter/material.dart';

class {{className}}Provider extends ChangeNotifier {
  String _message = 'Default Message';

  String get message => _message;

  void updateMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }
}
]]
  local rendered_content = render_template(content, { className = class_name })
  create_file(dir_path .. "/" .. feature_name .. "_provider.dart", rendered_content)
  return { "presentation/provider/" .. feature_name .. "_provider.dart" }
end

local function create_bloc_files(dir_path, feature_name, class_name)
  -- BLoC: bloc.dart
  local bloc_content = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part '{{featureName}}_event.dart';
part '{{featureName}}_state.dart';

class {{className}}Bloc extends Bloc<{{className}}Event, {{className}}State> {
  {{className}}Bloc() : super({{className}}Initial()) {
    on<{{className}}Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]
  create_file(
    dir_path .. "/" .. feature_name .. "_bloc.dart",
    render_template(bloc_content, { className = class_name, featureName = feature_name })
  )

  -- BLoC: event.dart
  local event_content = [[
part of '{{featureName}}_bloc.dart';

abstract class {{className}}Event extends Equatable {
  const {{className}}Event();
  @override
  List<Object> get props => [];
}
class {{className}}Started extends {{className}}Event {}
]]
  create_file(
    dir_path .. "/" .. feature_name .. "_event.dart",
    render_template(event_content, { className = class_name, featureName = feature_name })
  )

  -- BLoC: state.dart
  -- (Content omitted for brevity, but follows the same pattern)
  create_file(dir_path .. "/" .. feature_name .. "_state.dart", "...")

  -- Return list of generated files for export barrel file
  return {
    "presentation/bloc/" .. feature_name .. "_bloc.dart",
    "presentation/bloc/" .. feature_name .. "_event.dart",
    "presentation/bloc/" .. feature_name .. "_state.dart",
  }
end
-- ... Add other handlers for Cubit, Riverpod, GetX in the same style

---
--- DISPATCH TABLE for State Management
--- This is the core of the refactor. It maps a key to a function.
---
local state_handlers = {
  provider = { generator = create_provider_files, folder = "provider" },
  bloc = { generator = create_bloc_files, folder = "bloc" },
  -- cubit = { generator = create_cubit_files, folder = "cubit" },
  -- riverpod = { generator = create_riverpod_file, folder = "provider" },
  -- getx = { generator = create_getx_file, folder = "controller" },
}


--------------------------------------------------------------------------------
-- 4. CLEAN ARCHITECTURE GENERATION
--    - Massively simplified by using the dispatch table.
--------------------------------------------------------------------------------

local function generate_clean_architecture_files(base_path, feature_name, state_management)
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
      -- Use the dispatch table to call the correct function
      local generated_files = handler_info.generator(dir_path, feature_name, class_name)
      vim.list_extend(export_paths, generated_files)
    else
      -- Logic for creating placeholder files
      -- This part could also be refined, but is fine as is.
      local simple_name = dir:match("[^/]+$")
      local file_base_name = feature_name .. "_" .. simple_name
      -- ... (your existing filename logic)
      local file_path = dir_path .. "/" .. file_base_name .. ".dart"
      create_file(file_path, "// Placeholder for " .. file_base_name)
      table.insert(export_paths, dir .. "/" .. file_base_name .. ".dart")
    end
  end

  -- Create a single, consolidated export file
  local export_file_path = feature_base_path .. "/" .. feature_name .. ".dart"
  local export_content = table.concat(vim.tbl_map(function(p) return "export '" .. p .. "';" end, export_paths), "\n")
  create_file(export_file_path, export_content)

  notify("Clean Architecture feature '" .. feature_name .. "' created with " .. state_management)
end

-- MVC/MVVM generation function would be refactored similarly.


--------------------------------------------------------------------------------
-- 5. MAIN ENTRY FUNCTION
--    - Uses vim.ui.select for a modern, user-friendly UI.
--------------------------------------------------------------------------------

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  -- Architecture Selection
  local arch_options = { "Clean Architecture", "MVC", "MVVM" }
  local arch_choice = vim.ui.select(arch_options, { prompt = "Select architecture:" })
  if not arch_choice then return notify("Feature generation cancelled.", vim.log.levels.WARN) end

  -- State Management Selection
  local sm_options = { "Provider", "BLoC", "Cubit", "Riverpod", "GetX" }
  local sm_choice = vim.ui.select(sm_options, { prompt = "Select state management:" })
  if not sm_choice then return notify("Feature generation cancelled.", vim.log.levels.WARN) end

  local architecture = arch_choice:lower():gsub(" ", "_") -- "Clean Architecture" -> "clean_architecture"
  local state_management = sm_choice:lower()

  -- Feature Name Input
  vim.ui.input({ prompt = "Enter feature name:" }, function(feature_name)
    if not feature_name or feature_name == "" then
      return notify("Feature name cannot be empty.", vim.log.levels.ERROR)
    end

    -- Convert to snake_case for consistency
    feature_name = feature_name:lower():gsub("%s+", "_"):gsub("[^%w_]", "")

    if architecture == "clean_architecture" then
      generate_clean_architecture_files(base_path, feature_name, state_management)
    else
      -- generate_mvc_mvvm_files(base_path, feature_name, architecture, state_management)
      notify(architecture .. " generation is not fully implemented in this example.")
    end
  end)
end

--------------------------------------------------------------------------------
-- 6. SETUP FUNCTION
--------------------------------------------------------------------------------

function M.setup()
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "[A]rchFlow: [F]eature Generate" })
end

return M

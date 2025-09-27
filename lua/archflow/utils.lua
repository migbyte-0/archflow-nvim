--[[
-- utils.lua
--
-- This module provides utility functions for path manipulation, template rendering,
-- and other helper tasks. It helps keep the rest of the codebase clean and focused.
--]]

local M = {}

--- Notifies the user with a formatted message.
---@param msg string The message to display.
---@param level integer|nil An optional vim.log.levels value (e.g., ERROR, WARN).
function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "ArchFlow" })
end

---Converts a string from snake_case or kebab-case to PascalCase.
--- e.g., "my_feature" -> "MyFeature"
---@param str string The input string.
---@return string The PascalCase version of the string.
function M.to_pascal_case(str)
  return (str:gsub("[_-](.)", string.upper):gsub("^%l", string.upper))
end

---Simple template renderer that replaces {{key}} placeholders.
---@param template_content string The template content with placeholders.
---@param vars table A table of key-value pairs for substitution (e.g., { className = "MyClass" }).
---@return string The rendered string with placeholders replaced.
function M.render_template(template_content, vars)
  return template_content:gsub("{{(.-)}}", function(key)
    -- Trim whitespace from key, just in case
    key = key:match("^%s*(.-)%s*$")
    return tostring(vars[key] or "")
  end)
end

---Gets the root path of the plugin itself.
--- Used to locate the default templates directory.
---@return string The absolute path to the plugin's root directory.
function M.get_plugin_path()
  -- This reliably finds the path of the currently running script.
  return debug.getinfo(2, "S").source:match("@?(.*[/\\])") .. "../"
end

---Reads the content of a template file.
--- It first checks the user's custom template path if provided,
--- then falls back to the plugin's internal templates.
---@param config table The plugin's current configuration table.
---@param template_path string The relative path of the template (e.g., "bloc/bloc").
---@return string The content of the template file, or an empty string if not found.
function M.read_template(config, template_path)
  local path_to_check

  -- 1. Check for user-defined custom templates first.
  if config.custom_template_path then
    path_to_check = config.custom_template_path .. "/" .. template_path .. ".dart.template"
    local file = io.open(path_to_check, "r")
    if file then
      local content = file:read("*a")
      file:close()
      return content
    end
  end

  -- 2. Fallback to the plugin's default templates.
  path_to_check = M.get_plugin_path() .. "templates/" .. template_path .. ".dart.template"
  local file = io.open(path_to_check, "r")
  if not file then
    M.notify("Template not found: " .. template_path, vim.log.levels.ERROR)
    return ""
  end
  local content = file:read("*a")
  file:close()
  return content
end

---Searches upwards from the current buffer's directory to find the project root.
--- The project root is identified by the presence of a 'pubspec.yaml' file.
---@return string|nil The path to the project root, or nil if not found.
function M.find_project_root()
  local current_buf_path = vim.api.nvim_buf_get_name(0)
  if current_buf_path == "" then
    M.notify("Cannot find project root: current buffer has no file path.", vim.log.levels.ERROR)
    return nil
  end

  local start_path = vim.fn.fnamemodify(current_buf_path, ":h")
  local root_marker = "pubspec.yaml"
  local project_root = vim.fn.finddir(root_marker, start_path .. ";")

  if project_root == "" then
    M.notify("Could not find 'pubspec.yaml'. Are you in a Flutter project?", vim.log.levels.ERROR)
    return nil
  end

  return vim.fn.fnamemodify(project_root, ":h")
end

--- NEW FUNCTION: Reads the pubspec.yaml file and extracts the project name.
--- This is crucial for generating correct import paths in test files.
---@param project_root string The absolute path to the project root.
---@return string|nil The project name, or nil if not found.
function M.get_project_name(project_root)
  local pubspec_path = project_root .. "/pubspec.yaml"
  local file = io.open(pubspec_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  -- Find the 'name:' field and extract its value.
  local name = content:match("\nname:%s*([%w_]+)")
  if not name then
    M.notify("Could not parse project name from pubspec.yaml", vim.log.levels.WARN)
    return "my_project" -- Fallback
  end

  return name
end

return M

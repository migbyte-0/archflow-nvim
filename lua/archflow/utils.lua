--[[
-- utils.lua
--
-- This module provides utility functions for path manipulation, template rendering,
-- and other helper tasks. It helps keep the rest of the codebase clean and focused.
--]]

local M = {}

-- ... (all other functions like notify, to_pascal_case, etc., stay the same) ...

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "ArchFlow" })
end

function M.to_pascal_case(str)
  return (str:gsub("[_-](.)", string.upper):gsub("^%l", string.upper))
end

function M.render_template(template_content, vars)
  return template_content:gsub("{{(.-)}}", function(key)
    key = key:match("^%s*(.-)%s*$")
    return tostring(vars[key] or "")
  end)
end

function M.get_plugin_path()
  return debug.getinfo(2, "S").source:match("@?(.*[/\\])") .. "../"
end

function M.read_template(config, template_path)
  local path_to_check
  if config.custom_template_path then
    path_to_check = config.custom_template_path .. "/" .. template_path .. ".dart.template"
    local file = io.open(path_to_check, "r")
    if file then
      local content = file:read("*a")
      file:close()
      return content
    end
  end
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

function M.find_project_root()
  local current_buf_path = vim.api.nvim_buf_get_name(0)
  if current_buf_path == "" or current_buf_path == nil then
    M.notify("Cannot find project root: current buffer has no file path.", vim.log.levels.ERROR)
    return nil
  end
  local current_dir = vim.fn.fnamemodify(current_buf_path, ":h")
  local root_marker = "pubspec.yaml"
  while current_dir ~= "" and current_dir ~= "/" and current_dir ~= vim.fn.fnamemodify(current_dir, ":h") do
    local check_path = current_dir .. "/" .. root_marker
    local file = io.open(check_path, "r")
    if file then
      file:close()
      return current_dir
    end
    current_dir = vim.fn.fnamemodify(current_dir, ":h")
  end
  M.notify("Could not find 'pubspec.yaml'. Are you in a Flutter project?", vim.log.levels.ERROR)
  return nil
end

--- Reads the pubspec.yaml file and extracts the project name.
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

  -- UPDATED REGEX: This is now more robust.
  -- It handles the 'name:' field being at the start of the file
  -- and allows for hyphens (-) in the project name.
  local name = content:match("(^|\n)name:%s*([%w_-]+)")
  if not name then
    M.notify("Could not parse project name from pubspec.yaml", vim.log.levels.WARN)
    return "my_project" -- Fallback
  end

  -- The capture group we want is the second one.
  return name:match("([^%s]+)$")
end

return M

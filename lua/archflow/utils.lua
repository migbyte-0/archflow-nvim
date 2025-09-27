-- ~/.config/nvim/lua/local/archflow-nvim/lua/archflow/utils.lua

local M = {}

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

function M.get_template(template_path)
  -- This requires the new templates.lua file
  local templates = require("archflow.templates")
  local key = template_path:gsub("/", "_")
  local content = templates[key]

  if not content then
    M.notify("Internal template key not found: " .. key, vim.log.levels.ERROR)
    return ""
  end
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

---
--- FINAL UPDATED FUNCTION
--- Reads the pubspec.yaml file and extracts the project name.
---
function M.get_project_name(project_root)
  local pubspec_path = project_root .. "/pubspec.yaml"
  local file = io.open(pubspec_path, "r")
  if not file then
    return nil
  end

  local content = file:read("*a")
  file:close()

  -- SUPER-ROBUST REGEX: This handles extra spaces, quotes, and different cases.
  local _, project_name = content:match('(^|\n)%s*[nN]ame:%s*["\']?([%w_-]+)["\']?')

  if not project_name then
    M.notify("Could not parse project name from pubspec.yaml", vim.log.levels.WARN)
    return "my_project" -- Fallback
  end

  return project_name
end

return M

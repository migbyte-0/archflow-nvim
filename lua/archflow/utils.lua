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

function M.get_plugin_path()
  return debug.getinfo(2, "S").source:match("@?(.*[/\\])") .. "../"
end

---
--- REPLACED AND IMPROVED FUNCTION
---
---Reads the content of a template file using Neovim's native API.
--- This is more robust than the standard Lua io library.
---
function M.read_template(config, template_path)
  local path_to_check

  -- Function to read a file using vim's API
  local function read_with_vim_api(path)
    if vim.fn.filereadable(path) == 1 then
      local lines = vim.fn.readfile(path)
      return table.concat(lines, "\n")
    end
    return nil
  end

  -- 1. Check for user-defined custom templates first.
  if config.custom_template_path then
    path_to_check = config.custom_template_path .. "/" .. template_path .. ".dart.template"
    local content = read_with_vim_api(path_to_check)
    if content then
      return content
    end
  end

  -- 2. Fallback to the plugin's default templates.
  path_to_check = M.get_plugin_path() .. "templates/" .. template_path .. ".dart.template"
  local content = read_with_vim_api(path_to_check)
  if content then
    return content
  end

  -- If neither path worked, notify the user.
  M.notify("Template not found or not readable: " .. template_path, vim.log.levels.ERROR)
  return ""
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

function M.get_project_name(project_root)
  local pubspec_path = project_root .. "/pubspec.yaml"
  local file = io.open(pubspec_path, "r")
  if not file then
    return nil
  end
  local content = file:read("*a")
  file:close()
  local _, project_name = content:match("(^|\n)name:%s*([%w_-]+)")
  if not project_name then
    M.notify("Could not parse project name from pubspec.yaml", vim.log.levels.WARN)
    return "my_project" -- Fallback
  end
  return project_name
end

return M

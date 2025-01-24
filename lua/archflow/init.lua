local M = {}

local function create_directory(path)
  os.execute("mkdir -p " .. path)
end

local function create_file(path, content)
  local file = io.open(path, "w")
  if file then
    file:write(content)
    file:close()
  else
    print("Failed to create file: " .. path)
  end
end

local function prompt_user(prompt_text, choices)
  local choice = vim.fn.input(prompt_text .. " (" .. table.concat(choices, "/") .. "): ")
  return choice
end

local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  local directories = {
    "data", "domain", "presentation",
  }

  for _, dir in ipairs(directories) do
    create_directory(feature_path .. "/" .. dir)
  end

  if architecture == "clean" then
    create_directory(feature_path .. "/data/models")
    create_directory(feature_path .. "/domain/entities")
    create_directory(feature_path .. "/presentation/widgets")
  end

  local state_path = feature_path .. "/presentation/"
  if state_management == "bloc" then
    state_path = state_path .. "blocs"
  elseif state_management == "provider" then
    state_path = state_path .. "providers"
  end
  create_directory(state_path)

  create_file(state_path .. "/state.dart", "// State file for " .. feature_name)
  create_file(state_path .. "/logic.dart", "// Logic file for " .. feature_name)
end

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  local architecture = prompt_user("Select architecture", { "mvc", "mvvm", "clean" })
  if not architecture then
    print("Invalid architecture selection.")
    return
  end

  local state_management = prompt_user("Select state management", { "provider", "bloc", "riverpod", "getx" })
  if not state_management then
    print("Invalid state management selection.")
    return
  end

  local feature_name = vim.fn.input("Enter feature name: ")
  if feature_name == "" then
    print("Feature name cannot be empty.")
    return
  end

  generate_architecture_structure(base_path, feature_name, architecture, state_management)
  print("Feature " .. feature_name .. " generated with " .. architecture .. " and " .. state_management .. ".")
end

function M.setup()
  -- Provide default key mapping
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

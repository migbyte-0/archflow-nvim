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

-- Helper to display a Telescope picker
local function telescope_picker(prompt_text, choices)
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")

  local result = nil

  pickers.new({}, {
    prompt_title = prompt_text,
    finder = finders.new_table {
      results = choices,
    },
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(_, map)
      actions.select_default:replace(function()
        actions.close(_)
        result = action_state.get_selected_entry()[1]
      end)
      map("i", "<esc>", actions.close) -- Close picker with ESC
      return true
    end,
  }):find()

  -- Block until user makes a choice
  vim.wait(1000, function()
    return result ~= nil
  end, 10)
  
  return result
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

  -- Use Telescope picker for architecture
  local architecture = telescope_picker("Select Architecture", { "mvc", "mvvm", "clean" })
  if not architecture then
    print("No architecture selected.")
    return
  end

  -- Use Telescope picker for state management
  local state_management = telescope_picker("Select State Management", { "provider", "bloc", "riverpod", "getx" })
  if not state_management then
    print("No state management selected.")
    return
  end

  -- Use input for feature name
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

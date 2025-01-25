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

  if architecture == "mvc" then
    local mvc_directories = { "model", "view", "controller" }
    for _, dir in ipairs(mvc_directories) do
      create_directory(feature_path .. "/" .. dir)
    end

    -- Create files for MVC
    create_file(feature_path .. "/model/" .. feature_name .. "_model.dart", "// Model file for " .. feature_name)
    create_file(feature_path .. "/view/" .. feature_name .. "_view.dart", "// View file for " .. feature_name)
    create_file(feature_path .. "/controller/" .. feature_name .. "_controller.dart", "// Controller file for " .. feature_name)

  elseif architecture == "mvvm" then
    local mvvm_directories = { "model", "view", "viewmodel" }
    for _, dir in ipairs(mvvm_directories) do
      create_directory(feature_path .. "/" .. dir)
    end

    -- Create files for MVVM
    create_file(feature_path .. "/model/" .. feature_name .. "_model.dart", "// Model file for " .. feature_name)
    create_file(feature_path .. "/view/" .. feature_name .. "_view.dart", "// View file for " .. feature_name)
    create_file(feature_path .. "/viewmodel/" .. feature_name .. "_viewmodel.dart", "// ViewModel file for " .. feature_name)

  elseif architecture == "clean" then
    local clean_directories = {
      "data/models",
      "domain/entities",
      "presentation/widgets",
    }
    for _, dir in ipairs(clean_directories) do
      create_directory(feature_path .. "/" .. dir)
    end

    -- Create generic clean architecture files
    create_file(feature_path .. "/data/models/" .. feature_name .. "_model.dart", "// Model file for " .. feature_name)
    create_file(feature_path .. "/domain/entities/" .. feature_name .. "_entity.dart", "// Entity file for " .. feature_name)
    create_file(feature_path .. "/presentation/widgets/" .. feature_name .. "_widget.dart", "// Widget file for " .. feature_name)
  end

  if state_management == "bloc" then
    local bloc_path = feature_path .. "/presentation/blocs"
    create_directory(bloc_path)
    create_file(bloc_path .. "/" .. feature_name .. "_bloc.dart", "// Bloc file for " .. feature_name)

  elseif state_management == "provider" then
    local provider_path = feature_path .. "/presentation/providers"
    create_directory(provider_path)
    create_file(provider_path .. "/" .. feature_name .. "_provider.dart", "// Provider file for " .. feature_name)

  elseif state_management == "riverpod" then
    local riverpod_path = feature_path .. "/presentation/providers"
    create_directory(riverpod_path)
    create_file(riverpod_path .. "/" .. feature_name .. "_provider.dart", "// Riverpod provider file for " .. feature_name)

  elseif state_management == "getx" then
    local getx_path = feature_path .. "/presentation/controllers"
    create_directory(getx_path)
    create_file(getx_path .. "/" .. feature_name .. "_controller.dart", "// GetX controller file for " .. feature_name)
  end
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

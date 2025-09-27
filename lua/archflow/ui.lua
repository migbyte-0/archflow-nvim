-- ~/.config/nvim/lua/local/archflow-nvim/lua/archflow/ui.lua

local generator = require("archflow.generator")
local utils = require("archflow.utils")

local M = {}

function M.start_generation(config)
  -- 1. Select Architecture
  vim.ui.select({ "Clean Architecture", "MVVM", "MVC" }, { prompt = "Select architecture:" }, function(arch_choice)
    if not arch_choice then return utils.notify("Cancelled.", vim.log.levels.WARN) end
    local architecture = arch_choice:lower():gsub(" ", "_") -- "Clean Architecture" -> "clean_architecture"

    -- 2. Select State Management
    vim.ui.select({ "BLoC", "Cubit", "Provider", "Riverpod", "GetX", "MobX" }, { prompt = "Select state management:" }, function(sm_choice)
      if not sm_choice then return utils.notify("Cancelled.", vim.log.levels.WARN) end
      local state_management = sm_choice:lower()

      -- 3. Enter Feature Name
      vim.ui.input({ prompt = "Enter feature name (e.g., user_profile):" }, function(name)
        if not name or name == "" then return utils.notify("Feature name cannot be empty.", vim.log.levels.ERROR) end
        local feature_name = name:lower():gsub("%s+", "_"):gsub("[^%w_]", "")

        -- 4. Ask to create test files
        vim.ui.select({ "Yes", "No" }, { prompt = "Create test files?" }, function(test_choice)
          if test_choice == nil then return utils.notify("Cancelled.", vim.log.levels.WARN) end
          local create_test = (test_choice == "Yes")

          -- UPDATED: Call the correct generator based on architecture choice.
          if architecture == "clean_architecture" then
            generator.generate_clean_architecture(config, feature_name, state_management, create_test)
          elseif architecture == "mvc" or architecture == "mvvm" then
            generator.generate_mvc_mvvm(config, architecture, feature_name, state_management, create_test)
          else
            utils.notify(architecture .. " generation is not yet implemented.", vim.log.levels.WARN)
          end
        end)
      end)
    end)
  end)
end

return M

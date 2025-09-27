--[[
-- ui.lua
--
-- This module is responsible for all user interactions. It uses vim.ui to
-- present menus and prompts to the user, gathering all the necessary information
-- before handing it off to the generator.
--]]

local generator = require("archflow.generator")
local utils = require("archflow.utils")

local M = {}

---Starts the interactive feature generation process.
---@param config table The plugin's current configuration.
function M.start_generation(config)
  -- 1. Select Architecture
  vim.ui.select({ "Clean Architecture", "MVC (TBD)", "MVVM (TBD)" }, { prompt = "Select architecture:" }, function(choice)
    if not choice then return utils.notify("Cancelled.", vim.log.levels.WARN) end
    local architecture = choice

    -- 2. Select State Management
    -- UPDATED: Full list of state management options.
    vim.ui.select({ "BLoC", "Cubit", "Provider", "Riverpod", "GetX", "MobX" }, { prompt = "Select state management:" }, function(choice)
      if not choice then return utils.notify("Cancelled.", vim.log.levels.WARN) end
      local state_management = choice:lower()

      -- 3. Enter Feature Name
      vim.ui.input({ prompt = "Enter feature name (e.g., user_profile):" }, function(name)
        if not name or name == "" then return utils.notify("Feature name cannot be empty.", vim.log.levels.ERROR) end
        local feature_name = name:lower():gsub("%s+", "_"):gsub("[^%w_]", "")

        -- 4. Ask to create test files
        vim.ui.select({ "Yes", "No" }, { prompt = "Create test files?" }, function(choice)
          if choice == nil then return utils.notify("Cancelled.", vim.log.levels.WARN) end
          local create_test = (choice == "Yes")

          -- All information gathered, now call the generator.
          if architecture == "Clean Architecture" then
            generator.generate_clean_architecture(config, feature_name, state_management, create_test)
          else
            utils.notify(architecture .. " generation is not yet implemented.", vim.log.levels.WARN)
          end
        end)
      end)
    end)
  end)
end

return M

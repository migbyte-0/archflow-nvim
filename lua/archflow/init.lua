--------------------------------------------------------------------------------
-- File: generate_pattern.lua
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- Optional setup function for plugin initialization or user configuration
--------------------------------------------------------------------------------
function M.setup()
    -- You can put any plugin-wide initialization or user config defaults here.
    -- For now, we'll just provide a minimal example that prints a message.
    print("[ArchFlow] generate_pattern.lua loaded successfully.")
end

--------------------------------------------------------------------------------
-- Prompt the user for a design pattern/architecture and feature name.
--------------------------------------------------------------------------------
function M.prompt_pattern_and_feature()
    -- First, choose the pattern/architecture.
    local pattern_input = vim.fn.input(
        "Choose pattern:\n" ..
        "1) Clean Architecture\n" ..
        "2) MVC\n" ..
        "3) MVVM\n" ..
        "Enter choice (1/2/3): "
    )

    local chosen_pattern
    if pattern_input == "1" then
        chosen_pattern = "clean_architecture"
    elseif pattern_input == "2" then
        chosen_pattern = "mvc"
    elseif pattern_input == "3" then
        chosen_pattern = "mvvm"
    else
        print("Invalid choice")
        return
    end

    -- Prompt for state management choice only if we are using Clean Architecture
    local chosen_state_management = nil
    if chosen_pattern == "clean_architecture" then
        local state_choice = vim.fn.input("Choose state management (b for BLoC / c for Cubit): ")
        if state_choice:lower() == "b" then
            chosen_state_management = "BLoC"
        elseif state_choice:lower() == "c" then
            chosen_state_management = "Cubit"
        else
            print("Invalid choice for state management")
            return
        end
    end

    -- Now ask for the feature name.
    local feature_name = vim.fn.input("Enter feature name (without .dart): ")
    if feature_name == "" then
        print("Feature name cannot be empty")
        return
    end

    -- Determine the current working directory (root of your project).
    local base_path = vim.fn.getcwd()

    -- Generate files based on the chosen pattern (and optional state mgmt).
    if chosen_pattern == "clean_architecture" then
        M.generate_clean_architecture_files(base_path, feature_name, chosen_state_management)
    elseif chosen_pattern == "mvc" then
        M.generate_mvc_files(base_path, feature_name)
    elseif chosen_pattern == "mvvm" then
        M.generate_mvvm_files(base_path, feature_name)
    end
end

--------------------------------------------------------------------------------
-- CLEAN ARCHITECTURE (with optional BLoC or Cubit)
--------------------------------------------------------------------------------
function M.generate_clean_architecture_files(base_path, feature_name, state_management)
    -- We'll replicate the directory structure from your existing snippet:
    --   data/datasources
    --   data/models
    --   data/repositories
    --   domain/entities
    --   domain/usecases
    --   domain/repository_impl
    --   presentation/screens
    --   presentation/widgets
    --   presentation/blocs (if BLoC) OR presentation/cubits (if Cubit)

    local feature_base_path = base_path
        .. (string.match(base_path, "/lib$") and "/features" or "/lib/features")
        .. "/"
        .. feature_name

    -- Create the main feature folder if it doesn't exist
    os.execute("mkdir -p " .. feature_base_path)

    local camelCaseFeatureName = M.to_camel_case(feature_name)

    -- Directories for clean architecture
    local directories = {
        "data/datasources",
        "data/models",
        "data/repositories",
        "domain/entities",
        "domain/usecases",
        "domain/repository_impl",
        "presentation/screens",
        "presentation/widgets"
    }

    -- Append the appropriate folder for BLoC or Cubit
    if state_management == "BLoC" then
        table.insert(directories, "presentation/blocs")
    elseif state_management == "Cubit" then
        table.insert(directories, "presentation/cubits")
    end

    local export_files_content = {
        data = {},
        domain = {},
        presentation = {},
    }

    for _, dir in ipairs(directories) do
        local dir_path = feature_base_path .. "/" .. dir
        os.execute("mkdir -p " .. dir_path)

        -- If it's the BLoC or Cubit directory, create the specialized files
        if state_management == "BLoC" and dir:match("blocs") then
            M.create_bloc_files(dir_path, feature_name, camelCaseFeatureName, export_files_content.presentation)
        elseif state_management == "Cubit" and dir:match("cubits") then
            M.create_cubit_files(dir_path, feature_name, camelCaseFeatureName, export_files_content.presentation)
        else
            -- Create a placeholder file for each top-level subfolder
            local file_base_name = feature_name .. "_" .. dir:match("[^/]+$")
            local file_path = dir_path .. "/" .. file_base_name .. ".dart"
            local file_content = "// Placeholder for " .. file_base_name .. ".dart\n"
            M.create_file(file_path, file_content)

            -- We'll track the relative path for export
            local top_dir = dir:match("^[^/]+") -- 'data', 'domain', or 'presentation'
            local relative_path = "../" .. dir:gsub(".*/", "") .. "/" .. file_base_name .. ".dart"
            if export_files_content[top_dir] then
                table.insert(export_files_content[top_dir], relative_path)
            end
        end
    end

    -- Create the export files in data/, domain/, and presentation/ folders
    M.create_export_files(feature_base_path, export_files_content)

    print("Feature " .. feature_name .. " setup for Clean Architecture ("
        .. state_management .. ") completed.")
end

--------------------------------------------------------------------------------
-- Create BLoC files
--------------------------------------------------------------------------------
function M.create_bloc_files(dir_path, feature_name, camelCaseFeatureName, export_list)
    local bloc_file_path = dir_path .. "/" .. feature_name .. "_bloc.dart"
    local bloc_file_content = [[
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part ']] .. feature_name .. [[_event.dart';
part ']] .. feature_name .. [[_state.dart';

class ]] .. camelCaseFeatureName .. [[Bloc extends Bloc<]] .. camelCaseFeatureName .. [[Event, ]] .. camelCaseFeatureName .. [[State> {
  ]] .. camelCaseFeatureName .. [[Bloc() : super(]] .. camelCaseFeatureName .. [[Initial()) {
    on<]] .. camelCaseFeatureName .. [[Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]
    M.create_file(bloc_file_path, bloc_file_content)
    table.insert(export_list, "blocs/" .. feature_name .. "_bloc.dart")

    local event_file_path = dir_path .. "/" .. feature_name .. "_event.dart"
    local event_file_content = [[
part of ']] .. feature_name .. [[_bloc.dart';

abstract class ]] .. camelCaseFeatureName .. [[Event extends Equatable {
  const ]] .. camelCaseFeatureName .. [[Event();

  @override
  List<Object?> get props => [];
}
]]
    M.create_file(event_file_path, event_file_content)

    local state_file_path = dir_path .. "/" .. feature_name .. "_state.dart"
    local state_file_content = [[
part of ']] .. feature_name .. [[_bloc.dart';

abstract class ]] .. camelCaseFeatureName .. [[State extends Equatable {
  const ]] .. camelCaseFeatureName .. [[State();

  @override
  List<Object?> get props => [];
}

class ]] .. camelCaseFeatureName .. [[Initial extends ]] .. camelCaseFeatureName .. [[State {}
]]
    M.create_file(state_file_path, state_file_content)
end

--------------------------------------------------------------------------------
-- Create Cubit files
--------------------------------------------------------------------------------
function M.create_cubit_files(dir_path, feature_name, camelCaseFeatureName, export_list)
    local cubit_file_path = dir_path .. "/" .. feature_name .. "_cubit.dart"
    local cubit_file_content = [[
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
part ']] .. feature_name .. [[_state.dart';

class ]] .. camelCaseFeatureName .. [[Cubit extends Cubit<]] .. camelCaseFeatureName .. [[State> {
  ]] .. camelCaseFeatureName .. [[Cubit() : super(]] .. camelCaseFeatureName .. [[Initial());

  // Add your cubit methods here
}
]]
    M.create_file(cubit_file_path, cubit_file_content)
    table.insert(export_list, "cubits/" .. feature_name .. "_cubit.dart")

    local state_file_path = dir_path .. "/" .. feature_name .. "_state.dart"
    local state_file_content = [[
part of ']] .. feature_name .. [[_cubit.dart';

abstract class ]] .. camelCaseFeatureName .. [[State extends Equatable {
  const ]] .. camelCaseFeatureName .. [[State();

  @override
  List<Object?> get props => [];
}

class ]] .. camelCaseFeatureName .. [[Initial extends ]] .. camelCaseFeatureName .. [[State {}
]]
    M.create_file(state_file_path, state_file_content)
end

--------------------------------------------------------------------------------
-- Create export files for 'data', 'domain', 'presentation' directories
--------------------------------------------------------------------------------
function M.create_export_files(feature_base_path, export_files_content)
    for main_dir, files in pairs(export_files_content) do
        if #files > 0 then
            local export_file_path = feature_base_path .. "/" .. main_dir .. "/" .. main_dir .. "_exports.dart"
            local export_file_content = ""
            for _, relative_path in ipairs(files) do
                export_file_content = export_file_content .. "export '" .. relative_path .. "';\n"
            end
            M.create_file(export_file_path, export_file_content)
        end
    end
end

--------------------------------------------------------------------------------
-- MVC
--------------------------------------------------------------------------------
function M.generate_mvc_files(base_path, feature_name)
    -- Basic MVC approach typically includes:
    --   models/
    --   views/
    --   controllers/

    local feature_base_path = base_path
        .. (string.match(base_path, "/lib$") and "/features" or "/lib/features")
        .. "/"
        .. feature_name

    os.execute("mkdir -p " .. feature_base_path)

    local directories = {
        "models",
        "views",
        "controllers",
    }

    for _, dir in ipairs(directories) do
        local dir_path = feature_base_path .. "/" .. dir
        os.execute("mkdir -p " .. dir_path)

        local file_base_name = feature_name .. "_" .. dir
        local file_path = dir_path .. "/" .. file_base_name .. ".dart"

        local file_content = [[
// Placeholder for MVC ]] .. dir .. [[ code.
// Add your ]] .. dir .. [[ logic here.
]]

        M.create_file(file_path, file_content)
    end

    print("Feature " .. feature_name .. " setup for MVC completed.")
end

--------------------------------------------------------------------------------
-- MVVM
--------------------------------------------------------------------------------
function M.generate_mvvm_files(base_path, feature_name)
    -- Basic MVVM approach typically includes:
    --   models/
    --   views/
    --   viewmodels/

    local feature_base_path = base_path
        .. (string.match(base_path, "/lib$") and "/features" or "/lib/features")
        .. "/"
        .. feature_name

    os.execute("mkdir -p " .. feature_base_path)

    local directories = {
        "models",
        "views",
        "viewmodels",
    }

    for _, dir in ipairs(directories) do
        local dir_path = feature_base_path .. "/" .. dir
        os.execute("mkdir -p " .. dir_path)

        local file_base_name = feature_name .. "_" .. dir
        local file_path = dir_path .. "/" .. file_base_name .. ".dart"

        local file_content = [[
// Placeholder for MVVM ]] .. dir .. [[ code.
// Add your ]] .. dir .. [[ logic here.
]]

        M.create_file(file_path, file_content)
    end

    print("Feature " .. feature_name .. " setup for MVVM completed.")
end

--------------------------------------------------------------------------------
-- Helper function to create a file with given content.
--------------------------------------------------------------------------------
function M.create_file(file_path, content)
    local file = io.open(file_path, "w")
    if file then
        file:write(content)
        file:close()
    else
        print("Failed to create file: " .. file_path)
    end
end

--------------------------------------------------------------------------------
-- Helper function to convert a string to "CamelCase"
-- e.g. "my_feature" -> "MyFeature"
--------------------------------------------------------------------------------
function M.to_camel_case(str)
    return (str:gsub("(%l)(%w*)", function(first, rest)
        return first:upper() .. rest
    end))
end

return M

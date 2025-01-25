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

local function generate_mvc_with_getx_files(feature_path, feature_name)
  -- Controller file
  local controller_file = feature_path .. "/controller/" .. feature_name .. "_controller.dart"
  local controller_content = [[
import 'package:get/get.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Controller extends GetxController {
  @override
  void onInit() {
    // Called when controller is created
    super.onInit();
  }

  @override
  void onReady() {
    // Called after widget is rendered on screen
    super.onReady();
  }

  @override
  void onClose() {
    // Called when controller is removed from memory
    super.onClose();
  }
}
]]
  create_file(controller_file, controller_content)

  -- Model file
  local model_file = feature_path .. "/model/" .. feature_name .. "_model.dart"
  local model_content = [[
class ]] .. feature_name:gsub("^%l", string.upper) .. [[Model {
  // Add model properties here
}
]]
  create_file(model_file, model_content)

  -- View file
  local view_file = feature_path .. "/view/" .. feature_name .. "_view.dart"
  local view_content = [[
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/]] .. feature_name .. [[_controller.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[View extends StatelessWidget {
  final controller = Get.put(]] .. feature_name:gsub("^%l", string.upper) .. [[Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(']] .. feature_name:gsub("^%l", string.upper) .. [[View'),
      ),
      body: Center(
        child: Text('Hello from ]] .. feature_name:gsub("^%l", string.upper) .. [[View'),
      ),
    );
  }
}
]]
  create_file(view_file, view_content)
end

local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  if architecture == "mvc" then
    local mvc_directories = { "model", "view", "controller" }
    for _, dir in ipairs(mvc_directories) do
      create_directory(feature_path .. "/" .. dir)
    end

    -- Generate boilerplate files for MVC with GetX
    if state_management == "getx" then
      generate_mvc_with_getx_files(feature_path, feature_name)
    end
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

  -- Handle additional state management logic only for non-MVC architectures
  if architecture ~= "mvc" then
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
    end
  end
end

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  -- Prompt for architecture
  local architecture_choice = vim.fn.input("Select architecture (m: mvc, v: mvvm, c: clean): ")
  local architecture_map = { m = "mvc", v = "mvvm", c = "clean" }
  local architecture = architecture_map[architecture_choice]
  if not architecture then
    print("Invalid architecture selection.")
    return
  end

  -- Prompt for state management
  local state_choice = vim.fn.input("Select state management (p: provider, b: bloc, r: riverpod, g: getx): ")
  local state_map = { p = "provider", b = "bloc", r = "riverpod", g = "getx" }
  local state_management = state_map[state_choice]
  if not state_management then
    print("Invalid state management selection.")
    return
  end

  -- Prompt for feature name
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

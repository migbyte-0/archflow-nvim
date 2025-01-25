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

-- Boilerplate for Riverpod
local function generate_mvc_with_riverpod_files(feature_path, feature_name)
  local provider_file = feature_path .. "/controller/" .. feature_name .. "_provider.dart"
  local provider_content = [[
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[State {
  final String message;
  ]] .. feature_name:gsub("^%l", string.upper) .. [[State({this.message = ''});

  ]] .. feature_name:gsub("^%l", string.upper) .. [[State copyWith({String? message}) {
    return ]] .. feature_name:gsub("^%l", string.upper) .. [[State(
      message: message ?? this.message,
    );
  }
}

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Notifier extends StateNotifier<]] .. feature_name:gsub("^%l", string.upper) .. [[State> {
  ]] .. feature_name:gsub("^%l", string.upper) .. [[Notifier() : super(]] .. feature_name:gsub("^%l", string.upper) .. [[State());

  void updateMessage(String newMessage) {
    state = state.copyWith(message: newMessage);
  }
}

final ]] .. feature_name .. [[Provider = StateNotifierProvider<]] .. feature_name:gsub("^%l", string.upper) .. [[Notifier, ]] .. feature_name:gsub("^%l", string.upper) .. [[State>(
  (ref) => ]] .. feature_name:gsub("^%l", string.upper) .. [[Notifier(),
);
]]
  create_file(provider_file, provider_content)
end

-- Boilerplate for GetX
local function generate_mvc_with_getx_files(feature_path, feature_name)
  local controller_file = feature_path .. "/controller/" .. feature_name .. "_controller.dart"
  local controller_content = [[
import 'package:get/get.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Controller extends GetxController {
  var message = ''.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void updateMessage(String newMessage) {
    message.value = newMessage;
  }
}
]]
  create_file(controller_file, controller_content)
end

-- Generic MVC Files
local function generate_mvc_files(feature_path, feature_name, state_management)
  local model_file = feature_path .. "/model/" .. feature_name .. "_model.dart"
  local model_content = [[
class ]] .. feature_name:gsub("^%l", string.upper) .. [[Model {
  // Add model properties here
}
]]
  create_file(model_file, model_content)

  local view_file = feature_path .. "/view/" .. feature_name .. "_view.dart"
  local view_content = [[
import 'package:flutter/material.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[View extends StatelessWidget {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(']] .. feature_name:gsub("^%l", string.upper) .. [[ View'),
      ),
      body: Center(
        child: const Text('Welcome to ]] .. feature_name:gsub("^%l", string.upper) .. [[ View'),
      ),
    );
  }
}
]]
  create_file(view_file, view_content)

  -- Generate State Management Files
  if state_management == "riverpod" then
    generate_mvc_with_riverpod_files(feature_path, feature_name)
  elseif state_management == "getx" then
    generate_mvc_with_getx_files(feature_path, feature_name)
  end
end

-- Boilerplate for MVVM
local function generate_mvvm_files(feature_path, feature_name)
  local model_file = feature_path .. "/model/" .. feature_name .. "_model.dart"
  local view_file = feature_path .. "/view/" .. feature_name .. "_view.dart"
  local viewmodel_file = feature_path .. "/viewmodel/" .. feature_name .. "_viewmodel.dart"

  create_file(model_file, "// Model file for " .. feature_name)
  create_file(view_file, "// View file for " .. feature_name)
  create_file(viewmodel_file, "// ViewModel file for " .. feature_name)
end

-- Boilerplate for Clean Architecture
local function generate_clean_architecture_files(feature_path, feature_name)
  create_file(feature_path .. "/data/models/" .. feature_name .. "_model.dart", "// Data Model for " .. feature_name)
  create_file(feature_path .. "/domain/entities/" .. feature_name .. "_entity.dart", "// Domain Entity for " .. feature_name)
  create_file(feature_path .. "/presentation/widgets/" .. feature_name .. "_widget.dart", "// Presentation Widget for " .. feature_name)
end

-- Generate Architecture
local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  if architecture == "mvc" then
    create_directory(feature_path .. "/controller")
    create_directory(feature_path .. "/model")
    create_directory(feature_path .. "/view")
    generate_mvc_files(feature_path, feature_name, state_management)

  elseif architecture == "mvvm" then
    create_directory(feature_path .. "/model")
    create_directory(feature_path .. "/view")
    create_directory(feature_path .. "/viewmodel")
    generate_mvvm_files(feature_path, feature_name)

  elseif architecture == "clean" then
    create_directory(feature_path .. "/data/models")
    create_directory(feature_path .. "/domain/entities")
    create_directory(feature_path .. "/presentation/widgets")
    generate_clean_architecture_files(feature_path, feature_name)
  end
end

-- Generate Feature
function M.generate_feature()
  local base_path = vim.fn.getcwd()

  local architecture_choice = vim.fn.input("Select architecture (m: mvc, v: mvvm, c: clean): ")
  local architecture_map = { m = "mvc", v = "mvvm", c = "clean" }
  local architecture = architecture_map[architecture_choice]
  if not architecture then
    print("Invalid architecture selection.")
    return
  end

  local state_choice = vim.fn.input("Select state management (p: provider, b: bloc, r: riverpod, g: getx, c: cubit): ")
  local state_map = { p = "provider", b = "bloc", r = "riverpod", g = "getx", c = "cubit" }
  local state_management = state_map[state_choice]
  if not state_management and architecture == "mvc" then
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
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

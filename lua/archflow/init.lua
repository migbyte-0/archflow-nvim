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

-- Provider Boilerplate
local function generate_provider_files(feature_path, feature_name)
  local provider_file = feature_path .. "/controller/" .. feature_name .. "_provider.dart"
  local provider_content = [[
import 'package:flutter/material.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Provider extends ChangeNotifier {
  String _name = 'Default Name';

  String get name => _name;

  set name(String newName) {
    _name = newName;
    notifyListeners();
  }
}
]]
  create_file(provider_file, provider_content)
end

-- Bloc Boilerplate
local function generate_bloc_files(feature_path, feature_name)
  local bloc_file = feature_path .. "/controller/" .. feature_name .. "_bloc.dart"
  local bloc_content = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part ']] .. feature_name .. [[_event.dart';
part ']] .. feature_name .. [[_state.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Bloc extends Bloc<]] .. feature_name:gsub("^%l", string.upper) .. [[Event, ]] .. feature_name:gsub("^%l", string.upper) .. [[State> {
  ]] .. feature_name:gsub("^%l", string.upper) .. [[Bloc() : super(const ]] .. feature_name:gsub("^%l", string.upper) .. [[State()) {
    on<ExampleEvent>(_mapExampleEventToState);
  }

  void _mapExampleEventToState(ExampleEvent event, Emitter<]] .. feature_name:gsub("^%l", string.upper) .. [[State> emit) {
    emit(state.copyWith(message: "Handled ExampleEvent"));
  }
}
]]
  create_file(bloc_file, bloc_content)
end

-- Cubit Boilerplate
local function generate_cubit_files(feature_path, feature_name)
  local cubit_file = feature_path .. "/controller/" .. feature_name .. "_cubit.dart"
  local cubit_content = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part ']] .. feature_name .. [[_state.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Cubit extends Cubit<]] .. feature_name:gsub("^%l", string.upper) .. [[State> {
  ]] .. feature_name:gsub("^%l", string.upper) .. [[Cubit() : super(const ]] .. feature_name:gsub("^%l", string.upper) .. [[State());

  void exampleFunction() {
    emit(state.copyWith(message: "Example function called"));
  }
}
]]
  create_file(cubit_file, cubit_content)
end

-- Riverpod Boilerplate
local function generate_riverpod_files(feature_path, feature_name)
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

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Provider extends StateNotifier<]] .. feature_name:gsub("^%l", string.upper) .. [[State> {
  ]] .. feature_name:gsub("^%l", string.upper) .. [[Provider() : super(]] .. feature_name:gsub("^%l", string.upper) .. [[State());

  void updateMessage(String newMessage) {
    state = state.copyWith(message: newMessage);
  }
}

final ]] .. feature_name .. [[Provider = StateNotifierProvider<]] .. feature_name:gsub("^%l", string.upper) .. [[Provider, ]] .. feature_name:gsub("^%l", string.upper) .. [[State>(
  (ref) => ]] .. feature_name:gsub("^%l", string.upper) .. [[Provider(),
);
]]
  create_file(provider_file, provider_content)
end

-- GetX Boilerplate
local function generate_getx_files(feature_path, feature_name)
  local controller_file = feature_path .. "/controller/" .. feature_name .. "_controller.dart"
  local controller_content = [[
import 'package:get/get.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
]]
  create_file(controller_file, controller_content)
end

-- Model and View (Generic for All)
local function generate_model_and_view_files(feature_path, feature_name)
  local model_file = feature_path .. "/model/" .. feature_name .. "_model.dart"
  local model_content = [[
class ]] .. feature_name:gsub("^%l", string.upper) .. [[Model {
  // Add your model properties and methods here
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
end

-- Generate Architecture
local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  -- Common Directories
  local mvc_directories = { "model", "view", "controller" }
  for _, dir in ipairs(mvc_directories) do
    create_directory(feature_path .. "/" .. dir)
  end

  -- Generate Files
  generate_model_and_view_files(feature_path, feature_name)

  if state_management == "provider" then
    generate_provider_files(feature_path, feature_name)
  elseif state_management == "bloc" then
    generate_bloc_files(feature_path, feature_name)
  elseif state_management == "cubit" then
    generate_cubit_files(feature_path, feature_name)
  elseif state_management == "riverpod" then
    generate_riverpod_files(feature_path, feature_name)
  elseif state_management == "getx" then
    generate_getx_files(feature_path, feature_name)
  end
end

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  -- Prompt for architecture
  local architecture_choice = vim.fn.input("Select architecture (m: mvc): ")
  if architecture_choice ~= "m" then
    print("Only MVC architecture supported.")
    return
  end

  -- Prompt for state management
  local state_choice = vim.fn.input("Select state management (p: provider, b: bloc, r: riverpod, g: getx, c: cubit): ")
  local state_management = ({ p = "provider", b = "bloc", r = "riverpod", g = "getx", c = "cubit" })[state_choice]
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

  generate_architecture_structure(base_path, feature_name, "mvc", state_management)
  print("Feature " .. feature_name .. " generated with MVC and " .. state_management .. ".")
end

function M.setup()
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

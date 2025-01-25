local M = {}

-- Utility functions for directory and file creation
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

-- Generate files dynamically based on architecture and state management
local function generate_clean_architecture_files(base_path, feature_name, state_management)
  local directories = {
    "data/datasources",
    "data/models",
    "data/repositories",
    "domain/entities",
    "domain/usecases",
    "presentation/screens",
    "presentation/widgets",
    "presentation/" .. (state_management == "bloc" and "blocs" or state_management .. "s"),
  }

  for _, dir in ipairs(directories) do
    create_directory(base_path .. "/" .. dir)
  end

  -- Generate files with boilerplate code
  if state_management == "bloc" then
    M.create_bloc_files(base_path .. "/presentation/blocs", feature_name)
  elseif state_management == "cubit" then
    M.create_cubit_files(base_path .. "/presentation/cubits", feature_name)
  elseif state_management == "provider" then
    M.create_provider_files(base_path .. "/presentation/providers", feature_name)
  elseif state_management == "getx" then
    M.create_getx_files(base_path .. "/presentation/getxs", feature_name)
  elseif state_management == "riverpod" then
    M.create_riverpod_files(base_path .. "/presentation/providers", feature_name)
  end
end

local function generate_mvc_or_mvvm_files(base_path, feature_name, architecture, state_management)
  local architecture_map = {
    mvc = { "model", "view", "controller" },
    mvvm = { "model", "view", "viewmodel" },
  }

  local directories = architecture_map[architecture]
  for _, dir in ipairs(directories) do
    create_directory(base_path .. "/" .. dir)
  end

  -- Generate state management specific files
  if state_management == "bloc" then
    M.create_bloc_files(base_path .. "/controller", feature_name)
  elseif state_management == "cubit" then
    M.create_cubit_files(base_path .. "/controller", feature_name)
  elseif state_management == "provider" then
    M.create_provider_files(base_path .. "/controller", feature_name)
  elseif state_management == "getx" then
    M.create_getx_files(base_path .. "/controller", feature_name)
  elseif state_management == "riverpod" then
    M.create_riverpod_files(base_path .. "/controller", feature_name)
  end
end

function M.create_bloc_files(path, feature_name)
  local bloc_file = path .. "/" .. feature_name .. "_bloc.dart"
  local event_file = path .. "/" .. feature_name .. "_event.dart"
  local state_file = path .. "/" .. feature_name .. "_state.dart"

  create_file(bloc_file, [[
import 'package:flutter_bloc/flutter_bloc.dart';
import ']] .. feature_name .. "_event.dart';
import '" .. feature_name .. "_state.dart';

class " .. feature_name:gsub("^%l", string.upper) .. "Bloc extends Bloc<" .. feature_name .. "Event, " .. feature_name .. "State> {
  " .. feature_name:gsub("^%l", string.upper) .. "Bloc() : super(" .. feature_name:gsub("^%l", string.upper) .. "Initial());
}
]])

  create_file(event_file, [[
part of ']] .. feature_name .. "_bloc.dart';

abstract class " .. feature_name:gsub("^%l", string.upper) .. "Event {}
]])

  create_file(state_file, [[
part of ']] .. feature_name .. "_bloc.dart';

abstract class " .. feature_name:gsub("^%l", string.upper) .. "State {}

class " .. feature_name:gsub("^%l", string.upper) .. "Initial extends " .. feature_name:gsub("^%l", string.upper) .. "State {}
]])
end

function M.create_cubit_files(path, feature_name)
  local cubit_file = path .. "/" .. feature_name .. "_cubit.dart"
  local state_file = path .. "/" .. feature_name .. "_state.dart"

  create_file(cubit_file, [[
import 'package:flutter_bloc/flutter_bloc.dart';
import ']] .. feature_name .. "_state.dart';

class " .. feature_name:gsub("^%l", string.upper) .. "Cubit extends Cubit<" .. feature_name:gsub("^%l", string.upper) .. "State> {
  " .. feature_name:gsub("^%l", string.upper) .. "Cubit() : super(" .. feature_name:gsub("^%l", string.upper) .. "Initial());
}
]])

  create_file(state_file, [[
abstract class " .. feature_name:gsub("^%l", string.upper) .. "State {}

class " .. feature_name:gsub("^%l", string.upper) .. "Initial extends " .. feature_name:gsub("^%l", string.upper) .. "State {}
]])
end

function M.create_provider_files(path, feature_name)
  local provider_file = path .. "/" .. feature_name .. "_provider.dart"

  create_file(provider_file, [[
import 'package:flutter/material.dart';

class " .. feature_name:gsub("^%l", string.upper) .. "Provider extends ChangeNotifier {
  String data = "Initial Data";

  void updateData(String newData) {
    data = newData;
    notifyListeners();
  }
}
]])
end

function M.create_getx_files(path, feature_name)
  local controller_file = path .. "/" .. feature_name .. "_controller.dart"

  create_file(controller_file, [[
import 'package:get/get.dart';

class " .. feature_name:gsub("^%l", string.upper) .. "Controller extends GetxController {
  var data = "Initial Data".obs;

  void updateData(String newData) {
    data.value = newData;
  }
}
]])
end

function M.create_riverpod_files(path, feature_name)
  local provider_file = path .. "/" .. feature_name .. "_provider.dart"

  create_file(provider_file, [[
import 'package:flutter_riverpod/flutter_riverpod.dart';

class " .. feature_name:gsub("^%l", string.upper) .. "Notifier extends StateNotifier<String> {
  " .. feature_name:gsub("^%l", string.upper) .. "Notifier() : super("Initial Data");

  void updateData(String newData) {
    state = newData;
  }
}

final " .. feature_name .. "Provider = StateNotifierProvider<" .. feature_name:gsub("^%l", string.upper) .. "Notifier, String>((ref) {
  return " .. feature_name:gsub("^%l", string.upper) .. "Notifier();
});
]])
end

function M.generate_feature()
  local base_path = vim.fn.getcwd()
  local architecture_choice = vim.fn.input("Choose architecture (mvc/mvvm/clean): ")
  local state_choice = vim.fn.input("Choose state management (bloc/cubit/provider/getx/riverpod): ")
  local feature_name = vim.fn.input("Enter feature name: ")

  if architecture_choice == "mvc" or architecture_choice == "mvvm" then
    generate_mvc_or_mvvm_files(base_path, feature_name, architecture_choice, state_choice)
  elseif architecture_choice == "clean" then
    generate_clean_architecture_files(base_path, feature_name, state_choice)
  else
    print("Invalid architecture choice")
  end

  print("Feature " .. feature_name .. " generated with " .. architecture_choice .. " and " .. state_choice .. ".")
end

function M.setup()
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

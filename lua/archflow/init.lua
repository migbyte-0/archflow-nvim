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

local function generate_boilerplate(feature_path, feature_name, boilerplates)
  for file_name, content in pairs(boilerplates) do
    local file_path = feature_path .. "/" .. file_name
    create_file(file_path, content)
  end
end

local function get_boilerplate(feature_name, architecture, state_management)
  local class_name = feature_name:gsub("^%l", string.upper)
  local boilerplates = {}

  if architecture == "mvc" then
    -- Add MVC-specific boilerplates based on state management
    if state_management == "provider" then
      boilerplates["controller/" .. feature_name .. "_provider.dart"] = [[
import 'package:flutter/material.dart';

class ]] .. class_name .. [[Provider extends ChangeNotifier {
  String _message = 'Default Message';

  String get message => _message;

  void updateMessage(String newMessage) {
    _message = newMessage;
    notifyListeners();
  }
}
]]
    elseif state_management == "bloc" then
      boilerplates["controller/" .. feature_name .. "_bloc.dart"] = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part ']] .. feature_name .. [[_event.dart';
part ']] .. feature_name .. [[_state.dart';

class ]] .. class_name .. [[Bloc extends Bloc<]] .. class_name .. [[Event, ]] .. class_name .. [[State> {
  ]] .. class_name .. [[Bloc() : super(]] .. class_name .. [[Initial());

  @override
  Stream<]] .. class_name .. [[State> mapEventToState(]] .. class_name .. [[Event event) async* {
    // Add logic here
  }
}
]]

      boilerplates["controller/" .. feature_name .. "_event.dart"] = [[
part of ']] .. feature_name .. [[_bloc.dart';

abstract class ]] .. class_name .. [[Event extends Equatable {
  const ]] .. class_name .. [[Event();

  @override
  List<Object> get props => [];
}

class ]] .. class_name .. [[Started extends ]] .. class_name .. [[Event {}
]]

      boilerplates["controller/" .. feature_name .. "_state.dart"] = [[
part of ']] .. feature_name .. [[_bloc.dart';

enum ]] .. class_name .. [[Status { initial, loading, success, error }

class ]] .. class_name .. [[State extends Equatable {
  const ]] .. class_name .. [[State({
    this.status = ]] .. class_name .. [[Status.initial,
    this.message = '',
  });

  final ]] .. class_name .. [[Status status;
  final String message;

  ]] .. class_name .. [[State copyWith({
    ]] .. class_name .. [[Status? status,
    String? message,
  }) {
    return ]] .. class_name .. [[State(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
]]
    elseif state_management == "cubit" then
      boilerplates["controller/" .. feature_name .. "_cubit.dart"] = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part ']] .. feature_name .. [[_state.dart';

class ]] .. class_name .. [[Cubit extends Cubit<]] .. class_name .. [[State> {
  ]] .. class_name .. [[Cubit() : super(]] .. class_name .. [[Initial());

  void updateMessage(String message) {
    emit(]] .. class_name .. [[Updated(message));
  }
}
]]

      boilerplates["controller/" .. feature_name .. "_state.dart"] = [[
part of ']] .. feature_name .. [[_cubit.dart';

enum ]] .. class_name .. [[Status { initial, updated }

class ]] .. class_name .. [[State extends Equatable {
  const ]] .. class_name .. [[State({
    this.status = ]] .. class_name .. [[Status.initial,
    this.message = '',
  });

  final ]] .. class_name .. [[Status status;
  final String message;

  @override
  List<Object> get props => [status, message];
}

class ]] .. class_name .. [[Initial extends ]] .. class_name .. [[State {}

class ]] .. class_name .. [[Updated extends ]] .. class_name .. [[State {
  final String message;

  ]] .. class_name .. [[Updated(this.message) : super(status: ]] .. class_name .. [[Status.updated, message: message);

  @override
  List<Object> get props => [message];
}
]]
    elseif state_management == "riverpod" then
      boilerplates["controller/" .. feature_name .. "_provider.dart"] = [[
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ]] .. class_name .. [[Notifier extends StateNotifier<String> {
  ]] .. class_name .. [[Notifier() : super('Default Message');

  void updateMessage(String newMessage) {
    state = newMessage;
  }
}

final ]] .. feature_name .. [[Provider = StateNotifierProvider<]] .. class_name .. [[Notifier, String>((ref) => ]] .. class_name .. [[Notifier());
]]
    elseif state_management == "getx" then
      boilerplates["controller/" .. feature_name .. "_controller.dart"] = [[
import 'package:get/get.dart';

class ]] .. class_name .. [[Controller extends GetxController {
  var message = 'Default Message'.obs;

  void updateMessage(String newMessage) {
    message.value = newMessage;
  }
}
]]
    end

  elseif architecture == "mvvm" then
    boilerplates["viewmodel/" .. feature_name .. "_viewmodel.dart"] = [[
class ]] .. class_name .. [[ViewModel {
  // Add your view model logic here
}
]]
  end

  boilerplates["model/" .. feature_name .. "_model.dart"] = [[
class ]] .. class_name .. [[Model {
  // Add your model properties here
}
]]

  boilerplates["view/" .. feature_name .. "_view.dart"] = [[
import 'package:flutter/material.dart';

class ]] .. class_name .. [[View extends StatelessWidget {
  const ]] .. class_name .. [[View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(']] .. class_name .. [[ View'),
      ),
      body: Center(
        child: const Text('Welcome to ]] .. class_name .. [[ View'),
      ),
    );
  }
}
]]

  return boilerplates
end

local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  local directories = {
    mvc = { "model", "view", "controller" },
    mvvm = { "model", "view", "viewmodel" },
  }

  for _, dir in ipairs(directories[architecture]) do
    create_directory(feature_path .. "/" .. dir)
  end

  local boilerplates = get_boilerplate(feature_name, architecture, state_management)
  generate_boilerplate(feature_path, feature_name, boilerplates)
end

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  local architecture_choice = vim.fn.input("Select architecture (m: mvc, v: mvvm): ")
  local architecture_map = { m = "mvc", v = "mvvm" }
  local architecture = architecture_map[architecture_choice]
  if not architecture then
    print("Invalid architecture selection.")
    return
  end

  local state_choice = vim.fn.input("Select state management (p: provider, b: bloc, r: riverpod, g: getx, c: cubit): ")
  local state_map = { p = "provider", b = "bloc", r = "riverpod", g = "getx", c = "cubit" }
  local state_management = state_map[state_choice]
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
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

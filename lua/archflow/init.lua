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

local function generate_mvc_with_bloc_files(feature_path, feature_name)
  -- Bloc files
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

  -- Event file
  local event_file = feature_path .. "/controller/" .. feature_name .. "_event.dart"
  local event_content = [[
part of ']] .. feature_name .. [[_bloc.dart';

abstract class ]] .. feature_name:gsub("^%l", string.upper) .. [[Event extends Equatable {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[Event();

  @override
  List<Object?> get props => [];
}

class ExampleEvent extends ]] .. feature_name:gsub("^%l", string.upper) .. [[Event {}
]]
  create_file(event_file, event_content)

  -- State file
  local state_file = feature_path .. "/controller/" .. feature_name .. "_state.dart"
  local state_content = [[
part of ']] .. feature_name .. [[_bloc.dart';

enum ]] .. feature_name:gsub("^%l", string.upper) .. [[Status { initial, loading, success, error }

class ]] .. feature_name:gsub("^%l", string.upper) .. [[State extends Equatable {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[State({
    this.status = ]] .. feature_name:gsub("^%l", string.upper) .. [[Status.initial,
    this.message = '',
  });

  final ]] .. feature_name:gsub("^%l", string.upper) .. [[Status status;
  final String message;

  ]] .. feature_name:gsub("^%l", string.upper) .. [[State copyWith({
    ]] .. feature_name:gsub("^%l", string.upper) .. [[Status? status,
    String? message,
  }) {
    return ]] .. feature_name:gsub("^%l", string.upper) .. [[State(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
]]
  create_file(state_file, state_content)
end

local function generate_mvc_with_cubit_files(feature_path, feature_name)
  -- Cubit files
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

  -- State file
  local state_file = feature_path .. "/controller/" .. feature_name .. "_state.dart"
  local state_content = [[
part of ']] .. feature_name .. [[_cubit.dart';

enum ]] .. feature_name:gsub("^%l", string.upper) .. [[Status { initial, loading, success, error }

class ]] .. feature_name:gsub("^%l", string.upper) .. [[State extends Equatable {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[State({
    this.status = ]] .. feature_name:gsub("^%l", string.upper) .. [[Status.initial,
    this.message = '',
  });

  final ]] .. feature_name:gsub("^%l", string.upper) .. [[Status status;
  final String message;

  ]] .. feature_name:gsub("^%l", string.upper) .. [[State copyWith({
    ]] .. feature_name:gsub("^%l", string.upper) .. [[Status? status,
    String? message,
  }) {
    return ]] .. feature_name:gsub("^%l", string.upper) .. [[State(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
]]
  create_file(state_file, state_content)
end

local function generate_architecture_structure(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  if architecture == "mvc" then
    local mvc_directories = { "model", "view", "controller" }
    for _, dir in ipairs(mvc_directories) do
      create_directory(feature_path .. "/" .. dir)
    end

    if state_management == "bloc" then
      generate_mvc_with_bloc_files(feature_path, feature_name)
    elseif state_management == "cubit" then
      generate_mvc_with_cubit_files(feature_path, feature_name)
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
  local state_choice = vim.fn.input("Select state management (p: provider, b: bloc, r: riverpod, g: getx, c: cubit): ")
  local state_map = { p = "provider", b = "bloc", r = "riverpod", g = "getx", c = "cubit" }
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
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature" })
end

return M

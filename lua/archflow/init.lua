--------------------------------------------------------------------------------
-- File: archflow.lua
-- A single Lua module that merges MVC, MVVM, and Clean Architecture flows,
-- plus multiple state management options (Provider, BLoC, Riverpod, GetX, Cubit).
--------------------------------------------------------------------------------

local M = {}

--------------------------------------------------------------------------------
-- 1. HELPER FUNCTIONS
--------------------------------------------------------------------------------

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

--- Convert a string like "user_profile" -> "UserProfile".
local function to_camel_case(str)
  return str:gsub("(%l)(%w*)", function(a, b)
    return a:upper() .. b
  end)
end

--------------------------------------------------------------------------------
-- 2. MVC / MVVM GENERATION (old logic)
--------------------------------------------------------------------------------

--- Return a table of file_name -> file_content for MVC or MVVM
--- using the given state management approach.
local function get_boilerplate(feature_name, architecture, state_management)
  local class_name = to_camel_case(feature_name)
  local boilerplates = {}

  -- Common model/view placeholders
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

  if architecture == "mvc" then
    -- CREATE MVC-SPECIFIC FOLDERS (controller) & boilerplate
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
    -- CREATE MVVM-SPECIFIC FOLDERS (viewmodel) & minimal placeholders
    boilerplates["viewmodel/" .. feature_name .. "_viewmodel.dart"] = [[
class ]] .. class_name .. [[ViewModel {
  // Add your view model logic here
}
]]
    -- If desired, you can also combine the chosen state management inside MVVM
    -- but for brevity we keep a simple "ViewModel" placeholder.
  end

  return boilerplates
end

--- Actually creates the folder structure (for MVC or MVVM) and files
local function generate_mvc_mvvm_files(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  -- For simplicity, define the subfolders for each architecture:
  local directories_map = {
    mvc = { "model", "view", "controller" },
    mvvm = { "model", "view", "viewmodel" },
  }

  local subdirs = directories_map[architecture]
  if not subdirs then
    print("Unsupported architecture for MVC/MVVM flow: " .. (architecture or "nil"))
    return
  end

  for _, dir in ipairs(subdirs) do
    create_directory(feature_path .. "/" .. dir)
  end

  -- Grab the relevant boilerplate files
  local boilerplates = get_boilerplate(feature_name, architecture, state_management)
  -- Write them out
  for file_name, content in pairs(boilerplates) do
    local file_path = feature_path .. "/" .. file_name
    create_file(file_path, content)
  end

  print("Feature " .. feature_name .. " generated with " .. architecture
    .. " and " .. state_management .. ".")
end

--------------------------------------------------------------------------------
-- 3. CLEAN ARCHITECTURE GENERATION (the snippet you had)
--------------------------------------------------------------------------------

--- Create specialized BLoC files
local function create_bloc_files(dir_path, feature_name, camelCaseFeatureName, export_list)
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
  create_file(bloc_file_path, bloc_file_content)
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
  create_file(event_file_path, event_file_content)

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
  create_file(state_file_path, state_file_content)
end

--- Create specialized Cubit files
local function create_cubit_files(dir_path, feature_name, camelCaseFeatureName, export_list)
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
  create_file(cubit_file_path, cubit_file_content)
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
  create_file(state_file_path, state_file_content)
end

--- Create export files
local function create_export_files(feature_base_path, export_files_content)
  for main_dir, files in pairs(export_files_content) do
    if #files > 0 then
      local export_file_path = feature_base_path .. "/" .. main_dir .. "/" .. main_dir .. "_exports.dart"
      local export_file_content = ""
      for _, relative_path in ipairs(files) do
        export_file_content = export_file_content .. "export '" .. relative_path .. "';\n"
      end
      create_file(export_file_path, export_file_content)
    end
  end
end

--- Generate the full folder structure for Clean Architecture
local function generate_clean_architecture_files(base_path, feature_name, state_management)
  local feature_base_path = base_path
    .. (string.match(base_path, "/lib$") and "/features" or "/lib/features")
    .. "/"
    .. feature_name

  create_directory(feature_base_path)
  local camelCaseFeatureName = to_camel_case(feature_name)

  local directories = {
    "data/datasources",
    "data/models",
    "data/repositories",
    "domain/entities",
    "domain/usecases",
    "domain/repository_impl",
    "presentation/screens",
    "presentation/widgets",
  }

  -- If you want to support *all* state managements in Clean Arch, handle them here
  -- For example, if user picks "getx" or "riverpod", you can create placeholders or
  -- do specialized logic. For now, we handle BLoC or Cubit specifically:
  if state_management == "bloc" or state_management == "provider" or state_management == "riverpod"
     or state_management == "getx"
  then
    -- We'll treat them as "BLoC" in the folder name (or you can do separate getx/riverpod folder).
    table.insert(directories, "presentation/blocs")
  elseif state_management == "cubit" then
    table.insert(directories, "presentation/cubits")
  else
    -- fallback or error for unknown state mgmt
    table.insert(directories, "presentation/blocs")
  end

  local export_files_content = {
    data = {},
    domain = {},
    presentation = {},
  }

  for _, dir in ipairs(directories) do
    local dir_path = feature_base_path .. "/" .. dir
    create_directory(dir_path)

    if dir:match("blocs") then
      -- BLoC-like or "other" states in the same folder for demonstration
      create_bloc_files(dir_path, feature_name, camelCaseFeatureName, export_files_content.presentation)
      -- You could similarly create specialized files if user picks "provider" or "getx" etc.
      -- For demonstration, we reuse BLoC method if not Cubit.

    elseif dir:match("cubits") then
      create_cubit_files(dir_path, feature_name, camelCaseFeatureName, export_files_content.presentation)

    else
      local file_base_name = feature_name .. "_" .. dir:match("[^/]+$")
      local file_path = dir_path .. "/" .. file_base_name .. ".dart"
      local file_content = "// Placeholder for " .. file_base_name .. ".dart\n"
      create_file(file_path, file_content)

      local top_dir = dir:match("^[^/]+") -- 'data', 'domain', or 'presentation'
      local relative_path = "../" .. dir:gsub(".*/", "") .. "/" .. file_base_name .. ".dart"
      if export_files_content[top_dir] then
        table.insert(export_files_content[top_dir], relative_path)
      end
    end
  end

  create_export_files(feature_base_path, export_files_content)

  print("Feature " .. feature_name .. " generated under Clean Architecture ("
    .. state_management .. ")")
end

--------------------------------------------------------------------------------
-- 4. MAIN ENTRY FUNCTION
--------------------------------------------------------------------------------

--- Prompt user for architecture (MVC, MVVM, or Clean Arch) + state mgmt, then generate
function M.generate_feature()
  local base_path = vim.fn.getcwd()

  local arch_choice = vim.fn.input(
    "Select architecture (m: MVC, v: MVVM, c: Clean Architecture): "
  )
  local architecture_map = { m = "mvc", v = "mvvm", c = "clean_architecture" }
  local architecture = architecture_map[arch_choice]
  if not architecture then
    print("Invalid architecture selection.")
    return
  end

  local state_choice = vim.fn.input(
    "Select state management (p: provider, b: bloc, r: riverpod, g: getx, c: cubit): "
  )
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

  -- Now decide which approach to generate
  if architecture == "clean_architecture" then
    -- Use the Clean Architecture flow
    generate_clean_architecture_files(base_path, feature_name, state_management)
  else
    -- Use the old MVC/MVVM flow
    generate_mvc_mvvm_files(base_path, feature_name, architecture, state_management)
  end
end

--------------------------------------------------------------------------------
-- 5. SETUP FUNCTION (OPTIONAL)
--------------------------------------------------------------------------------

function M.setup()
  -- For example, bind <leader>af to generate a new feature
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature (ArchFlow)" })
end

return M

--------------------------------------------------------------------------------
-- File: archflow.lua
-- A single Lua module that merges:
--   1) MVC / MVVM flows with multiple state management (Provider, BLoC, Riverpod, GetX, Cubit)
--   2) Clean Architecture flow, also supporting all those state management choices
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

--- Convert snake_case or lowerCamelCase to UpperCamelCase
--- e.g. "my_feature" -> "MyFeature"
local function to_camel_case(str)
  return (str:gsub("(%l)(%w*)", function(a, b)
    return a:upper() .. b
  end))
end

--------------------------------------------------------------------------------
-- 2. STATE-MANAGEMENT-SPECIFIC HELPERS (BOILERPLATE)
--    We create separate functions to generate code for each approach
--    (Provider, BLoC, Cubit, Riverpod, GetX).
--    We can reuse them in both MVC/MVVM and Clean Architecture contexts.
--------------------------------------------------------------------------------

-- Provider
local function create_provider_file(dir_path, feature_name, class_name)
  local provider_file_path = dir_path .. "/" .. feature_name .. "_provider.dart"
  local provider_file_content = [[
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
  create_file(provider_file_path, provider_file_content)
end

-- BLoC
local function create_bloc_files(dir_path, feature_name, class_name)
  -- bloc dart
  local bloc_file_path = dir_path .. "/" .. feature_name .. "_bloc.dart"
  local bloc_file_content = [[
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part ']] .. feature_name .. [[_event.dart';
part ']] .. feature_name .. [[_state.dart';

class ]] .. class_name .. [[Bloc extends Bloc<]] .. class_name .. [[Event, ]] .. class_name .. [[State> {
  ]] .. class_name .. [[Bloc() : super(]] .. class_name .. [[Initial()) {
    on<]] .. class_name .. [[Event>((event, emit) {
      // TODO: implement event handler
    });
  }
}
]]
  create_file(bloc_file_path, bloc_file_content)

  -- event dart
  local event_file_path = dir_path .. "/" .. feature_name .. "_event.dart"
  local event_file_content = [[
part of ']] .. feature_name .. [[_bloc.dart';

abstract class ]] .. class_name .. [[Event extends Equatable {
  const ]] .. class_name .. [[Event();

  @override
  List<Object> get props => [];
}

class ]] .. class_name .. [[Started extends ]] .. class_name .. [[Event {}
]]
  create_file(event_file_path, event_file_content)

  -- state dart
  local state_file_path = dir_path .. "/" .. feature_name .. "_state.dart"
  local state_file_content = [[
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

class ]] .. class_name .. [[Initial extends ]] .. class_name .. [[State {}
]]
  create_file(state_file_path, state_file_content)
end

-- Cubit
local function create_cubit_files(dir_path, feature_name, class_name)
  local cubit_file_path = dir_path .. "/" .. feature_name .. "_cubit.dart"
  local cubit_file_content = [[
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
  create_file(cubit_file_path, cubit_file_content)

  local state_file_path = dir_path .. "/" .. feature_name .. "_state.dart"
  local state_file_content = [[
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
  create_file(state_file_path, state_file_content)
end

-- Riverpod
local function create_riverpod_file(dir_path, feature_name, class_name)
  local riverpod_file_path = dir_path .. "/" .. feature_name .. "_provider.dart"
  local riverpod_file_content = [[
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ]] .. class_name .. [[Notifier extends StateNotifier<String> {
  ]] .. class_name .. [[Notifier() : super('Default Message');

  void updateMessage(String newMessage) {
    state = newMessage;
  }
}

final ]] .. feature_name .. [[Provider = StateNotifierProvider<]] .. class_name .. [[Notifier, String>((ref) => ]] .. class_name .. [[Notifier());
]]
  create_file(riverpod_file_path, riverpod_file_content)
end

-- GetX
local function create_getx_file(dir_path, feature_name, class_name)
  local getx_file_path = dir_path .. "/" .. feature_name .. "_controller.dart"
  local getx_file_content = [[
import 'package:get/get.dart';

class ]] .. class_name .. [[Controller extends GetxController {
  var message = 'Default Message'.obs;

  void updateMessage(String newMessage) {
    message.value = newMessage;
  }
}
]]
  create_file(getx_file_path, getx_file_content)
end

--------------------------------------------------------------------------------
-- 3. MVC / MVVM GENERATION
--------------------------------------------------------------------------------

--- For MVC or MVVM, the "boilerplate" mostly resides in model/view + (controller or viewmodel).
--- Reuses the above state-management helpers for the "controller" portion, if needed (like BLoC).
local function generate_mvc_mvvm_files(base_path, feature_name, architecture, state_management)
  local feature_path = base_path .. "/lib/features/" .. feature_name
  create_directory(feature_path)

  local class_name = to_camel_case(feature_name)

  local directories_map = {
    mvc  = { "model", "view", "controller" },
    mvvm = { "model", "view", "viewmodel" },
  }

  local subdirs = directories_map[architecture]
  if not subdirs then
    print("Unsupported architecture: " .. tostring(architecture))
    return
  end

  -- Create subdirectories
  for _, dir in ipairs(subdirs) do
    create_directory(feature_path .. "/" .. dir)
  end

  -- Always create a model file
  create_file(feature_path .. "/model/" .. feature_name .. "_model.dart",
[[
class ]] .. class_name .. [[Model {
  // Add your model properties here
}
]]
  )

  -- Always create a view file
  create_file(feature_path .. "/view/" .. feature_name .. "_view.dart",
[[
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
  )

  -- If MVC, we have "controller" subfolder => generate the chosen state mgmt there
  if architecture == "mvc" then
    local controller_path = feature_path .. "/controller"
    if state_management == "provider" then
      create_provider_file(controller_path, feature_name, class_name)
    elseif state_management == "bloc" then
      create_bloc_files(controller_path, feature_name, class_name)
    elseif state_management == "cubit" then
      create_cubit_files(controller_path, feature_name, class_name)
    elseif state_management == "riverpod" then
      create_riverpod_file(controller_path, feature_name, class_name)
    elseif state_management == "getx" then
      create_getx_file(controller_path, feature_name, class_name)
    end
  end

  -- If MVVM, we have "viewmodel" subfolder => minimal example
  if architecture == "mvvm" then
    local viewmodel_path = feature_path .. "/viewmodel"
    -- For demonstration, we just create a single file.
    -- You could likewise add different state mgmt, but let's keep it minimal:
    create_file(viewmodel_path .. "/" .. feature_name .. "_viewmodel.dart",
[[
class ]] .. class_name .. [[ViewModel {
  // Add your view model logic here
}
]]
    )
    -- If you want to also incorporate state mgmt code in MVVM style,
    -- you'd similarly call the relevant creation function here
    -- (Provider, BLoC, etc.) but storing in "viewmodel" folder or another approach.
  end

  print("Feature " .. feature_name .. " generated with " .. architecture
    .. " + " .. state_management .. ".")
end

--------------------------------------------------------------------------------
-- 4. CLEAN ARCHITECTURE GENERATION
--------------------------------------------------------------------------------

--- We'll create subfolders for Clean Architecture:
--- data/datasources, data/models, data/repositories,
--- domain/entities, domain/usecases, domain/repository_impl,
--- presentation/screens, presentation/widgets,
--- + a subfolder for the chosen state management approach:
---   - "blocs" if user picks bloc
---   - "cubits" if user picks cubit
---   - "providers" if user picks provider
---   - "riverpods" if user picks riverpod
---   - "getx" if user picks getx
local function create_export_files(feature_base_path, export_files_content)
  for main_dir, files in pairs(export_files_content) do
    if #files > 0 then
      local export_file_path = feature_base_path .. "/" .. main_dir .. "/" .. main_dir .. "_exports.dart"
      local export_file_content = ""
      for _, rel_path in ipairs(files) do
        export_file_content = export_file_content .. "export '" .. rel_path .. "';\n"
      end
      create_file(export_file_path, export_file_content)
    end
  end
end

local function generate_clean_architecture_files(base_path, feature_name, state_management)
  local feature_base_path = base_path
    .. (string.match(base_path, "/lib$") and "/features" or "/lib/features")
    .. "/"
    .. feature_name

  create_directory(feature_base_path)

  local class_name = to_camel_case(feature_name)

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

  -- Decide the subfolder name for the chosen state management
  local folder_map = {
    bloc = "blocs",
    cubit = "cubits",
    provider = "providers",
    riverpod = "riverpods",
    getx = "getx",
  }
  local sm_folder = folder_map[state_management]
  if not sm_folder then
    sm_folder = "blocs"  -- fallback or handle error
  end
  table.insert(directories, "presentation/" .. sm_folder)

  local export_files_content = {
    data = {},
    domain = {},
    presentation = {},
  }

  for _, dir in ipairs(directories) do
    local dir_path = feature_base_path .. "/" .. dir
    create_directory(dir_path)

    -- If it's the dynamic subfolder for state management:
    if dir:match(sm_folder) then
      if state_management == "bloc" then
        create_bloc_files(dir_path, feature_name, class_name)
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_bloc.dart")
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_event.dart")
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_state.dart")

      elseif state_management == "cubit" then
        create_cubit_files(dir_path, feature_name, class_name)
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_cubit.dart")
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_state.dart")

      elseif state_management == "provider" then
        create_provider_file(dir_path, feature_name, class_name)
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_provider.dart")

      elseif state_management == "riverpod" then
        create_riverpod_file(dir_path, feature_name, class_name)
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_provider.dart")

      elseif state_management == "getx" then
        create_getx_file(dir_path, feature_name, class_name)
        table.insert(export_files_content.presentation, sm_folder .. "/" .. feature_name .. "_controller.dart")
      end

    else
      -- Create a placeholder .dart file
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

  -- create export files
  create_export_files(feature_base_path, export_files_content)

  print("Feature " .. feature_name .. " generated under Clean Architecture + " .. state_management)
end

--------------------------------------------------------------------------------
-- 5. MAIN ENTRY FUNCTION
--------------------------------------------------------------------------------

function M.generate_feature()
  local base_path = vim.fn.getcwd()

  local arch_choice = vim.fn.input("Select architecture (m: MVC, v: MVVM, c: Clean Architecture): ")
  local architecture_map = { m = "mvc", v = "mvvm", c = "clean_architecture" }
  local architecture = architecture_map[arch_choice]
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

  if architecture == "clean_architecture" then
    generate_clean_architecture_files(base_path, feature_name, state_management)
  else
    generate_mvc_mvvm_files(base_path, feature_name, architecture, state_management)
  end
end

--------------------------------------------------------------------------------
-- 6. SETUP FUNCTION (OPTIONAL BINDING)
--------------------------------------------------------------------------------

function M.setup()
  vim.keymap.set("n", "<leader>af", M.generate_feature, { desc = "Generate Flutter feature (ArchFlow)" })
end

return M

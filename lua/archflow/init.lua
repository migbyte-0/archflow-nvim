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

local function generate_mvc_with_riverpod_files(feature_path, feature_name)
  -- Riverpod Provider file
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

  -- Model file
  local model_file = feature_path .. "/model/" .. feature_name .. "_model.dart"
  local model_content = [[
class ]] .. feature_name:gsub("^%l", string.upper) .. [[Model {
  // Add your model properties and methods here
}
]]
  create_file(model_file, model_content)

  -- View file
  local view_file = feature_path .. "/view/" .. feature_name .. "_view.dart"
  local view_content = [[
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/]] .. feature_name .. [[_provider.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[View extends ConsumerWidget {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(]] .. feature_name .. [[Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(']] .. feature_name:gsub("^%l", string.upper) .. [[ View'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.message.isNotEmpty)
            Text(
              state.message,
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),
          ElevatedButton(
            onPressed: () {
              ref.read(]] .. feature_name .. [[Provider.notifier).updateMessage('Hello from Riverpod!');
            },
            child: const Text('Update Message'),
          ),
        ],
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

    if state_management == "riverpod" then
      generate_mvc_with_riverpod_files(feature_path, feature_name)
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

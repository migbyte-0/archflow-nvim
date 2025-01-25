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

local function generate_mvc_with_provider_files(feature_path, feature_name)
  -- Provider file
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
import 'package:provider/provider.dart';
import '../controller/]] .. feature_name .. [[_provider.dart';

class ]] .. feature_name:gsub("^%l", string.upper) .. [[View extends StatelessWidget {
  const ]] .. feature_name:gsub("^%l", string.upper) .. [[View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<]] .. feature_name:gsub("^%l", string.upper) .. [[Provider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(']] .. feature_name:gsub("^%l", string.upper) .. [[ View'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Current Name: ${provider.name}',
            style: const TextStyle(fontSize: 20),
          ),
          ElevatedButton(
            onPressed: () {
              provider.name = 'Updated Name';
            },
            child: const Text('Update Name'),
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

    if state_management == "provider" then
      generate_mvc_with_provider_files(feature_path, feature_name)
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

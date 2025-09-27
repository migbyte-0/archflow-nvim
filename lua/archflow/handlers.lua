-- ~/.config/nvim/lua/local/archflow-nvim/lua/archflow/handlers.lua

local utils = require("archflow.utils")

local M = {}

local function create_directory(path)
  vim.fn.mkdir(path, "p")
end

local function create_file(path, content)
  vim.fn.writefile(vim.split(content, "\n"), path)
end

local function create_source_and_test(p)
  local source_content = utils.get_template(p.source_template)
  local rendered_source = utils.render_template(source_content, p.template_vars)
  create_file(p.base_path .. "/" .. p.template_vars.featureName .. p.source_suffix, rendered_source)

  if p.create_test then
    local test_content = utils.get_template(p.test_template)
    if test_content ~= "" then
      create_directory(p.test_base_path)
      local rendered_test = utils.render_template(test_content, p.template_vars)
      create_file(p.test_base_path .. "/" .. p.template_vars.featureName .. p.test_suffix, rendered_test)
    end
  end
end

function M.create_bloc_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "bloc/bloc", test_template = "bloc/bloc_test",
    source_suffix = "_bloc.dart", test_suffix = "_bloc_test.dart",
  })
  local event_content = utils.get_template("bloc/event")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_event.dart", utils.render_template(event_content, p.vars))
  local state_content = utils.get_template("bloc/state")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_state.dart", utils.render_template(state_content, p.vars))
  return {
    p.sm_folder .. "/" .. p.vars.featureName .. "_bloc.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_event.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_state.dart",
  }
end

function M.create_provider_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "provider/provider", test_template = "provider/provider_test",
    source_suffix = "_provider.dart", test_suffix = "_provider_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_provider.dart" }
end

function M.create_cubit_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "cubit/cubit", test_template = "cubit/cubit_test",
    source_suffix = "_cubit.dart", test_suffix = "_cubit_test.dart",
  })
  local state_content = utils.get_template("cubit/state")
  create_file(p.base_path .. "/" .. p.vars.featureName .. "_state.dart", utils.render_template(state_content, p.vars))
  return {
    p.sm_folder .. "/" .. p.vars.featureName .. "_cubit.dart",
    p.sm_folder .. "/" .. p.vars.featureName .. "_state.dart",
  }
end

function M.create_getx_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "getx/controller", test_template = "getx/controller_test",
    source_suffix = "_controller.dart", test_suffix = "_controller_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_controller.dart" }
end

function M.create_riverpod_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "riverpod/provider", test_template = "riverpod/provider_test",
    source_suffix = "_provider.dart", test_suffix = "_provider_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_provider.dart" }
end

function M.create_mobx_files(config, p)
  create_source_and_test({
    base_path = p.base_path, test_base_path = p.test_base_path,
    template_vars = p.vars, create_test = p.create_test,
    source_template = "mobx/store", test_template = "mobx/store_test",
    source_suffix = "_store.dart", test_suffix = "_store_test.dart",
  })
  return { p.sm_folder .. "/" .. p.vars.featureName .. "_store.dart" }
end

return M

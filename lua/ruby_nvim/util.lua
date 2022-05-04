-- util functions
local Job = require("plenary.job")
local Path = require("plenary.path")
local M = {}

-- local functions
local git_root = function(file)
  local path = Path:new(file)
  if path:exists() ~= true then
    return nil
  end

  local opts = {
    command = "git",
    args = {"rev-parse", "--show-toplevel"},
    cwd = path:parent().filename,
  }
  local job = Job:new(opts):sync()
  if job == nil then
    vim.notify("git not installed or not in a git repository", "error")
    return nil
  end

  return job[1]
end

local function get_methods(root)
  local keys = {}
  for node, name in root:iter_children() do
    if name == 'method' then
      table.insert(keys, node)
    end

    if node:child_count() > 0 then
      for _, child in pairs(get_methods(node)) do
        table.insert(keys, child)
      end
    end
  end
  return keys
end

local split_path = function(path)
  local matches = {}
  for match in (path .. Path.path.sep):gmatch("(.-)" .. Path.path.sep) do
    table.insert(matches, match)
  end
  return matches
end

local get_alternate = function(alternate_directory, alternate_name, context)
  context.path[1] = alternate_directory
  context.path[#context.path] = alternate_name
  return Path:new(context.git_root):joinpath(unpack(context.path))
end

local test_suffix = function(directory, regex)
  if regex then
    return "_" .. directory .. "%.rb$"
  end

  return "_" .. directory .. ".rb"
end

-- public functions
M.is_ruby = function(path)
  return path:exists() and string.match(path.filename, "%.rb$")
end

M.is_test = function(path)
  return string.match(path.filename, "_test%.rb$") or
           string.match(path.filename, "_spec%.rb$")
end

M.alternate = function(file_path)
  local path = Path:new(file_path)
  local git = git_root(path)
  path = path:make_relative(git)

  local parts = split_path(path)
  local base_name = parts[#parts]
  local context = {git_root = git_root(path), path = parts}

  local main_directories = {"app", "lib", ""}
  local test_directories = {"test", "spec"}
  local test_subdirectories = {nil, "lib"}

  for _, test_directory in pairs(test_directories) do
    local suffix_regex = test_suffix(test_directory, true)

    if string.match(base_name, suffix_regex) then
      local alternate, _ = string.gsub(base_name, suffix_regex, ".rb")

      for _, directory in pairs(main_directories) do
        local alternate = get_alternate(directory, alternate, context)
        if alternate:exists() then
          return alternate
        end
      end
    end
  end

  for _, directory in pairs(test_directories) do
    local suffix = test_suffix(directory)
    local new_name, _ = string.gsub(base_name, "%.rb$", suffix)

    for _, subdirectory in pairs(test_subdirectories) do
      if subdirectory ~= nil then
        directory = directory .. Path.path.sep .. subdirectory
      end

      local alternate = get_alternate(directory, new_name, context)
      if alternate:exists() then
        return alternate
      end
    end
  end
end

M.all_methods = function ()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, "ft")
  local tree = vim.treesitter.get_parser(bufnr, ft):parse()[1]
  local root = tree:root()
  return get_methods(root)
end

M.get_gem_name = function (node, bufnr)
  while node ~= nil do
    if node:type() == 'call' then
      local method = node:field('method')[1]
      local method_name = vim.treesitter.query.get_node_text(method, bufnr)
      if method_name == 'gem' then
        local method_args = node:field('arguments')[1] --that when using get_node_text has text 'aws-sdk-s3', '~> 1'
        local gem_node_with_quotes = method_args:child(0) -- that when using get_node_text has text 'aws-sdk-s3'
        local gem_node = gem_node_with_quotes:child(1) -- that when usin get_node_text has text aws-sdk-s3
        local gem_name = vim.treesitter.query.get_node_text(gem_node, bufnr)
        if gem_name ~= "'" then
          return gem_name
        end
      end
    end
    node = node:parent()
  end
end

M.get_method_relevant_to_cursor = function ()
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
  local previous_node = nil
  for _, node in pairs(M.all_methods()) do
    local node_line, _ = node:start()
    node_line = node_line + 1
    if cursor_line == node_line then
      return node
    end

    if cursor_line < node_line then
      return previous_node
    end

    previous_node = node
  end
end



return M

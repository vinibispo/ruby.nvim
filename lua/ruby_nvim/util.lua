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

return M

local plenary_dir = os.getenv("PLENARY_DIR") and os.getenv("PLENARY_DIR") or "/tmp/plenary.nvim"
if vim.fn.isdirectory(plenary_dir) == nil then
  print(vim.fn.system({"git", "clone", "https://github.com/nvim-lua/plenary.nvim", plenary_dir}))
end

vim.o.runtimepath = vim.o.runtimepath .. '.' .. plenary_dir

vim.cmd("runtime plugin/plenary.vim")
vim.cmd("runtime plugin/ruby.vim")
require("plenary.busted")


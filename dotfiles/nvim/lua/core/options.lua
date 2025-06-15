-- lua/core/options.lua

local opt = vim.opt -- Sshortcut for vim.opt

-- [[ Context ]]
opt.number = true         -- Show line numbers
opt.relativenumber = true -- Show relative line numbers
opt.cursorline = true     -- Highlight the current line
opt.signcolumn = 'yes'    -- Always show the signcolumn, otherwise it would shift the text
opt.scrolloff = 8         -- Minimum number of screen lines to keep above and below the cursor
opt.sidescrolloff = 8     -- Minimum number of screen columns to keep to the left and right of the cursor

-- [[ Look and Feel ]]
opt.termguicolors = true  -- Enable true color support in the terminal
opt.background = 'dark'   -- Use a dark background
opt.syntax = 'on'         -- Enable syntax highlighting

-- [[ Tabs and Indentation ]]
opt.tabstop = 2           -- Number of visual spaces per TAB
opt.softtabstop = 2       -- Number of spaces TAB counts for while editing
opt.shiftwidth = 2        -- Size of an indent
opt.expandtab = true      -- Use spaces instead of tabs
opt.autoindent = true     -- Copy indent from current line when starting new line
opt.smartindent = true    -- Makes indenting smart

-- [[ Search ]]
opt.ignorecase = true     -- Ignore case when searching
opt.smartcase = true      -- Don't ignore case if search pattern contains uppercase letters
opt.hlsearch = true       -- Highlight search results
opt.incsearch = true      -- Show search results incrementally

-- [[ Files, Backup, Swap ]]
opt.backup = false        -- No backup files
opt.writebackup = false   -- No backup files during write
opt.swapfile = false      -- No swap files
opt.undofile = true       -- Enable persistent undo
-- Create undo directory if it doesn't exist
local undodir = vim.fn.stdpath('data') .. '/undodir'
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, 'p')
end
opt.undodir = undodir

-- [[ Performance / Behavior ]]
opt.hidden = true         -- Allow hidden buffers
opt.shortmess:append('I') -- Disable startup message (keep your original)
opt.updatetime = 250      -- Faster completion triggering (default is 4000ms)
opt.timeoutlen = 500      -- Time to wait for a mapped sequence to complete (in ms)
opt.completeopt = 'menuone,noselect' -- Completion options

-- [[ Splitting ]]
opt.splitright = true     -- Vertical splits open to the right
opt.splitbelow = true     -- Horizontal splits open below

-- [[ Cursor ]]
-- Keep your cursor setting if you like it, or remove/comment if not needed
-- vim.opt.guicursor = "n-v-c:ver25-Cursor,i-ci-ve:ver25-Cursor"

-- Python Host Program (optional, Neovim often finds it automatically)
-- If you MUST specify, use vim.fn.executable to check if it exists
-- local python_path = '/home/febf/Utveckling/Python/venv/venv_py3.12/lsp_pynvim/bin/python'
-- if vim.fn.executable(python_path) == 1 then
--   vim.g.python3_host_prog = python_path
-- end

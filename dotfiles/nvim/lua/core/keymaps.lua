-- lua/core/keymaps.lua

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- [[ Navigation ]]
-- Move between windows
map('n', '<C-h>', '<C-w>h', { desc = 'Navigate Left Window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Navigate Down Window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Navigate Up Window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Navigate Right Window' })

-- Resize windows
map('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase window height' })
map('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease window height' })
map('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease window width' })
map('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase window width' })

-- Move lines up/down
map('n', '<A-j>', '<cmd>m .+1<cr>==', { desc = 'Move line down' })
map('n', '<A-k>', '<cmd>m .-2<cr>==', { desc = 'Move line up' })
map('v', '<A-j>', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('v', '<A-k>', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })

-- [[ Editing ]]
-- Stay in indent mode
map('v', '<', '<gv', { desc = 'Indent line left (visual)'})
map('v', '>', '>gv', { desc = 'Indent line right (visual)'})

-- Paste without losing yanked text
map('v', 'p', '"_dP', { desc = 'Paste without losing yank buffer (visual)'})

-- [[ Buffers / Files / Session ]]
map('n', '<leader>s', '<cmd>w<cr>', vim.tbl_extend('force', opts, { desc = 'Save file' }))
map('n', '<leader>q', '<cmd>q<cr>', vim.tbl_extend('force', opts, { desc = 'Quit Window' }))
map('n', '<leader>Q', '<cmd>qa!<cr>', vim.tbl_extend('force', opts, { desc = 'Quit All (Force)' }))
map('n', '<leader>bn', '<cmd>bnext<cr>', vim.tbl_extend('force', opts, { desc = 'Next buffer' }))
map('n', '<leader>bp', '<cmd>bprevious<cr>', vim.tbl_extend('force', opts, { desc = 'Previous buffer' }))
-- Note: :Bdelete usually requires a plugin like bufferline or fzf integrations
-- Use <cmd>bdelete<cr> for standard Neovim buffer delete
map('n', '<leader>bd', '<cmd>bdelete<cr>', vim.tbl_extend('force', opts, { desc = 'Delete buffer' }))

-- [[ Other ]]
-- Clear search highlights
map('n', '<leader><leader>h', '<cmd>nohlsearch<CR>', vim.tbl_extend('force', opts, { desc = 'Clear highlights' }))

-- REMOVED redundant mapping: <leader>fw was same as <leader>s
-- map('n', '<leader>fw', '<cmd>w<cr>', { desc = 'Save File (WhichKey)' })

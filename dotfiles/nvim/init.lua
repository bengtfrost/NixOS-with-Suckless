-- ~/.config/nvim/init.lua

-- Set leader key BEFORE loading plugins/keymaps
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- Optional: Set localleader as well

-- Load core configuration
require("core.options")
require("core.keymaps")

--[[ <<< REMOVE OR COMMENT OUT this line to use system python >>>
-- Tell Neovim which Python to use for the 'neovim' package (pynvim)
-- vim.g.python3_host_prog = '/home/febf/Utveckling/Python/venv/venv_py3.12/lsp_pynvim/bin/python'
-- By removing/commenting the line above, Neovim will search $PATH for python3
-- Ensure 'pynvim' is installed for the system python3 Neovim finds.
]]

-- [[ Install lazy.nvim package manager ]]
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- Ensure parent directory exists before cloning
  local parent_dir = vim.fn.fnamemodify(lazypath, ":h")
  if vim.fn.isdirectory(parent_dir) == 0 then
    vim.fn.mkdir(parent_dir, "p")
  end
  -- Clone lazy.nvim repository
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- Use 'main' for latest features, 'stable' for stability
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath) -- Add lazy.nvim to runtime path

-- [[ Configure and load plugins via lazy.nvim ]]
-- Tells lazy to load plugin specifications from lua/plugins/ directory
require("lazy").setup("plugins", {
  -- lazy.nvim configuration options (optional)
  checker = {
    enabled = true, -- Check for plugin updates automatically
    notify = false, -- Don't notify on check, just background check
  },
  change_detection = {
    enabled = true, -- Automatically check for config file changes
    notify = false, -- Automatically reload changes without notification
  },
  -- performance = { -- Optional performance tweaks
  --   rtp = {
  --     -- disable some standard plugins
  --     disabled_plugins = {
  --       "gzip",
  --       "matchit",
  --       "matchparen",
  --       "netrwPlugin",
  --       "tarPlugin",
  --       "tohtml",
  --       "tutor",
  --       "zipPlugin",
  --     },
  --   },
  -- },
})

-- [[ Disable Unused Default Providers ]]
-- Saves a tiny amount of startup time if you don't use these languages
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- [[ Diagnostics Configuration ]]
-- Configure how diagnostics (errors, warnings) are displayed
vim.diagnostic.config({
  virtual_text = true,     -- Show inline diagnostics text
  signs = true,            -- Show signs in the sign column
  underline = true,        -- Underline errors/warnings
  update_in_insert = false, -- Don't update diagnostics while typing in Insert mode
  severity_sort = true,    -- Sort diagnostics by severity
  float = {                -- Configuration for floating diagnostic window (vim.diagnostic.open_float)
    source = "always",     -- Show the source of the diagnostic (e.g., 'pyright')
    border = "rounded",    -- Style of the border
    -- delay = 250,             -- Optional: Delay before showing float (helps with lua_ls timing)
  },
})

-- Ensure sign column is always present to prevent text jitter
vim.opt.signcolumn = "yes:1" -- Use 'yes:1' for minimal width

-- [[ Auto Commands ]]

-- Highlight yanked text briefly
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = highlight_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({ timeout = 300 }) -- Highlight for 300ms
  end,
})

-- Auto-close NvimTree when it's the last window
local nvimtree_group = vim.api.nvim_create_augroup("NvimTreeClose", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
  group = nvimtree_group,
  callback = function()
    -- Check if window is valid before accessing buffer info
    if not vim.api.nvim_win_is_valid(0) then
      return
    end
    -- Check if only one window remains and it's NvimTree
    if #vim.api.nvim_list_wins() == 1 and vim.bo.filetype == "NvimTree" then
      local current_buf = vim.api.nvim_get_current_buf()
      -- Check if buffer is listed and is NvimTree type
      if vim.fn.bufexists(current_buf) == 1 and vim.bo[current_buf].filetype == "NvimTree" then
        -- Defer quit slightly to avoid race conditions
        vim.defer_fn(function()
          -- Check again before quitting, state might change rapidly
          if
              vim.api.nvim_win_is_valid(1)
              and #vim.api.nvim_list_wins() == 1
              and vim.bo[vim.api.nvim_win_get_buf(1)].filetype == "NvimTree"
          then
            vim.cmd.quit()
          end
        end, 50) -- Slightly longer delay might be safer
      end
    end
  end,
})

-- [[ Format on Save ]]
-- Conform.nvim handles format_on_save via its 'format_on_save' option
-- configured in lua/plugins/formatter.lua.
-- The manual autocommand below is NOT needed when using Conform's option.
--[[ -- Keep commented out or remove entirely
local format_group = vim.api.nvim_create_augroup('FormatOnSave', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_group,
  pattern = { '*.py', '*.js', '*.ts', '*.lua' }, -- Add filetypes Conform handles
  callback = function(args)
    -- This used LSP format, conform is now preferred
    -- vim.lsp.buf.format({ bufnr = args.buf, async = false, timeout_ms = 1000 })
    -- Conform handles this via format_on_save = { lsp_fallback = true }
  end,
})
]]

-- vim.cmd [[ command! Format execute 'lua require("conform").format({async=true, lsp_fallback=true})' ]] -- Optional global command

-- print("Neovim config loaded!") -- Keep commented out

-- lua/plugins/ui.lua
return {
  -- Icons - Load lazily as they are dependencies
  {
    'nvim-tree/nvim-web-devicons',
    lazy = true
  },

  -- File Explorer (NvimTree)
  {
    'nvim-tree/nvim-tree.lua',
    dependencies = {
      'nvim-tree/nvim-web-devicons' -- Specify dependency
    },
    -- Define the keymap here to trigger loading the plugin
    keys = {
      { "<leader>n", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
      -- You could add other NvimTree global keys here if needed, e.g.,
      -- { "<leader>nf", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in tree" },
    },
    -- Configuration function runs *after* the plugin is loaded
    config = function()
      require('nvim-tree').setup({
        -- Core behaviour
        disable_netrw = true, -- Disable netrw & related buffers
        hijack_netrw = true,  -- Hijack netrw targets opening NvimTree instead

        -- Filters for ignored files/folders
        filters = {
          dotfiles = false, -- Show dotfiles (like .git, .env)
          custom = { ".git", "node_modules", ".cache" }, -- Folders/files to hide
          exclude = {}, -- Regex patterns for files/folders to exclude
        },

        -- Git status integration
        git = {
          enable = true,
          ignore = false, -- Show files ignored by .gitignore?
          timeout = 400,  -- Timeout for git commands
        },

        -- View settings
        view = {
          width = 35,             -- Default width of the tree panel
          -- height = 30,         -- Default height (relevant for side='top'/'bottom')
          side = "left",          -- Position of the panel (left, right, top, bottom)
          preserve_window_proportions = true, -- Keep window sizes when opening files
          -- number = false,      -- Display line numbers?
          -- relativenumber = false, -- Display relative line numbers?
          signcolumn = "yes",     -- Always show the signcolumn space
        },

        -- File opening behaviour
        actions = {
          open_file = {
            quit_on_open = false, -- Close NvimTree panel when opening a file?
            resize_window = true, -- Resize NvimTree panel when opening a file?
            -- window_picker = { enable = true, exclude = { filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" }, buftype = { "nofile", "terminal", "prompt" } } },
          },
          -- change_dir = { enable = true, global = false, restrict_above_cwd = false },
        },

        -- Visual rendering options
        renderer = {
          -- group_empty = true, -- Show empty folders?
          -- highlight_git = false, -- Highlight git changes in the tree? (use gitsigns instead usually)
          -- highlight_opened_files = 'none', -- Options: 'none', 'icon', 'name', 'all'
          -- root_folder_modifier = ":~", -- Modifier for the root folder display

          -- Indentation markers
          indent_markers = {
            enable = true,
            -- icons = { corner = "└ ", edge = "│ ", item = "│ ", none = "  " }
          },

          -- Icons configuration (requires nvim-web-devicons)
          icons = {
            webdev_colors = true, -- Use devicons colors (if available)
            git_placement = "before", -- Show git icons before or after file icon
            padding = " ", -- Padding around icons
            symlink_arrow = " ➛ ", -- Arrow for symlinks
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
            glyphs = {
              default = "󰈚", -- Default file icon
              symlink = "",  -- Symlink icon
              folder = {
                default = "",    -- Default folder icon
                open = "",       -- Open folder icon
                empty = "󰜌",     -- Empty folder icon
                empty_open = "󰜌", -- Empty open folder icon (might need custom icon)
                symlink = "",    -- Symlinked folder icon
                symlink_open = "", -- Open symlinked folder icon
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "󰆴",
                ignored = "◌",
              },
            },
          },
        },

        -- Function to run when NvimTree buffer attaches (for buffer-local keymaps)
        on_attach = function(bufnr)
          local api = require('nvim-tree.api')
          local map = vim.keymap.set
          -- Options for NvimTree buffer maps: silent, noremap, buffer-local
          local opts = { buffer = bufnr, noremap = true, silent = true, nowait = true }

          -- Default mappings (can be overridden/removed)
          -- See :help nvim-tree-mappings

          -- Basic navigation (using h/l for consistency with Vim)
          map('n', 'h', api.node.navigate.parent_close, opts) -- Go up/close folder
          map('n', 'l', api.node.open.edit, opts)           -- Go down/open folder/file

          -- Other useful mappings (add/remove/customize as needed)
          map('n', '<CR>', api.node.open.edit, opts)         -- Open file/folder (same as l)
          map('n', 'o', api.node.open.edit, opts)           -- Open file/folder (same as l)
          map('n', '<2-LeftMouse>', api.node.open.edit, opts)-- Double click opens
          map('n', 'v', api.node.open.vertical, opts)       -- Open in vertical split
          map('n', 's', api.node.open.horizontal, opts)     -- Open in horizontal split (use different key if 's' conflicts)
          map('n', '<Tab>', api.node.open.preview, opts)      -- Open preview (doesn't close tree)
          map('n', 'a', api.fs.create, opts)                -- Add file/folder
          map('n', 'd', api.fs.remove, opts)                -- Delete file/folder (confirm)
          map('n', 'r', api.fs.rename, opts)                -- Rename
          map('n', 'x', api.fs.cut, opts)                   -- Cut
          map('n', 'c', api.fs.copy.node, opts)             -- Copy node
          map('n', 'p', api.fs.paste, opts)                 -- Paste
          map('n', 'y', api.fs.copy.filename, opts)         -- Copy filename
          map('n', 'Y', api.fs.copy.relative_path, opts)    -- Copy relative path
          map('n', 'gy', api.fs.copy.absolute_path, opts)   -- Copy absolute path
          map('n', '.', api.node.run.cmd, opts)             -- Run command on node (e.g. `.` then `chmod +x %`)
          map('n', '-', api.tree.change_root_to_parent, opts) -- Change tree root up one level
          map('n', 'H', api.tree.toggle_hidden_filter, opts)  -- Toggle hidden files filter
          map('n', 'I', api.tree.toggle_gitignore_filter, opts) -- Toggle gitignore filter
          map('n', 'R', api.tree.reload, opts)              -- Reload tree
          map('n', '?', api.tree.toggle_help, opts)          -- Show help
          map('n', 'q', api.tree.close, opts)               -- Close NvimTree window
        end,

        -- Other options: logs, diagnostics, update_focused_file, etc.
        -- log = { enable = false, truncate = false, types = { all = false, config = false, fs = false, git = false, view = false, } },
        -- diagnostics = { enable = false, show_on_dirs = false, icons = { hint = "💡", info = "", warning = "", error = "" } }

      })

      -- NOTE: The <leader>n keymap is now defined in the `keys` table above
      -- and does not need to be set here inside the config function.

    end, -- End of config function
  }, -- End of nvim-tree plugin spec
} -- End of return table

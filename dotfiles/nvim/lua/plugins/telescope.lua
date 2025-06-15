-- lua/plugins/telescope.lua (Recommended: Using Latest Stable Tag)
return {
  {
    'nvim-telescope/telescope.nvim',
    -- Use a specific release tag for stability
    tag = '0.1.8', -- Replace with the actual latest stable tag found on GitHub if needed
    -- branch = 'master', -- Commented out - use tag instead
    lazy = true, -- Keep lazy loading
    dependencies = {
      -- Plenary is essential
      'nvim-lua/plenary.nvim',
      -- Optional but recommended: FZF native sorter for performance
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- Build command for the native sorter
        build = 'make',
        -- Only load if 'make' is available
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
    -- Keymaps defined here for lazy-loading and discoverability
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>',  desc = '[F]ind [F]iles' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>',   desc = '[F]ind by [G]rep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',     desc = '[F]ind [B]uffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',   desc = '[F]ind [H]elp' },
      { '<leader>fo', '<cmd>Telescope oldfiles<cr>',    desc = '[F]ind [O]ld Files' },
      { '<leader>fr', '<cmd>Telescope resume<cr>',      desc = '[F]ind [R]esume' },
      { '<leader>fd', '<cmd>Telescope diagnostics<cr>', desc = '[F]ind [D]iagnostics' },
      -- Add other common Telescope commands if desired:
      -- { '<leader>fc', '<cmd>Telescope git_commits<cr>', desc = '[F]ind Git [C]ommits' },
      -- { '<leader>fs', '<cmd>Telescope git_status<cr>',  desc = '[F]ind Git [S]tatus' },
    },
    -- Configuration function runs after the plugin is loaded
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          -- General defaults
          prompt_prefix = " ", -- Nerd Font search icon
          selection_caret = " ", -- Nerd Font caret icon
          -- Path display settings can be useful
          -- path_display = { "truncate" },
          -- Layout strategy
          layout_strategy = 'horizontal',
          layout_config = {
            horizontal = { preview_width = 0.55 },
            vertical = { mirror = false },
          },
          -- Sorting settings
          sorting_strategy = "ascending",
          -- File previewer (requires 'bat' or 'cat')
          -- file_previewer = require('telescope.previewers').vim_buffer_cat.new,
          -- grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
          -- qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
          -- Ignore patterns
          file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "%.lock",
            "__pycache__/",
            "%.ipynb", -- Common Python notebook extension
            "%.o", "%.a", "%.out", "%.class", -- Compiled object files
          },
        },
        pickers = {
          -- Configuration for specific pickers, e.g., find_files
          find_files = {
            -- theme = "dropdown", -- Example theme
            -- find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" }, -- Example using ripgrep
          },
          live_grep = {
            -- Additional arguments for rg might be needed
            -- additional_args = function(opts) return {"--hidden"} end
          },
          buffers = {
            -- theme = "dropdown",
            -- sort_mru = true,
          },
          -- Configure other pickers as needed
        },
        extensions = {
          -- Configuration for extensions like fzf
          fzf = {
            fuzzy = true,                    -- Enable fuzzy finding
            override_generic_sorter = true,  -- Override the generic sorter
            override_file_sorter = true,     -- Override the file sorter
            case_mode = "smart_case",        -- Smart case sensitivity
          },
          -- Configure other extensions if loaded
        },
      })

      -- Load extensions after setup
      -- Ensures fzf integration works if fzf-native is installed and built
      pcall(telescope.load_extension, 'fzf')
      -- Load other extensions here, e.g.:
      -- pcall(telescope.load_extension, 'media_files')
    end, -- End config function
  }, -- End telescope spec
} -- End return

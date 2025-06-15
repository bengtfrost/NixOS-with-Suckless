-- lua/plugins/utils.lua 
return {
  -- WhichKey: Displays a popup with available keybindings
  {
    'folke/which-key.nvim',
    event = "VeryLazy", -- Load lazily when needed (typically on first <leader> press)
    dependencies = { 'echasnovski/mini.icons' }, -- Add dependency if icons or plugins section use them
    config = function()
      -- print("WhichKey: Attempting setup...") -- Keep commented
      local wk_ok, wk = pcall(require, "which-key")
      if not wk_ok then
        vim.notify("Failed to load which-key", vim.log.levels.ERROR)
        return
      end

      -- Setup WhichKey using options that were confirmed working.
      -- Specific 'win' options are commented out below as they caused
      -- the popup to fail rendering in the Sway/Foot environment during debugging.
      local setup_ok, err = pcall(wk.setup, {
        -- Options that worked reliably:
        plugins = {
          marks = true,      -- Enable showing marks on ' and `
          registers = true,  -- Enable showing registers on " or <C-r>
          spelling = {
            enabled = true,     -- Enable spelling suggestions
            suggestions = 20,   -- Limit number of suggestions
          },
        },
        icons = {
          breadcrumb = "»", -- Indicator for key sequence
          separator = "➜",  -- Separator between key and description
          group = "+",      -- Prefix for mapping groups (e.g., +File)
        },
        layout = {
          height = { min = 4, max = 25 }, -- Min/max height of the popup
          width = { min = 20, max = 50 },  -- Min/max width of the popup
          spacing = 3,                     -- Space between columns
          align = "left",                  -- Align content to the left
        },

        -- 'win' options section: Customize window appearance
        -- NOTE: Some options below caused issues on Sway/Foot. Test cautiously if uncommenting.
        win = {
          border = "rounded",      -- Border style. This *might* be okay alone.
          -- position = "bottom",     -- This caused the popup to fail. Do not uncomment unless tested thoroughly.
          -- margin = { 1, 0, 1, 0 }, -- This caused failure, likely related to position calculation.
          padding = { 1, 2, 1, 2 }, -- Padding inside border. This seemed okay. Can uncomment.
          -- winblend = 0,            -- Transparency. This caused failure.
        },

        -- Other WhichKey options can be added here if needed, e.g.,
        -- ignore_missing = true, -- Hide mappings without descriptions
        -- triggers = "auto", -- Default trigger behavior (on <leader>, etc.)

      }) -- End wk.setup call

      if not setup_ok then
        vim.notify("Failed to setup which-key: " .. tostring(err), vim.log.levels.ERROR)
      else
        -- print("WhichKey: Setup completed.") -- Keep commented
      end
    end, -- End config function
  }, -- End which-key spec

  -- Mini Icons: Provides icons for various plugins
  {
    'echasnovski/mini.icons',
    lazy = true, -- Load only when needed by another plugin
  },
} -- End return table

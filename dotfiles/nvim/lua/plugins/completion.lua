-- lua/plugins/completion.lua
return {
  -- Completion Engine (nvim-cmp)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter', -- Load plugin once Insert mode is entered
    dependencies = {
      -- Sources for nvim-cmp
      'hrsh7th/cmp-nvim-lsp',       -- LSP completions
      'hrsh7th/cmp-buffer',       -- Buffer text completions
      'hrsh7th/cmp-path',         -- Filesystem path completions

      -- Snippet Engine & Source: LuaSnip
      {
        'L3MON4D3/LuaSnip',
        -- Follow latest release.
        version = "v2.*", -- Replace <CurrentMajor> by the latest major version.
        -- Build step is recommended for regex support in VS Code snippets. Requires 'make'.
        build = "make install_jsregexp",
        dependencies = {
           -- Optional: Load common snippets (recommended)
          'rafamadriz/friendly-snippets',
        }
      },
      'saadparwaiz1/cmp_luasnip',     -- Bridges nvim-cmp and LuaSnip

      -- NOTE: Removed 'hrsh7th/vim-vsnip' and 'hrsh7th/cmp-vsnip'
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip') -- Required for snippet expansion and jumping

      -- Optional: Load snippets from friendly-snippets
      -- Check if the loader exists before calling (good practice)
      if pcall(require, "luasnip.loaders.from_vscode") then
         require("luasnip.loaders.from_vscode").lazy_load()
      end

      -- Custom comparison function for sorting: put snippets on top
      local compare = require('cmp.config.compare')

      cmp.setup({
        -- Enable snippet features
        snippet = {
          expand = function(args)
            -- Use LuaSnip's expand function
            luasnip.lsp_expand(args.body)
          end,
        },

        -- Key mappings for completion
        mapping = cmp.mapping.preset.insert({
          ['<C-k>'] = cmp.mapping.select_prev_item(), -- Previous item
          ['<C-j>'] = cmp.mapping.select_next_item(), -- Next item
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),      -- Scroll docs up
          ['<C-f>'] = cmp.mapping.scroll_docs(4),       -- Scroll docs down
          ['<C-Space>'] = cmp.mapping.complete(),      -- Trigger completion
          ['<C-e>'] = cmp.mapping.abort(),           -- Close completion window
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Confirm selection

          -- Tab mapping: Navigate completion if open, jump snippets, or fallback
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- If completion menu is visible, select next item
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              -- If cursor is in a snippet jump point, jump to next point
              luasnip.expand_or_jump()
            else
              -- Otherwise, fallback to default Tab behavior (e.g., indent)
              fallback()
            end
          end, { "i", "s" }), -- Run in Insert and Select modes

          -- Shift-Tab mapping: Navigate completion back, jump snippets back, or fallback
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              -- If completion menu is visible, select previous item
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              -- If cursor is in a snippet jump point, jump to previous point
              luasnip.jump(-1)
            else
              -- Otherwise, fallback to default Shift-Tab behavior
              fallback()
            end
          end, { "i", "s" }), -- Run in Insert and Select modes
        }),

        -- Sources for completion candidates
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' }, -- Use luasnip source
          { name = 'path' },
        }, {
          { name = 'buffer', keyword_length = 5 }, -- Source from current buffer (longer words)
        }),

        -- Configure appearance (Optional, requires Nerd Font for icons)
        formatting = {
          fields = { 'kind', 'abbr', 'menu' },
          format = function(entry, vim_item)
            -- Define icons for different completion kinds
            local kind_icons = {
              Text = "", Method = "󰆧", Function = "󰊕", Constructor = "", Field = "󰇽",
              Variable = "󰂡", Class = "󰠱", Interface = "", Module = "", Property = "󰜢",
              Unit = "", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "",
              Color = "󰏘", File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕", TypeParameter = "󰅲",
            }
            -- Add icon to the completion item kind
            vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind] or '?', vim_item.kind)
            -- Add source menu name (useful for debugging)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip = "[Snippet]", -- Updated source name
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },

        -- Configure completion window appearance (Optional)
        window = {
           completion = cmp.config.window.bordered(),
           documentation = cmp.config.window.bordered(),
        },

        -- Configure sorting behavior (Optional)
        sorting = {
          comparators = {
            compare.offset, compare.exact, compare.score,
            -- Put snippets higher in the list
            compare.kind, -- Sort by kind (snippets usually grouped)
            compare.sort_text, compare.length, compare.order,
            compare.recently_used, -- Add recently_used comparator
          }
        }
      }) -- End of cmp.setup
    end, -- End of config function
  }, -- End of nvim-cmp plugin spec

  -- LuaSnip engine definition (defined here so lazy.nvim manages it)
  -- Note: Dependencies were listed under nvim-cmp, this is just for clarity
  -- If you prefer, you can remove the spec below and just keep it in nvim-cmp's dependencies
  {
    'L3MON4D3/LuaSnip',
    -- Ensure this is loaded when completion is needed or snippets are used
    -- No specific event needed if it's a dependency of cmp which loads on InsertEnter
  },
} -- End of return table

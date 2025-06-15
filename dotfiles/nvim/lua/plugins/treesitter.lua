-- lua/plugins/treesitter.lua
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  event = { "BufReadPost", "BufNewFile" }, -- Load slightly later
  config = function()
    require('nvim-treesitter.configs').setup({
      -- Add languages to be installed here
      ensure_installed = { 'python', 'javascript', 'typescript', 'lua', 'query', 'vim', 'vimdoc', 'c', 'bash', 'html', 'css', 'json', 'yaml', 'markdown', 'markdown_inline' },
      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,
      -- Automatically install missing parsers when entering buffer
      auto_install = true,
      -- List of modules derived from `ensure_installed` potentially used by other plugins
      modules = {},
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (like Ruby) for indent rules.
        -- If you are experiencing weird indenting issues, add the language to
        -- the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        -- disable = { "yaml" } -- Disable indent for specific languages if needed
      },
      -- Optional: Add other Treesitter modules like incremental selection, etc.
      -- incremental_selection = {
      --   enable = true,
      --   keymaps = {
      --     init_selection = '<c-space>',
      --     node_incremental = '<c-space>',
      --     scope_incremental = '<c-s>',
      --     node_decremental = '<M-space>',
      --   },
      -- },
      -- textobjects = { ... }
    })
  end,
}

-- lua/plugins/comment.lua
return {
  'numToStr/Comment.nvim',
  -- opts = {}, -- Add plugin options here if needed later
  config = function(_, opts)
    require('Comment').setup(vim.tbl_deep_extend('force', {
      -- Add plugin options here if needed
      -- For example: disable padding
      -- padding = false,

      -- Note: Default mappings are enabled (create_default_mappings = true is default).
      -- This causes a slight delay on <leader>gc / <leader>gb due to overlap
      -- with mappings like gcc, gco, gbc, etc. (visible in :checkhealth which-key).
      -- This delay is usually acceptable. To remove the delay and the extra
      -- default mappings, add the following line inside this setup table:
      -- create_default_mappings = false,

    }, opts or {})) -- Merge with any opts defined above

    -- Define custom keymaps
    local map = vim.keymap.set

    -- Linewise comment toggle for Normal and Visual mode
    map({ 'n', 'v' }, '<leader>gc', function()
      require('Comment.api').toggle.linewise.current()
    end, { desc = 'Toggle comment line' }) -- Simplified desc

    -- Ensure visual mode mapping uses visual selection context
    -- Note: The above mapping might handle visual mode correctly with the API call.
    -- If issues arise, this alternative targets the visual selection explicitly.
    -- map('v', '<leader>gc', "<cmd>'<,'>CommentToggle<CR>", { desc = 'Toggle comment selection' })

     -- Custom block comment mapping
     map({ 'n', 'v' }, '<leader>gb', function()
       require('Comment.api').toggle.blockwise.current()
     end, { desc = 'Toggle comment block' })
  end,
}

return {
  'tpope/vim-unimpaired',
  dependencies = { 'afreakk/unimpaired-which-key.nvim' },
  config = function()
    local wk = require('which-key')
    local uwk = require('unimpaired-which-key')

    local function override(mappings)
      local filtered_mappings = {}
      for _, mapping in ipairs(mappings) do
        local filtered_mapping = {}
        for _, m in ipairs(mapping) do
          -- The ]t, [t mappings are overwritten for todo-comments
          if m[1] ~= ']t' and m[1] ~= '[t' then
            table.insert(filtered_mapping, m)
          end
        end
        table.insert(filtered_mappings, filtered_mapping)
      end
      return filtered_mappings
    end

    wk.add(override(uwk))
  end,
}

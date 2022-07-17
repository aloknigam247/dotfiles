return require('packer').startup(function()
    -- packer manages itself
    use 'wbthomason/packer.nvim'

    -- Auto Pair:
    -- ``````````
    -- {{{
    -- Plug 'windwp/nvim-autopairs' " {
        -- TODO: Create custom rule to Expand multiple pairs on enter key, similar to vim-closer, already implemented in its wiki
        -- BUG: braces Indentation is not correct in some situation
        -- TODO: Create rule to not pair " for vim files
    -- }
    use 'ZhiyuanLck/smart-pairs'
    -- TODO: https://github.com/max-0406/autoclose.nvim
    -- TODO: https://github.com/rstacruz/vim-closer
    -- TODO: https://github.com/steelsojka/pears.nvim
    -- TODO: https://github.com/theHamsta/nvim-treesitter-pairs
    -- }}}
end
)

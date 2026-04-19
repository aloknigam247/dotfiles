-- Minimal init for review.nvim test harness
local plugin_root = "D:/dotfiles/neovim/review"
local lazy_root = "D:/apps/nvim-data/lazy"

vim.opt.rtp:append(plugin_root)
vim.opt.rtp:append(lazy_root .. "/snacks.nvim")
vim.opt.rtp:append(lazy_root .. "/nui.nvim")

require("snacks").setup({
	picker = { enabled = true },
})

_G.REVIEW_TEST = true

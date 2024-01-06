local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	defaults = { lazy = true, version = "*" },
	spec = { import = "plugins" },
	install = { missing = true, colorscheme = { "tokyonight" } },
	ui = { border = "single" },
	change_detection = { enabled = true, notify = false },
})

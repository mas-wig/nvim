return {
	{ "ray-x/go.nvim", ft = { "go", "gomod" }, opts = require("plugins.language.golang") },
	{ "jakewvincent/mkdnflow.nvim", ft = "markdown", opts = require("plugins.language.markdown") },
	{ "p00f/clangd_extensions.nvim", ft = { "c", "cpp" }, opts = require("plugins.language.c_cpp") },
	{
		"mrcjkb/rustaceanvim",
		version = "^3",
		cmd = "RustLsp",
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = require("plugins.language.rust")
		end,
	},
}

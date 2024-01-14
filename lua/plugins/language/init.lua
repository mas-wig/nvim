return {
	{
		"ray-x/go.nvim",
		ft = { "go", "gomod" },
		config = function()
			require("plugins.language.golang")
		end,
	},
	{ "jakewvincent/mkdnflow.nvim", ft = "markdown", opts = require("plugins.language.markdown") },
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		config = function()
			require("plugins.language.c_cpp")
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		ft = { "javascript", "typescript" },
		config = function()
			require("plugins.language.typescript")
		end,
	},
	{
		"mrcjkb/rustaceanvim",
		version = "^3",
		branch = "master",
		cmd = "RustLsp",
		ft = { "rust" },
		config = function()
			vim.g.rustaceanvim = require("plugins.language.rust")
		end,
	},
}

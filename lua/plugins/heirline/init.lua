return {
	"rebelot/heirline.nvim",
	event = "BufRead",
	dependencies = {
		"SmiteshP/nvim-navic",
		opts = { highlight = true, icons = require("utils.icons").kinds, lazy_update_context = true },
	},
	config = function()
		require("heirline").setup({
			statusline = {
				condition = function()
					return not require("heirline.conditions").buffer_matches({
						buftype = { "nofile", "terminal", "prompt", "help", "quickfix" },
						filetype = {
							"^alpha$",
							"^harpoon$",
							"^dashboard$",
							"^DressingInput$",
							"^lazy$",
							"^Glance$",
							"^lazyterm$",
							"^netrw$",
							"^TelescopePrompt$",
							"^neo--tree$",
							"^neotest--summary$",
							"^neo--tree--popup$",
						},
					})
				end,
				require("plugins.heirline.statusline").left,
				require("plugins.heirline.statusline").middle,
				require("plugins.heirline.statusline").right,
			},
			statuscolumn = require("plugins.heirline.statuscolumn"),
			winbar = require("plugins.heirline.winbar"),
			opts = {
				disable_winbar_cb = function(args)
					return require("heirline.conditions").buffer_matches({
						buftype = { "prompt", "nofile", "terminal", "help", "quickfix" },
						filetype = {
							"^git.*",
							"fugitive",
							"Trouble",
							"dashboard",
							"mysql",
							"sql",
							"json",
							"fugitive",
							"qf",
							"oil",
							"dbui",
							"dbout",
							"^Glance$",
						},
					}, args.buf)
				end,
				colors = require("tokyonight.colors").setup(),
			},
		})
	end,
}

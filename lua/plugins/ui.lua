return {
	{ "MunifTanjim/nui.nvim", lazy = true },
	{ "nvim-tree/nvim-web-devicons", lazy = true },
	{ "NvChad/nvim-colorizer.lua", event = "BufRead", config = true },
	{ "https://gitlab.com/HiPhish/rainbow-delimiters.nvim", event = "BufRead" },
	{
		"nvimdev/dashboard-nvim",
		event = "VimEnter",
		opts = function()
			local logo = [[
        ██████╗  ███████╗ ███╗   ███╗  ██████╗  ██╗  ██╗     ██████╗  ███████╗ ██╗   ██╗
        ██╔══██╗ ██╔════╝ ████╗ ████║ ██╔═══██╗ ██║ ██╔╝     ██╔══██╗ ██╔════╝ ██║   ██║
        ██████╔╝ █████╗   ██╔████╔██║ ██║   ██║ █████╔╝      ██║  ██║ █████╗   ██║   ██║
        ██╔══██╗ ██╔══╝   ██║╚██╔╝██║ ██║   ██║ ██╔═██╗      ██║  ██║ ██╔══╝   ╚██╗ ██╔╝
        ██║  ██║ ███████╗ ██║ ╚═╝ ██║ ╚██████╔╝ ██║  ██╗     ██████╔╝ ███████╗  ╚████╔╝ 
        ╚═╝  ╚═╝ ╚══════╝ ╚═╝     ╚═╝  ╚═════╝  ╚═╝  ╚═╝     ╚═════╝  ╚══════╝   ╚═══╝  
        ]]

			logo = string.rep("\n", 2) .. logo .. "\n\n"
			local opts = {
				theme = "doom",
				hide = { statusline = true },
				config = {
					header = vim.split(logo, "\n"),
					center = {
                        -- stylua: ignore start
						{ action = "FzfLua files", desc = "Find Files", icon = " ", key = "n", },
						{ action = "ene | startinsert", desc = " New file", icon = " ", key = "n", },
						{ action = "LazyExtras", desc = " Lazy Extras", icon = " ", key = "x", },
						{ action = "Lazy", desc = " Lazy", icon = "󰒲 ", key = "l", },
						{ action = "qa", desc = " Quit", icon = " ", key = "q", },
						-- stylua: ignore start
					},
					footer = function()
						local stats = require("lazy").stats()
						local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
						return {
							"⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms",
						}
					end,
				},
			}

			for _, button in ipairs(opts.config.center) do
				button.desc = button.desc .. string.rep(" ", 43 - #button.desc)
				button.key_format = "  %s"
			end
			-- close Lazy and re-open when the dashboard is ready
			if vim.o.filetype == "lazy" then
				vim.cmd.close()
				vim.api.nvim_create_autocmd("User", {
					pattern = "DashboardLoaded",
					callback = function()
						require("lazy").show()
					end,
				})
			end
			return opts
		end,
	},
	{
		"lukas-reineke/indent-blankline.nvim",
		event = { "BufReadPost" },
		opts = {
			indent = { char = "▏", tab_char = "▏" },
			scope = {
				enabled = true,
				highlight = {
					"RainbowDelimiterRed",
					"RainbowDelimiterYellow",
					"RainbowDelimiterBlue",
					"RainbowDelimiterOrange",
					"RainbowDelimiterGreen",
					"RainbowDelimiterViolet",
					"RainbowDelimiterCyan",
				},
			},
			exclude = {
				filetypes = { "help", "alpha", "dashboard", "Trouble", "lazy", "mason", "notify", "toggleterm" },
			},
		},
		main = "ibl",
	},
	{
		"rcarriga/nvim-notify",
		opts = {
			timeout = 3000,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
			render = "wrapped-compact",
		},
		init = function()
			vim.notify = require("notify")
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = { view = "cmdline" },
			popupmenu = { enabled = false },
			lsp = {
				signature = { enabled = true, auto_open = { enabled = false } }, -- karana gua pake lsp signature
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			views = {
				popup = {
					border = { style = vim.g.border },
					size = { max_width = math.floor(vim.o.columns / 2), max_height = math.floor(vim.o.lines / 3) },
				},
				hover = {
					border = { style = vim.g.border },
					size = { max_width = math.floor(vim.o.columns / 2), max_height = math.floor(vim.o.lines / 3) },
				},
			},
			presets = {
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				inc_rename = false,
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "BufRead",
		config = function()
			local wk = require("which-key")
			wk.setup({
				plugins = { marks = false, register = false },
				icons = {
					breadcrumb = "  ",
					separator = "  ",
					group = "󱡠  ",
				},
				disable = {
					buftypes = { "quickfix", "terminal", "nofile" },
					filetypes = { "Trouble" },
				},
			})
			-- method 3
			wk.register({
				["<leader>t"] = { name = "  Terminal &   Testing" },
				["<leader>f"] = { name = "  Fuzzy Finder" },
				["<leader>h"] = { name = "  Git" },
				["<leader>d"] = { name = "  Debugger" },
				["<leader>df"] = { name = "  UI Float" },
				["<leader>x"] = { name = "  Diagnostics &   TODO" },
				["<leader>u"] = { name = "⏼  Toggle Stuff" },
				["<leader><tab>"] = { name = "󰓩  Tabs" },
				["<leader>j"] = { name = "󰌝  Languages" },
				["<leader>hf"] = { name = "  Git Search" },
				["<leader>ds"] = { name = "  Dap Find" },
				["<leader>s"] = { name = "  Search" },
				["<leader>m"] = { name = "󱪾  Marks" },
				["<leader>w"] = { name = "  Windows" },
				["<leader>b"] = { name = "  Buffers" },
			})
		end,
	},
}

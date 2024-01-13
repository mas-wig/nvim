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
						{ action = "lua require('fzf-lua').files()", desc = " Find Files", icon = " ", key = "f", },
						{ action = "lua require('fzf-lua').resume()", desc = " Resume Files", icon = "󰼨 ", key = "p", },
						{ action = "Oil", desc = " File Explorer", icon = "󱇧 ", key = "o", },
						{ action = "ToggleTerm", desc = " Open Terminal", icon = " ", key = "t", },
						{ action = "lua require'harpoon'.ui:toggle_quick_menu(require'harpoon':list())", desc = " Marks", icon = "󱪾 ", key = "m", },
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
		init = function()
			vim.notify = require("notify")
		end,
		config = function()
			local notify = require("notify")

			local stages_util = require("notify.stages.util")
			local Dir = stages_util.DIRECTION

			local function anim(direction)
				return {
					function(state)
						local next_row = stages_util.available_slot(state.open_windows, state.message.height, direction)
						if not next_row then
							return nil
						end
						return {
							relative = "editor",
							anchor = "NE",
							width = 1,
							height = state.message.height,
							col = vim.opt.columns:get(),
							row = next_row,
							border = "rounded",
							style = "minimal",
						}
					end,
					function(state, win)
						return {
							width = { state.message.width },
							col = { vim.opt.columns:get() },
							row = {
								stages_util.slot_after_previous(win, state.open_windows, direction),
								frequency = 3,
								complete = function()
									return true
								end,
							},
						}
					end,
					function(state, win)
						return {
							col = { vim.opt.columns:get() },
							time = true,
							row = {
								stages_util.slot_after_previous(win, state.open_windows, direction),
								frequency = 3,
								complete = function()
									return true
								end,
							},
						}
					end,
					function(state, win)
						return {
							border = "FloatBorder",
							width = {
								1,
								frequency = 2.5,
								damping = 0.9,
								complete = function(cur_width)
									return cur_width < 3
								end,
							},
							col = { vim.opt.columns:get() },
							row = {
								stages_util.slot_after_previous(win, state.open_windows, direction),
								frequency = 3,
								complete = function()
									return true
								end,
							},
						}
					end,
				}
			end
			notify.setup({
				timeout = 3000,
				on_open = function(win)
					vim.api.nvim_win_set_config(win, { zindex = 100 })
				end,
				render = "wrapped-compact",
				stages = anim(Dir.TOP_DOWN),
			})
		end,
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		config = function()
			require("noice").setup({
				cmdline = { view = "cmdline" },
				popupmenu = { enabled = false },
				lsp = {
					signature = {
						enabled = true,
						auto_open = { enabled = true, trigger = false, luasnip = false, throttle = 50 },
					},
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
					documentation = {
						view = "hover",
						opts = {
							lang = "markdown",
							replace = true,
							render = "plain",
							format = { "{message}" },
							win_options = { concealcursor = "nc", conceallevel = 3 },
						},
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
						wrap = true,
						size = { max_width = math.floor(vim.o.columns / 2), max_height = math.floor(vim.o.lines / 3) },
					},
					hover = {
						border = { style = vim.g.border },
						wrap = true,
						size = {
							max_width = math.max(15, math.ceil(vim.go.columns * 0.41)),
							max_height = math.max(10, math.ceil(vim.go.lines * 0.4)),
						},
					},
				},
				presets = {
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
					inc_rename = false,
				},
			})
			vim.keymap.set({ "n", "s" }, "<c-f>", function()
				if not require("noice.lsp").scroll(4) then
					return "<c-f>"
				end
			end, { silent = true, expr = true })
			vim.keymap.set({ "n", "s" }, "<c-b>", function()
				if not require("noice.lsp").scroll(-4) then
					return "<c-b>"
				end
			end, { silent = true, expr = true })
		end,
	},
	{
		"folke/which-key.nvim",
		event = "BufRead",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
			local wk = require("which-key")
			wk.setup({
				layout = {
					height = { min = 4, max = 15 },
					width = { min = 20, max = 50 },
					spacing = 4,
					align = "left",
				},
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
				["<A-space>"] = { name = "󱪾  Marks" },
				["<leader>w"] = { name = "  Windows" },
				["<leader>g"] = { name = "  Lsp" },
				["<leader>b"] = { name = "  Buffers" },
			})
		end,
	},
}

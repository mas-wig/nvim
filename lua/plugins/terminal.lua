return {
	{
		"akinsho/toggleterm.nvim",
		cmd = { "ToggleTerm", "ToggleTermToggleAll", "TermExec", "TermSelect", "ToggleTermSetName" },
		keys = {
			{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
			{ "<C-/>", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Terminal Horizontal" },
			{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Terminal Vertical" },
			{ "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal Float" },
			{
				"<leader>hg",
				function()
					require("toggleterm.terminal").Terminal
						:new({
							cmd = "lazygit",
							hidden = true,
							direction = "float",
							close_on_exit = true,
							dir = require("utils.dir").root(),
						})
						:toggle()
				end,
				desc = "LazyGit",
			},
			{
				"<leader>hh",
				function()
					require("toggleterm.terminal").Terminal
						:new({
							cmd = "gh extension exec dash",
							hidden = true,
							direction = "float",
							close_on_exit = true,
							dir = require("utils.dir").cwd(),
						})
						:toggle()
				end,
				desc = "Gtihub CLI",
			},
		},
		opts = {
			open_mapping = [[<c-/>]],
			autochdir = true,
			highlights = {
				Normal = { link = "Normal" },
				NormalFloat = { link = "NormalFloat" },
				FloatBorder = { link = "Comment" },
			},
			shade_terminals = false,
			start_in_insert = true,
			insert_mappings = true,
			terminal_mappings = true,
			persist_size = true,
			direction = "horizontal",
			shell = vim.o.shell,
			auto_scroll = true,
			float_opts = { border = "solid", width = vim.o.columns, height = vim.o.lines, winblend = 0 },
			size = function(term)
				if term.direction == "horizontal" then
					return math.floor(vim.o.lines / 2)
				elseif term.direction == "vertical" then
					return math.floor(vim.o.columns * 0.4)
				end
			end,
		},
	},
	{
		"willothy/flatten.nvim",
		lazy = false,
		priority = 1001,
		opts = function()
			local saved_terminal
			return {
				window = { open = "alternate" },
				one_per = { kitty = false, wezterm = false },
				callbacks = {
					should_block = function(argv)
						return vim.tbl_contains(argv, "-b")
					end,
					pre_open = function()
						local term = require("toggleterm.terminal")
						local termid = term.get_focused_id()
						saved_terminal = term.get(termid)
					end,
					post_open = function(bufnr, winnr, ft, is_blocking)
						if is_blocking and saved_terminal then
							saved_terminal:close()
						else
							vim.api.nvim_set_current_win(winnr)
						end
						if ft == "gitcommit" or ft == "gitrebase" then
							vim.api.nvim_create_autocmd("BufWritePost", {
								buffer = bufnr,
								once = true,
								callback = vim.schedule_wrap(function()
									vim.api.nvim_buf_delete(bufnr, {})
								end),
							})
						end
					end,
					block_end = function()
						vim.schedule(function()
							if saved_terminal then
								saved_terminal:open()
								saved_terminal = nil
							end
						end)
					end,
				},
				pipe_path = function()
					if vim.env.NVIM then
						return vim.env.NVIM
					end
					if vim.env.KITTY_PID then
						local addr = ("%s/%s"):format(vim.fn.stdpath("run"), "kitty.nvim-" .. vim.env.KITTY_PID)
						if not vim.uv.fs_stat(addr) then
							vim.fn.serverstart(addr)
						end
						return addr
					end
				end,
			}
		end,
	},
}

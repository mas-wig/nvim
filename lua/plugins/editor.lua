return {
	{
		"numToStr/Comment.nvim",
		event = "BufRead",
		config = function()
			require("Comment").setup()
			local ft = require("Comment.ft")
			ft({ "http" }, "#%s")
		end,
	},

	{
		"chrisgrieser/nvim-early-retirement",
		event = "VeryLazy",
		opts = { retirementAgeMins = 5, notificationOnAutoClose = true },
	},

	{
		"tpope/vim-dadbod",
		dependencies = {
			{
				"kristijanhusak/vim-dadbod-ui",
				init = function()
					vim.g.db_ui_use_nerd_fonts = 1
					vim.g.db_ui_winwidth = 45
				end,
			},
		},
		cmd = "DBUI",
	},
	{
		"folke/trouble.nvim",
		cmd = { "TroubleToggle", "Trouble" },
		opts = {
			auto_jump = { "lsp_references", "lsp_implementations", "lsp_type_definitions", "lsp_definitions" },
			use_diagnostic_signs = true,
		},
		keys = {
			{ "<leader>xx", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics (Trouble)" },
			{ "<leader>xL", "<cmd>TroubleToggle loclist<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").previous({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous trouble/quickfix item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next trouble/quickfix item",
			},
		},
	},

	{
		"echasnovski/mini.surround",
		keys = function(_, keys)
			local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
			local opts = require("lazy.core.plugin").values(plugin, "opts", false)
			local mappings = {
				{ opts.mappings.add, desc = "Add surrounding", mode = { "n", "v" } },
				{ opts.mappings.delete, desc = "Delete surrounding" },
				{ opts.mappings.find, desc = "Find right surrounding" },
				{ opts.mappings.find_left, desc = "Find left surrounding" },
				{ opts.mappings.highlight, desc = "Highlight surrounding" },
				{ opts.mappings.replace, desc = "Replace surrounding" },
				{ opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
			}
			mappings = vim.tbl_filter(function(m)
				return m[1] and #m[1] > 0
			end, mappings)
			return vim.list_extend(mappings, keys)
		end,
		opts = {
			mappings = {
				add = "gsa",
				delete = "gsd",
				find = "gsf",
				find_left = "gsF",
				highlight = "gsh",
				replace = "gsr",
				update_n_lines = "gsn",
			},
		},
	},
	{
		"ThePrimeagen/harpoon",
		dependencies = { "nvim-lua/plenary.nvim" },
		branch = "harpoon2",
		config = function()
			local harpoon = require("harpoon")
			require("harpoon.config").DEFAULT_LIST = "files"
			harpoon:setup({
				settings = {
					save_on_toggle = true,
					sync_on_ui_close = false,
					key = function()
						return vim.uv.cwd()
					end,
				},
				default = {},
			})
			harpoon:extend({
				UI_CREATE = function(cx)
					vim.keymap.set("n", "<C-v>", function()
						harpoon.ui:select_menu_item({ vsplit = true })
					end, { buffer = cx.bufnr })

					vim.keymap.set("n", "<C-h>", function()
						harpoon.ui:select_menu_item({ split = true })
					end, { buffer = cx.bufnr })

					vim.keymap.set("n", "<C-t>", function()
						harpoon.ui:select_menu_item({ tabedit = true })
					end, { buffer = cx.bufnr })
				end,
			})
		end,
		keys = function()
			local hp = require("harpoon")
			return {
                -- stylua: ignore start
				{ "<A-space>", function() hp.ui:toggle_quick_menu(hp:list(), { title = "", ui_width_ratio = 0.65 }) end, desc = "Harpoon Toggle" },
				{ "<A-a>", function() vim.notify("Add to Mark", 2) hp:list():append() end, desc = "Add to Mark" },
				{ "<A-1>", function() hp:list():select(1) end, desc = "Mark File 1" },
				{ "<A-2>", function() hp:list():select(2) end, desc = "Mark File 2" },
				{ "<A-3>", function() hp:list():select(3) end, desc = "Mark File 3" },
				{ "<A-4>", function() hp:list():select(4) end, desc = "Mark File 4" },
				{ "<A-5>", function() hp:list():select(5) end, desc = "Mark File 6" },
				{ "<A-6>", function() hp:list():select(6) end, desc = "Mark File 6" },
				{ "<A-7>", function() hp:list():select(7) end, desc = "Mark File 7" },
				{ "<A-8>", function() hp:list():select(8) end, desc = "Mark File 8" },
				{ "<A-9>", function() hp:list():select(9) end, desc = "Mark File 9" },
				-- stylua: ignore end
			}
		end,
	},
	{
		"altermo/ultimate-autopair.nvim",
		event = { "InsertEnter" },
		branch = "v0.6",
		config = function()
			local function get_two_char_after()
				local col, line
				if vim.fn.mode():match("^c") then
					col = vim.fn.getcmdpos()
					line = vim.fn.getcmdline()
				else
					col = vim.fn.col(".")
					line = vim.api.nvim_get_current_line()
				end
				return line:sub(col, col + 1)
			end
			local compltype = {}
			local IGNORE_REGEX = vim.regex([=[^\(\k\|\\\?[([{]\)]=])
			require("ultimate-autopair").setup({
				extensions = {
					alpha = false,
					tsnode = false,
					utf8 = false,
					filetype = { tree = false },
					cond = {
						cond = function(f)
							return not f.in_macro()
								and not IGNORE_REGEX:match_str(get_two_char_after())
								and (not f.in_cmdline() or compltype[1] ~= "" or compltype[2] ~= "command")
						end,
					},
				},
				{ "\\(", "\\)" },
				{ "\\[", "\\]" },
				{ "\\{", "\\}" },
			})
		end,
	},
	{
		"folke/todo-comments.nvim",
		event = "BufRead",
		opts = {
			signs = true,
			sign_priority = 8,
			keywords = {
				FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
				TODO = { icon = " ", color = "info" },
				HACK = { icon = " ", color = "warning" },
				WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
				PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
				NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
				TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
			},
			gui_style = { fg = "NONE", bg = "BOLD" },
			merge_keywords = true,
			highlight = {
				multiline = true,
				multiline_pattern = "^.",
				multiline_context = 10,
				before = "",
				keyword = "wide",
				after = "fg",
				pattern = [[.*<(KEYWORDS)\s*:]],
				comments_only = true,
				max_line_len = 400,
				exclude = { "markdown" },
			},
			colors = {
				error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
				warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
				info = { "DiagnosticInfo", "#2563EB" },
				hint = { "DiagnosticHint", "#10B981" },
				default = { "Identifier", "#7C3AED" },
				test = { "Identifier", "#FF00FF" },
			},
		},
		keys = {
            -- stylua: ignore start
			{ "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment", },
			{ "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment", },
			{ "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo (Trouble)" },
			{ "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
			-- stylua: ignore end
		},
	},
	{
		"echasnovski/mini.bufremove",
		keys = {
			{
				"<leader>bd",
				function()
					local bd = require("mini.bufremove").delete
					if vim.bo.modified then
						local choice =
							vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
						if choice == 1 then -- Yes
							vim.cmd.write()
							bd(0)
						elseif choice == 2 then -- No
							bd(0, true)
						end
					else
						bd(0)
					end
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>bD",
				function()
					require("mini.bufremove").delete(0, true)
				end,
				desc = "Delete Buffer (Force)",
			},
		},
	},
}

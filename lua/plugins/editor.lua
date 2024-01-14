return {
	{ "numToStr/Comment.nvim", event = "BufRead", config = true },

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
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		keys = {
			{
				"<leader>up",
				function()
					local Util = require("lazy.core.util")
					local autopairs = require("nvim-autopairs")
					if autopairs.state.disabled then
						autopairs.enable()
						Util.info("Enabled auto pairs", { title = "Option" })
					else
						autopairs.disable()
						Util.warn("Disabled auto pairs", { title = "Option" })
					end
				end,
				desc = "Toggle auto pairs",
			},
		},
		config = function()
			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")
			npairs.setup({
				check_ts = true,
				map_c_h = true,
				map_c_w = true,
				enable_abbr = true,
				disable_in_macro = true,
				enable_check_bracket_line = true,
				ignored_next_char = [=[[%w%%%'%[%"%.%`]]=],
				fast_wrap = {
					map = "<A-c>",
					chars = { "{", "[", "(", '"', "'", "`" },
					pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
					offset = 0, -- Offset from pattern match
					end_key = "$",
					keys = "qwertyuiopzxcvbnmasdfghjkl",
					check_comma = true,
					highlight = "Search",
					highlight_grey = "Comment",
				},
			})

			npairs.add_rules({
				Rule(" ", " "):with_pair(function(opts)
					local pairs_single_char = { "()", "[]", "{}" }
					local pairs_double_char = { "/**/" }
					local line_before_cur = opts.line:sub(1, opts.col - 1)
					if
						vim.bo[opts.bufnr].ft == "markdown"
						and (line_before_cur:match("^%s*[-*+]%s+%[$") or line_before_cur:match("^%s*%d+%.%s+%[$"))
					then
						pairs_single_char = { "()", "{}" }
					end
					return vim.tbl_contains(pairs_single_char, opts.line:sub(opts.col - 1, opts.col))
						or vim.tbl_contains(pairs_double_char, opts.line:sub(opts.col - 2, opts.col + 1))
				end):with_del(function(opts)
					return vim.fn.match(opts.line:sub(1, opts.col):reverse(), [[\s\((\|[\|{\|\*\/\)]]) == 0
				end),

				Rule("<<<", ">>>", { "cuda" }),
				Rule("/*", "*/", { "c", "cpp" }),
				Rule("$", "$", { "markdown", "tex" }):with_pair(cond.none()),
				Rule("*", "*", { "markdown" }):with_pair(cond.none()),
				Rule("\\(", "\\)"):with_pair(cond.not_before_text("\\)")),
				Rule("\\(", "\\)", { "tex" }):with_pair(cond.not_before_text("\\)")),
				Rule("\\[", "\\]", { "tex" }):with_pair(cond.not_before_text("\\]")),
				Rule("\\{", "\\}", { "tex", "markdown" }):with_pair(cond.not_before_text("\\}")),
				Rule("\\left(", "\\right)", { "markdown", "tex" }):with_pair(cond.not_before_text("\\right)")),
				Rule("\\left[", "\\right]", { "markdown", "tex" }):with_pair(cond.not_before_text("\\right]")),
				Rule("\\left{", "\\right}", { "markdown", "tex" }):with_pair(cond.not_before_text("\\right}")),
				Rule("\\left<", "\\right>", { "markdown", "tex" }):with_pair(cond.not_before_text("\\right>")),
				Rule("\\left\\lfloor ", " \\right\\rfloor", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\right\\rfloor)")
				),
				Rule("\\left\\lceil ", " \\right\\rceil", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\right\\rceil)")
				),
				Rule("\\left\\vert ", " \\right\\vert", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\right\\vert")
				),
				Rule("\\left\\lVert ", " \\right\\rVert", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\right\\lVert")
				),
				Rule("\\left\\lVert ", " \\right\\rVert", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\right\\lVert")
				),
				Rule("\\begin{bmatrix} ", " \\end{bmatrix}", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\end{bmatrix}")
				),
				Rule("\\begin{pmatrix} ", " \\end{pmatrix}", { "markdown", "tex" }):with_pair(
					cond.not_before_text("\\end{pmatrix}")
				),
			})

			local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
			npairs.add_rules({
				Rule(" ", " ")
					-- Pair will only occur if the conditional function returns true
					:with_pair(function(opts)
						-- We are checking if we are inserting a space in (), [], or {}
						local pair = opts.line:sub(opts.col - 1, opts.col)
						return vim.tbl_contains({
							brackets[1][1] .. brackets[1][2],
							brackets[2][1] .. brackets[2][2],
							brackets[3][1] .. brackets[3][2],
						}, pair)
					end)
					:with_move(cond.none())
					:with_cr(cond.none())
					-- We only want to delete the pair of spaces when the cursor is as such: ( | )
					:with_del(
						function(opts)
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local context = opts.line:sub(col - 1, col + 2)
							return vim.tbl_contains({
								brackets[1][1] .. "  " .. brackets[1][2],
								brackets[2][1] .. "  " .. brackets[2][2],
								brackets[3][1] .. "  " .. brackets[3][2],
							}, context)
						end
					),
			})
			-- For each pair of brackets we will add another rule
			for _, bracket in pairs(brackets) do
				npairs.add_rules({
					-- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
					Rule(bracket[1] .. " ", " " .. bracket[2])
						:with_pair(cond.none())
						:with_move(function(opts)
							return opts.char == bracket[2]
						end)
						:with_del(cond.none())
						:use_key(bracket[2])
						-- Removes the trailing whitespace that can occur without this
						:replace_map_cr(function(_)
							return "<C-c>2xi<CR><C-c>O"
						end),
				})
			end
			for _, punct in pairs({ ",", ";" }) do
				require("nvim-autopairs").add_rules({
					require("nvim-autopairs.rule")("", punct)
						:with_move(function(opts)
							return opts.char == punct
						end)
						:with_pair(function()
							return false
						end)
						:with_del(function()
							return false
						end)
						:with_cr(function()
							return false
						end)
						:use_key(punct),
				})
			end
		end,
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
					-- sync_on_ui_close = true,
					key = function()
						return vim.uv.cwd() --[[@as string]]
					end,
				},
				tmux = {
					automated = true,
					encode = false,
					prepopulate = function(cb)
						vim.system({ "tmux", "list-sessions" }, { text = true }, function(out)
							if out.code ~= 0 then
								return {}
							end
							local sessions = out.stdout or ""
							local lines = {}
							for s in sessions:gmatch("[^\r\n]+") do
								table.insert(lines, { value = s, context = { row = 1, col = 1 } })
							end
							cb(lines)
						end)
					end,
					select = function(list_item, _, _)
						local sessionName = string.match(list_item.value, "([^:]+)")
						vim.system({ "tmux", "switch-client", "-t", sessionName }, {}, function() end)
					end,
					remove = function(list_item, _)
						local sessionName = string.match(list_item.value, "([^:]+)")
						return vim.system({ "tmux", "kill-session", "-t", sessionName }, {}, function() end)
					end,
				},
				default = {},
			})

			---@param list HarpoonList
			local function prepopulate(list)
				---@diagnostic disable-next-line: undefined-field
				if list.config.prepopulate and list:length() == 0 then
					-- async via callback, or sync via return value
					local sync_items =
						---@diagnostic disable-next-line: undefined-field
						list.config.prepopulate(function(items)
							if type(items) ~= "table" then
								return
							end
							for _, item in ipairs(items) do
								list:append(item)
							end
							-- if ui is open, buffer needs to be updated
							-- so that items aren't removed immediately after being added
							vim.schedule(function()
								local ui_buf = harpoon.ui.bufnr
								if ui_buf and vim.api.nvim_buf_is_valid(ui_buf) then
									local lines = list:display()
									vim.api.nvim_buf_set_lines(ui_buf, 0, -1, false, lines)
								end
							end)
						end)
					if sync_items and type(sync_items) == "table" then
						for _, item in ipairs(sync_items) do
							list:append(item)
						end
					end
				end
			end

			harpoon:extend({
				UI_CREATE = function(cx)
					local win = cx.win_id
					vim.wo[win].cursorline = true
					vim.wo[win].signcolumn = "no"
					vim.keymap.set("n", "<C-v>", function()
						harpoon.ui:select_menu_item({ vsplit = true })
					end, { buffer = cx.bufnr })
					vim.keymap.set("n", "<C-s>", function()
						harpoon.ui:select_menu_item({ split = true })
					end, { buffer = cx.bufnr })
				end,
				---@param list HarpoonList
				LIST_READ = function(list)
					---@diagnostic disable-next-line: undefined-field
					if list.config.automated then
						list:clear()
						prepopulate(list)
					end
				end,
				LIST_CREATED = prepopulate,
			})
		end,
		keys = function()
			local harpoon = require("harpoon")
			return {
                -- stylua: ignore start
				{ "<A-a>", function() vim.notify("Add to Mark",2) harpoon:list():append() end, desc = "Add to Mark" },
				{ "<A-space>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Toggle" },
				{ "<A-1>", function() harpoon:list():select(1) end, desc = "Goto Mark 1" },
				{ "<A-2>", function() harpoon:list():select(2) end, desc = "Goto Mark 2" },
				{ "<A-3>", function() harpoon:list():select(3) end, desc = "Goto Mark 3" },
				{ "<A-4>", function() harpoon:list():select(4) end, desc = "Goto Mark 4" },
                { "<A-5>", function() harpoon:list():select(5) end, desc = "Goto Mark 6" },
                { "<A-6>", function() harpoon:list():select(6) end, desc = "Goto Mark 6" },
                { "<A-7>", function() harpoon:list():select(7) end, desc = "Goto Mark 7" },
                { "<A-8>", function() harpoon:list():select(8) end, desc = "Goto Mark 8" },
                { "<A-9>", function() harpoon:list():select(9) end, desc = "Goto Mark 9" },
				-- stylua: ignore start
			}
		end,
	},
	{
		"echasnovski/mini.hipatterns",
		event = "BufRead",
		opts = {
			highlighters = {
				todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
				fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
				hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
				note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
			},
		},
	},
}

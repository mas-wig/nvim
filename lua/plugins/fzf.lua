return {
	"ibhagwan/fzf-lua",
	init = function()
		---@diagnostic disable-next-line: duplicate-set-field
		vim.ui.select = function(...)
			require("fzf-lua").register_ui_select(function(_, items)
				local min_h, max_h = 0.15, 0.70
				local h = (#items + 4) / vim.o.lines
				if h < min_h then
					h = min_h
				elseif h > max_h then
					h = max_h
				end
				return {
					winopts = { height = h, width = 0.55, row = 0.45 },
					fzf_opts = {
						["--no-scrollbar"] = "",
						["--color"] = "separator:cyan",
						["--info"] = "right",
						["--marker"] = "󰍎 ",
						["--pointer"] = " ",
						["--padding"] = "0,1",
						["--margin"] = "0",
					},
				}
			end)
			return vim.ui.select(...)
		end
	end,
	keys = function()
		local fzf = require("utils").fzf
		return {
			{ "<leader>fB", fzf("builtin"), desc = "Find Builtin" },
			{ "<leader>fb", fzf("buffers"), desc = "Find Buffers" },
			{ "<leader>ff", fzf("files"), desc = "Find Files (root)" },
			{ "<leader>fo", fzf("oldfiles"), desc = "Find Old Files" },
			{ "<leader>fq", fzf("quickfix"), desc = "Quick Fix Item" },
			{ "<leader>fl", fzf("lines"), desc = "Find in Lines" },
			{ "<leader>ft", fzf("tabs"), desc = "Find Tabs" },
			{ "<leader>fa", fzf("args"), desc = "Args" },
			{ "<leader>fh", fzf("help_tags"), desc = "Help Tags" },
			{ "<leader>fm", fzf("man_pages"), desc = "Man Pages" },
			{ "<leader>fH", fzf("highlights"), desc = "Highlight Groups" },
			{ "<leader>fc", fzf("commands"), desc = "Neovim Commands" },
			{ "<leader>fz", fzf("search_history"), desc = "Search History" },
			{ "<leader>fm", fzf("marks"), desc = "Marks" },
			{ "<leader>fc", fzf("changes"), desc = "Changes" },
			{ "<leader>fj", fzf("jumps"), desc = "Jumps" },
			{ "<leader>fk", fzf("keymaps"), desc = "Keymaps" },
			{ "<leader>fR", fzf("registers"), desc = "Registers" },
			{ "<leader>fd", fzf("diagnostics_document"), desc = "Document Diagnostics" },
			{ "<leader>fD", fzf("diagnostics_workspace"), desc = "Workspace Diagnostics" },
			{ "<leader>fr", fzf("resume"), desc = "Find Resume" },

			-- git
			{ "<leader><leader>", fzf("files"), desc = "Find Files" },
			{ "<leader>hfs", fzf("git_status"), desc = "`git status`" },
			{ "<leader>hfc", fzf("git_commits"), desc = "Git Commit Log (project)" },
			{ "<leader>hfB", fzf("git_branches"), desc = "`git branches`" },
			{ "<leader>hfb", fzf("git_bcommits"), desc = "Git Commit Log (buffer)" },
			{ "<leader>hft", fzf("git_tags"), desc = "`git tags`" },
			{ "<leader>hfS", fzf("git_stash"), desc = "`git stash`" },

			-- Grep
			{ "<leader>/", fzf("grep"), desc = "Grep with Pattern" },
			{ "<leader>ss", fzf("grep"), desc = "Grep with Pattern" },
			{ "<leader>sS", fzf("grep_last"), desc = "Run Last Grep" },
			{ "<leader>sB", fzf("grep_curbuf"), desc = "Grep Current Buf" },
			{ "<leader>sb", fzf("lgrep_curbuf"), desc = "Lgrep Current Buf" },
			{ "<leader>sw", fzf("live_grep"), desc = "Lgrep Root Dir" },
			{ "<leader>sW", fzf("live_grep_resume"), desc = "Lgrep last search" },
			{ "<leader>sn", fzf("live_grep_native"), desc = "Native of Lgrep" },
			{ "<leader>sg", fzf("live_grep_glob"), desc = "Lgrep with rg --glob" },

			-- dap
			{ "<leader>dsc", fzf("dap_commands"), desc = "Command" },
			{ "<leader>dsC", fzf("dap_configurations"), desc = "Configuration" },
			{ "<leader>dsb", fzf("dap_breakpoints"), desc = "Breakpoint" },
			{ "<leader>dsv", fzf("dap_variables"), desc = "Active Session Variables" },
			{ "<leader>dsf", fzf("dap_frames"), desc = "Frames" },

			-- LSP
			-- { "<leader>gd", fzf("lsp_declarations"), desc = "Declaration" },
			-- { "<leader>gs", fzf("lsp_document_symbols"), desc = "Document Symbols" },
			-- { "<leader>gS", fzf("lsp_workspace_symbols"), desc = "Workspace Symbols" },
			-- { "<leader>gL", fzf("lsp_live_workspace_symbols"), desc = "Live Workspace Symbols" },
			-- { "<leader>gc", fzf("lsp_code_actions"), desc = "Code Action" },
			-- { "<leader>gi", fzf("lsp_incoming_calls"), desc = "Incoming Calls" },
			-- { "<leader>go", fzf("lsp_outgoing_calls"), desc = "Outgoing Calls" },
			-- { "<leader>gf", fzf("lsp_finder"), desc = "Lsp Finder" },
			-- { "<leader>gx", fzf("diagnostics_document"), desc = "Current Bufer Diagnostics" },
			-- { "<leader>gX", fzf("diagnostics_workspace"), desc = "Workspace Diagnostics" },
		}
	end,
	config = function()
		local fmt, icons, fzf = string.format, require("utils.icons"), require("fzf-lua")
		local ignore_folder = table.concat({
			".git",
			"node_modules",
			"vendor",
			"debug",
			".next",
			"dist",
			"build",
			"reports",
			".idea",
			".vscode",
			".yarn",
			".nyc_output",
			"__generated__",
		}, ",")

		local no_preview_winopts = { height = 0.7, width = 0.8, preview = { hidden = "hidden" } }

		return fzf.setup({
			actions = {
				files = {
					["default"] = fzf.actions.file_edit_or_qf,
					["ctrl-l"] = fzf.actions.arg_add,
					["ctrl-s"] = fzf.actions.file_split,
					["ctrl-v"] = fzf.actions.file_vsplit,
					["ctrl-t"] = fzf.actions.file_tabedit,
					["ctrl-q"] = fzf.actions.file_sel_to_qf,
					["alt-q"] = fzf.actions.file_sel_to_ll,
				},
			},
			previewers = {
				cat = { cmd = "cat", args = "--number" },
				bat = { cmd = "bat", args = "--style=numbers,changes --color always", theme = "base16", config = nil },
				head = { cmd = "head", args = nil },
				git_diff = {
					cmd_deleted = "git diff --color HEAD --",
					cmd_modified = "git diff --color HEAD",
					cmd_untracked = "git diff --color --no-index /dev/null",
				},
				man = { cmd = "man -c %s | col -bx" },
				builtin = {
					syntax = true,
					syntax_limit_l = 0,
					syntax_limit_b = 1024 * 1024,
					extensions = { ["png"] = { "feh" }, ["jpg"] = { "feh" } },
				},
			},
			winopts = {
				height = 0.80,
				width = 0.90,
				row = 0.40,
				col = 0.50,
				border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
				fullscreen = false,
				preview = {
					border = "border",
					wrap = "nowrap",
					hidden = "nohidden",
					-- vertical = "down:45%",
					horizontal = "right:53%",
					layout = "flex",
					flip_columns = 120,
					title = false,
					scrollbar = false,
					scrollchars = { "", "" },
					delay = 100,
					winopts = { number = false, relativenumber = false },
				},
			},

			grep = {
				prompt = " Search : ",
				input_prompt = " Grep For : ",
				glob_flag = "--iglob",
				glob_separator = "%s%-%-",
				git_icons = false,
				grep_opts = table.concat({
					"--binary-files=without-match",
					"--line-number",
					"--recursive",
					"--color=auto",
					"--perl-regexp",
					"-e",
				}, " "),
				rg_opts = table.concat({
					"--hidden",
					"--follow",
					"--smart-case",
					"--column",
					"--line-number",
					"--no-heading",
					"--color=always",
					"-g",
					fmt("'!{%s}/'", ignore_folder),
					"-e",
				}, " "),
			},

			-- Setup find files
			files = {
				prompt = " Files : ",
				multiprocess = true,
				git_icons = false,
				file_icons = true,
				color_icons = true,
				cwd_header = false,
				cwd_prompt = false,
				toggle_ignore_flag = "--no-ignore",
				path_shorten = false,
				find_opts = table.concat(
					{ "-type", "f", "-type", "d", "-type", "l", "-not", "-path", "'*/.git/*'", "-printf", "'%P\n'" },
					" "
				),
				fd_opts = table.concat({
					"--color=never",
					"--type",
					"f",
					"--hidden",
					"--no-ignore",
					"--follow",
					"--exclude",
					fmt("'{%s}/'", ignore_folder),
				}, " "),
				rg_opts = table.concat({
					"--column",
					"--line-number",
					"--no-heading",
					"--color=always",
					"--smart-case",
					"--max-columns=512",
					"--hidden",
					"--no-ignore",
					"-g",
					fmt("'!{%s}/'", ignore_folder),
				}, " "),
			},

			lsp = {
				code_actions = {
					prompt = " Code Action : ",
					winopts = { height = 0.3, width = 0.55, row = 0.45, preview = { hidden = "hidden" } },
				},
				finder = { prompt = " Lsp Finder : " },
				symbols = { prompt = " Lsp Symbols : ", symbol_icons = icons.kinds },
			},
			args = { prompt = " Args : ", git_icons = false, files_only = true },
			oldfiles = { prompt = " Old Files : ", git_icons = false },
			buffers = { prompt = " Buffers : ", git_icons = false },
			tabs = { winopts = no_preview_winopts, prompt = " Tabs : " },
			lines = { winopts = no_preview_winopts, prompt = " Lines : " },
			blines = { winopts = no_preview_winopts, prompt = " Buffer Lines : " },
			keymaps = { winopts = no_preview_winopts, prompt = " Keymaps : " },
			quickfix = { winopts = no_preview_winopts, prompt = " Quick Fix : " },
			quickfix_stack = { prompt = " Quick Fix Stack : " },
			diagnostics = {
				winopts = no_preview_winopts,
				prompt = " Diagnostics : ",
				signs = {
					["Error"] = { text = icons.diagnostics.Error, texthl = "DiagnosticError" },
					["Warn"] = { text = icons.diagnostics.Warn, texthl = "DiagnosticWarn" },
					["Info"] = { text = icons.diagnostics.Info, texthl = "DiagnosticInfo" },
					["Hint"] = { text = icons.diagnostics.Hint, texthl = "DiagnosticHint" },
				},
			},
			git = {
				icons = {
					["M"] = { icon = icons.git.modified, color = "yellow" },
					["D"] = { icon = icons.git.removed, color = "red" },
					["A"] = { icon = icons.git.added, color = "green" },
					["R"] = { icon = icons.git.renamed, color = "yellow" },
					["C"] = { icon = icons.git.unstage, color = "yellow" }, --copied
					["T"] = { icon = icons.git.ignored, color = "magenta" }, -- type change
					["?"] = { icon = icons.git.untracked, color = "magenta" },
				},
				branches = {
					prompt = " Git Branches : ",
					cmd = "git branch --all --color",
					preview = "git log --graph --pretty=oneline --abbrev-commit --color {1}",
				},
				bcommits = {
					prompt = " Git Buffer Commit : ",
					cmd = "git log --pretty=oneline --abbrev-commit --color",
					preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
				},
				commits = {
					prompt = "Commits❯ ",
					cmd = "git log --pretty=oneline --abbrev-commit --color",
					preview = "git show --pretty='%Cred%H%n%Cblue%an%n%Cgreen%s' --color {1}",
				},
				status = {
					prompt = " Git Status : ",
					cmd = "git status -su",
					previewer = "git_diff",
					file_icons = true,
					git_icons = true,
					color_icons = true,
				},
				files = {
					prompt = " Git Files : ",
					cmd = "git ls-files --exclude-standard",
					multiprocess = true,
					git_icons = false,
					file_icons = true,
					color_icons = true,
				},
			},

			fzf_colors = {
				["fg"] = { "fg", "TelescopeNormal" },
				["bg"] = { "bg", "Normal" },
				["hl"] = { "fg", "NeoTreeTabActive" },
				["fg+"] = { "fg", "TelescopeSelection" },
				["bg+"] = { "bg", "PmenuSel" },
				["hl+"] = { "fg", "CmpItemAbbrMatch" },
				["info"] = { "fg", "TelescopeCounter" },
				["border"] = { "fg", "Comment" },
				["gutter"] = { "bg", "TelescopeNormal" },
				["prompt"] = { "fg", "TelescopePrefix" },
				["pointer"] = { "fg", "TelescopeSelectionCaret" },
				["marker"] = { "fg", "GitSignsChange" },
			},
			file_icon_padding = " ",
			global_resume = true, -- enable global `resume`?
			global_resume_query = true, -- include typed query in `resume`?
		})
	end,
}

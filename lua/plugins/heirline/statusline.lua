local fmt, colors, icons = string.format, require("tokyonight.colors").setup(), require("utils.icons")
local space, conditions = { provider = " " }, require("heirline.conditions")

return {
	left = {
		{
			init = function(self)
				self.mode = vim.fn.mode()
				self.mode_color = self.mode_colors[self.mode:sub(1, 1)]
			end,
			update = {
				"ModeChanged",
				pattern = "*:*",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
			},
			static = {
				mode_names = {
					n = "N",
					no = "N?",
					nov = "N?",
					noV = "N?",
					["no\22"] = "N?",
					niI = "Ni",
					niR = "Nr",
					niV = "Nv",
					nt = "Nt",
					v = "V",
					vs = "Vs",
					V = "V-B",
					Vs = "Vs",
					["\22"] = "^V",
					["\22s"] = "^V",
					s = "S",
					S = "S_",
					["\19"] = "^S",
					i = "I",
					ic = "Ic",
					ix = "Ix",
					R = "R",
					Rc = "Rc",
					Rx = "Rx",
					Rv = "Rv",
					Rvc = "Rv",
					Rvx = "Rv",
					c = "C",
					cv = "Ex",
					r = "...",
					rm = "M",
					["r?"] = "?",
					["!"] = "!",
					t = "T",
				},
				mode_colors = {
					n = colors.blue2,
					i = colors.green,
					v = colors.magenta,
					V = colors.purple,
					["\22"] = colors.orange,
					c = colors.cyan,
					s = colors.yellow,
					S = colors.yellow,
					["\19"] = colors.yellow,
					r = colors.green,
					["!"] = colors.red,
					R = colors.red,
					t = colors.cyan,
				},
			},
			provider = function(self)
				return string.format("%s%s%s", " %1(", self.mode_names[self.mode], "%) ")
			end,
			hl = function(self)
				return { bg = self.mode_color, fg = colors.bg_statusline, bold = true }
			end,
		},
		{
			condition = conditions.is_git_repo,
			init = function(self)
				self.status_dict = vim.b.gitsigns_status_dict
			end,
			space,
			{
				provider = function(self)
					return fmt(" %s %s ", "", (self.status_dict.head == "" and "main" or self.status_dict.head))
				end,
				hl = { fg = colors.blue2, bg = colors.fg_gutter, bold = true },
			},
			space,
			{
				provider = function(self)
					local count = self.status_dict.added or 0
					return count > 0 and fmt("%s %d ", icons.git.added, count)
				end,
				hl = { fg = colors.green, bold = true, bg = colors.bg_statusline },
			},
			{
				provider = function(self)
					local count = self.status_dict.removed or 0
					return count > 0 and fmt("%s %d ", icons.git.removed, count)
				end,
				hl = { fg = colors.red, bold = true, bg = colors.bg_statusline },
			},
			{
				provider = function(self)
					local count = self.status_dict.changed or 0
					return count > 0 and fmt("%s %d ", icons.git.modified, count)
				end,
				hl = { fg = colors.yellow, bold = true, bg = colors.bg_statusline },
			},
		},

		{
			condition = function()
				return not vim.tbl_contains({ "prompt", "nofile", "terminal", "help", "quickfix" }, vim.bo.buftype)
					or vim.tbl_contains(
						{ "fugitive", "qf", "dbui", "dbout", "compilation", "Trouble", "Glance" },
						vim.bo.filetype
					)
					or vim.api.nvim_win_get_config(0).relative ~= ""
					or vim.api.nvim_buf_get_name(0) == ""
			end,
			space,
			{
				provider = function()
					local ft_icon, _ = require("nvim-web-devicons").get_icon_by_filetype(vim.bo.filetype)
					return fmt("%s  ", ft_icon or "")
				end,
				hl = function()
					local _, color = require("nvim-web-devicons").get_icon_color(vim.fn.expand("%:t"), vim.bo.filetype)
					return { bg = colors.bg_statusline, bold = true, italic = true, fg = color }
				end,
			},
			{
				provider = "%f",
				hl = { fg = colors.cyan, bg = colors.bg_statusline },
			},
		},
	},
	middle = {
		{ provider = "%=" },
		{
			condition = function()
				return #vim.api.nvim_list_tabpages() >= 2
			end,
			require("heirline.utils").make_tablist({
				provider = function(self)
					return string.format("%s%s%s%s%s", "%", self.tabnr, "T ", self.tabpage, " %T")
				end,
				hl = function(self)
					if self.is_active then
						return { bg = colors.blue1, bold = true, fg = colors.bg_statusline }
					else
						return { bg = colors.fg_gutter }
					end
				end,
			}),
		},
		{ provider = "%=" },
	},
	right = {
		{
			condition = conditions.has_diagnostics,
			init = function(self)
				self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
				self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
				self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
			end,
			update = { "DiagnosticChanged", "BufEnter" },
			{
				condition = function(self)
					return self.errors > 0
				end,
				hl = { fg = colors.error, bg = colors.bg_statusline, bold = true },
				provider = function(self)
					return fmt("%s %d ", icons.diagnostics.Error, self.errors)
				end,
			},
			-- Warnings
			{
				condition = function(self)
					return self.warnings > 0
				end,
				hl = { fg = colors.warning, bg = colors.bg_statusline, bold = true },
				provider = function(self)
					return fmt("%s %d ", icons.diagnostics.Warn, self.warnings)
				end,
			},
			-- Hints
			{
				condition = function(self)
					return self.hints > 0
				end,
				hl = { fg = colors.hint, bg = colors.bg_statusline, bold = true },
				provider = function(self)
					return fmt("%s %d ", icons.diagnostics.Hint, self.hints)
				end,
			},
			{
				condition = function(self)
					return self.info > 0
				end,
				hl = { fg = colors.info, bg = colors.bg_statusline, bold = true },
				provider = function(self)
					return fmt("%s %d ", icons.diagnostics.Info, self.info)
				end,
			},
		},

		{
			condition = require("lazy.status").has_updates,
			space,
			{
				provider = function()
					return fmt(" %s ", require("lazy.status").updates())
				end,
				hl = { bold = true, fg = colors.blue2, bg = colors.fg_gutter },
			},
		},
		{
			condition = conditions.lsp_attached,
			update = {
				"LspDetach",
				"LspAttach",
				"BufEnter",
				callback = vim.schedule_wrap(function()
					vim.cmd("redrawstatus")
				end),
			},
			space,
			{
				provider = function()
					if #vim.lsp.get_clients({ bufnr = 0 }) > 0 then
						return " LSP "
					end
				end,
				hl = function()
					return { fg = colors.blue1, bg = colors.fg_gutter, bold = true }
				end,
			},
		},
		{
			condition = require("noice").api.status.command.has,
			space,
			{
				provider = function()
					return fmt(" %s ", require("noice").api.status.command.get())
				end,
				hl = { bold = true, fg = colors.blue2, bg = colors.fg_gutter },
			},
		},
		{
			condition = require("noice").api.status.mode.has,
			space,
			{
				provider = function()
					return fmt(" %s ", require("noice").api.status.mode.get())
				end,
				hl = { bold = true, fg = colors.blue2, bg = colors.fg_gutter },
			},
		},
		space,
		{
			provider = function()
				return fmt(" %s ", vim.bo.filetype)
			end,
			hl = { bold = true, fg = colors.blue2, bg = colors.fg_gutter },
		},
		space,
		{
			provider = " %l:%c:%L ",
			hl = { fg = colors.bg_statusline, bg = colors.blue2, bold = true },
		},
	},
}

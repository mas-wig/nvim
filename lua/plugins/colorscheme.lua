local function hl_override(hl, c, util)
	hl.Visual = { bg = c.bg_visual, bold = true }
	hl.VisualNOS = { bg = c.bg_visual, bold = true }
	hl.WinBar = { bg = c.bg_statusline, underline = true, sp = util.darken(c.blue1, 0.8) }
	hl.CmpItemAbbr = { fg = "#ffffff", bg = c.none }
	hl.CmpItemAbbrMatch = { fg = c.cyan1, bg = c.none }
	hl.CmpItemAbbrMatchFuzzy = { fg = c.magenta2, bg = c.none }
	hl.PmenuSel = { bg = util.darken(c.purple, 0.4), bold = true }
	hl.WinBarNC = { bg = c.bg_statusline, underline = true, sp = util.darken(c.blue1, 0.8) }
	hl.StatusLine = { fg = c.fg_sidebar, bg = c.bg_statusline }
	hl.TreesitterContext = { underline = true, sp = util.darken(c.purple, 0.8) }
	hl.WinSeparator = { link = "Comment" }
	hl.LineNr = { fg = c.purple, bg = c.none, bold = true }
	hl.CursorLineNr = { fg = c.cyan, bg = c.none, bold = true }
	hl.FloatBorder = { link = "Comment" }

	-- Telescope
	hl.TelescopePreviewTitle = { fg = c.black, bg = c.yellow, bold = true }
	hl.TelescopePromptTitle = { fg = c.black, bg = c.blue1, bold = true }
	hl.TelescopeBorder = { link = "Comment" }
	-- Gitsign
	hl.GitSignsAdd = { fg = c.green1, bg = c.none }
	hl.GitSignsChange = { fg = c.yellow, bg = c.none }
	hl.GitSignsDelete = { fg = c.red1, bg = c.none }

	-- Mason
	hl.MasonHeader = { bg = c.red, fg = c.none }
	hl.MasonHighlight = { fg = c.blue }
	hl.MasonHighlightBlock = { fg = c.none, bg = c.green }
	hl.MasonHighlightBlockBold = { link = "MasonHighlightBlock" }
	hl.MasonHeaderSecondary = { link = "MasonHighlightBlock" }
	hl.MasonMuted = { fg = c.grey }
	hl.MasonMutedBlock = { fg = c.grey, bg = c.one_bg }

	-- Neotree
	hl.NeoTreeTabInactive = { fg = c.cyan, bg = c.none, bold = true }
	hl.NeoTreeTabActive = { fg = c.magenta2, bg = c.none, bold = true }
	hl.NeoTreeTabSeparatorInactive = { bg = c.none, fg = c.none }
	hl.NeoTreeTabSeparatorActive = { bg = c.none, fg = c.none }
	hl.NeoTreeFloatTitle = { link = "TelescopePreviewTitle" }
	hl.NeoTreeDirectoryIcon = { link = "OilDir" }

	-- Syntax
	hl.Constant = { fg = c.orange, italic = true }
	hl.String = { fg = c.green, italic = true }
	hl.Boolean = { fg = c.blue1, italic = true }
	hl.Function = { fg = c.blue, bold = true }
	hl.Conditional = { fg = c.cyan, italic = true }
	hl.Operator = { fg = c.blue5, bold = true }
	hl.Keyword = { fg = c.purple, italic = true }
	hl.Structure = { fg = c.magenta, italic = true }

	-- LSP
	hl.LspReferenceText = { italic = true, bold = true, reverse = true }
	hl.LspReferenceRead = { italic = true, bold = true, reverse = true }
	hl.LspReferenceWrite = { italic = true, bold = true, reverse = true }
	hl.LspSignatureActiveParameter = { italic = true, bold = true, reverse = true }
	hl.LspCodeLens = { link = "DiagnosticVirtualTextHint", default = true }
	hl.LspCodeLensText = { link = "DiagnosticVirtualTextHint", default = true }
	hl.LspCodeLensSign = { link = "DiagnosticVirtualTextHint", default = true }
	hl.LspCodeLensSeparator = { link = "Boolean", default = true }
	hl.DiagnosticFloatingError = { link = "DiagnosticError", default = true }
	hl.DiagnosticFloatingWarn = { link = "DiagnosticWarn", default = true }
	hl.DiagnosticFloatingInfo = { link = "DiagnosticInfo", default = true }
	hl.DiagnosticFloatingHint = { link = "DiagnosticHint", default = true }

	hl.OilDir = { default = true, link = "Directory" }
	hl.OilDirIcon = { link = "Directory" }
	hl.OilLink = { link = "Constant" }
	hl.OilLinkTarget = { link = "Comment" }
	hl.OilCopy = { link = "DiagnosticSignHint" }
	hl.OilMove = { link = "DiagnosticSignWarn" }
	hl.OilCreate = { link = "DiagnosticSignInfo" }
	hl.OilDelete = { link = "DiagnosticSignError" }
	hl.OilChange = { link = "DiagnosticSignWarn" }
	hl.OilPermissionRead = { fg = c.yellow1, bold = true }
	hl.OilPermissionNone = { link = "NonText" }
	hl.OilPermissionWrite = { fg = c.green2, bold = true }
	hl.OilPermissionExecute = { fg = c.magenta2, bold = true }
	hl.OilTypeDir = { link = "Directory" }
	hl.OilTypeFifo = { link = "Special" }
	hl.OilTypeFile = { link = "NonText" }
	hl.OilTypeLink = { link = "Constant" }
	hl.FzfLuaBorder = { link = "Comment" }
end

return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			transparent = false,
			styles = { sidebars = "normal", floats = "normal" },
			sidebars = { "toggleterm", "qf", "oil", "help", "terminal", "neotest-summary", "dashboard" },
			on_highlights = function(hl, c)
				return hl_override(hl, c, require("tokyonight.util"))
			end,
			on_colors = function(c)
				c.green2 = "#2bff05"
				c.yellow1 = "#faf032"
				c.cyan1 = "#00ffee"
				c.purple1 = "#f242f5"
				c.red2 = "#eb0000"
			end,
		})
		vim.cmd.colorscheme("tokyonight-night")
	end,
}

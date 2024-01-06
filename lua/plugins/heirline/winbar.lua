local colors, color_util = require("tokyonight.colors").setup(), require("tokyonight.util")

return {
	condition = package.loaded["nvim-navic"] and require("nvim-navic").is_available(),
	update = "CursorMoved",
	static = {
		type_hl = {
			File = "Directory",
			Module = "@include",
			Namespace = "@namespace",
			Package = "@include",
			Class = "@structure",
			Method = "@method",
			Property = "@property",
			Field = "@field",
			Constructor = "@constructor",
			Enum = "@field",
			Interface = "@type",
			Function = "@function",
			Variable = "@variable",
			Constant = "@constant",
			String = "@string",
			Number = "@number",
			Boolean = "@boolean",
			Array = "@field",
			Object = "@type",
			Key = "@keyword",
			Null = "@comment",
			EnumMember = "@field",
			Struct = "@structure",
			Event = "@keyword",
			Operator = "@operator",
			TypeParameter = "@type",
		},
		enc = function(line, col, winnr)
			return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
		end,
		-- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
		dec = function(col)
			return bit.rshift(col, 16), bit.band(bit.rshift(col, 6), 1023), bit.band(col, 63)
		end,
	},
	init = function(self)
		local data = require("nvim-navic").get_data() or {}
		local children = {}
		for i, d in ipairs(data) do
			local child = {
				{ provider = string.format("%s ", d.icon), hl = self.type_hl[d.type] }, -- link to item kind
				{
					provider = d.name:gsub("%%", "%%%%"):gsub("%s*-->%s*", ""),
					hl = self.type_hl[d.type],
					on_click = {
						minwid = self.enc(d.scope.start.line, d.scope.start.character, self.winnr),
						callback = function(_, minwid)
							local line, col, winnr = self.dec(minwid)
							vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), { line, col })
						end,
						name = "heirline_navic",
					},
				},
			}
			if #data > 1 and i < #data then
				table.insert(
					child,
					{ provider = " --> ", hl = { bg = colors.bg_statusline, fg = colors.red, bold = true } }
				)
			end
			table.insert(children, child)
		end
		self.child = self:new(children, 1)
	end,
	provider = function(self)
		return self.child:eval()
	end,
	hl = function()
		return {
			bg = colors.bg_statusline,
			underline = true,
			sp = color_util.darken(colors.blue1, 0.8),
			italic = true,
		}
	end,
}

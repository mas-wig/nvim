local v, fn, api = vim.v, vim.fn, vim.api
local conditions = require("heirline.conditions")
return {
	condition = function()
		return not conditions.buffer_matches({
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
				"^toggleterm$",
				"^dbui$",
				"^dbout$",
				"^oil$",
			},
		})
	end,
	static = {
		get_extmarks = function(self, bufnr, lnum)
			local signs = {}
			local extmarks = api.nvim_buf_get_extmarks(
				0,
				bufnr,
				{ lnum - 1, 0 },
				{ lnum - 1, -1 },
				{ details = true, type = "sign" }
			)
			for _, extmark in pairs(extmarks) do
				-- Exclude gitsigns
				if extmark[4].ns_id ~= self.git_ns then
					signs[#signs + 1] = {
						name = extmark[4].sign_hl_group or "",
						text = extmark[4].sign_text,
						sign_hl_group = extmark[4].sign_hl_group,
						priority = extmark[4].priority,
					}
				end
			end
			-- Sort by priority
			table.sort(signs, function(a, b)
				return (a.priority or 0) > (b.priority or 0)
			end)
			return signs
		end,
		git_ns = api.nvim_create_namespace("gitsigns_extmark_signs_"),
		click_args = function(self, minwid, clicks, button, mods)
			local args = { minwid = minwid, clicks = clicks, button = button, mods = mods, mousepos = fn.getmousepos() }
			local sign = fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol)
			if sign == " " then
				sign = fn.screenstring(args.mousepos.screenrow, args.mousepos.screencol - 1)
			end
			args.sign = self.signs[sign]
			api.nvim_set_current_win(args.mousepos.winid)
			api.nvim_win_set_cursor(0, { args.mousepos.line, 0 })

			return args
		end,
		resolve = function(self, name)
			for pattern, callback in pairs(self.handlers.Signs) do
				if name:match(pattern) then
					return vim.defer_fn(callback, 100)
				end
			end
		end,
		handlers = {
			Signs = {
				["Neotest.*"] = function()
					require("neotest").run.run()
				end,
				["Debug.*"] = function()
					require("dap").continue()
				end,
				["Diagnostic.*"] = function()
					vim.diagnostic.open_float()
				end,
				["LspLightBulb"] = function()
					vim.lsp.buf.code_action()
				end,
			},
			Dap = function()
				require("dap").toggle_breakpoint()
			end,
			GitSigns = function()
				vim.defer_fn(function()
					require("gitsigns").blame_line({ full = true })
				end, 100)
			end,
		},
	},
	init = function(self)
		self.signs = {}
	end,
	{
		init = function(self)
			local signs = self.get_extmarks(self, -1, v.lnum)
			self.sign = signs[1]
		end,
		provider = function(self)
			return self.sign and self.sign.text:gsub("%s+", " ") or ""
		end,
		hl = function(self)
			return self.sign and self.sign.sign_hl_group
		end,
		on_click = {
			name = "sc_sign_click",
			update = true,
			callback = function(self, ...)
				local line = self.click_args(self, ...).mousepos.line
				local sign = self.get_extmarks(self, -1, line)[1]
				if sign then
					self:resolve(sign.name)
				end
			end,
		},
	},
	{ provider = "%=" },
	{
		provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
		on_click = {
			name = "sc_linenumber_click",
			callback = function(self, ...)
				self.handlers.Dap(self.click_args(self, ...))
			end,
		},
	},
	{
		{
			condition = function()
				return conditions.is_git_repo() and v.virtnum == 0
			end,
			init = function(self)
				local extmark = api.nvim_buf_get_extmarks(
					0,
					self.git_ns,
					{ v.lnum - 1, 0 },
					{ v.lnum - 1, -1 },
					{ limit = 1, details = true }
				)[1]
				self.sign = extmark and extmark[4]["sign_hl_group"]
			end,
			provider = "▍",
			hl = function(self)
				return self.sign or { fg = "bg" }
			end,
			on_click = {
				name = "sc_gitsigns_click",
				callback = function(self, ...)
					self.handlers.GitSigns(self.click_args(self, ...))
				end,
			},
		},
		{
			condition = function()
				return not conditions.is_git_repo() or v.virtnum ~= 0
			end,
			provider = "",
			hl = "HeirlineStatusColumn",
		},
	},
	{ provider = " " },
}

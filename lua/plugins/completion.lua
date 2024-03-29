return {
	{ "hrsh7th/cmp-nvim-lsp", event = "LspAttach" },
	{ "saadparwaiz1/cmp_luasnip", event = "InsertEnter" },
	{ "FelipeLema/cmp-async-path", event = { "InsertEnter" } },
	{ "lukas-reineke/cmp-rg", event = "InsertEnter" },
	{ "hrsh7th/cmp-cmdline", event = "InsertEnter" },
	{ "rafamadriz/friendly-snippets", event = "InsertEnter" },
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		build = "make install_jsregexp",
		config = function()
			local luasnip = require("luasnip")
			local t = require("luasnip.util.types")
			luasnip.setup({
				keep_roots = true,
				link_roots = false,
				link_children = true,
				region_check_events = "CursorMoved,CursorMovedI",
				delete_check_events = "TextChanged,TextChangedI",
				ext_base_prio = 300,
				ft_func = require("luasnip.extras.filetype_functions").from_cursor_pos,
				store_selection_keys = "<Tab>",
				ext_opts = {
					[t.choiceNode] = { active = { virt_text = { { "│", "NeoTreeTabActive" } } } },
					[t.insertNode] = { unvisited = { virt_text = { { "│", "NonText" } }, virt_text_pos = "inline" } },
					[t.exitNode] = { unvisited = { virt_text = { { "│", "NonText" } }, virt_text_pos = "inline" } },
				},
			})
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		lazy = true,
		config = function()
			local luasnip, cmp, fmt, cmp_core = require("luasnip"), require("cmp"), string.format, require("cmp.core")
			local _cmp_on_change, last_changed, cmdline = cmp_core.on_change, 0, cmp.setup.cmdline

			-- optimize on big file
			function cmp_core.on_change(self, trigger_event)
				local now = vim.uv.now()
				local fast_typing = now - last_changed < 16
				last_changed = now
				if not fast_typing or trigger_event ~= "TextChanged" or cmp.visible() then
					_cmp_on_change(self, trigger_event)
					return
				end
				vim.defer_fn(function()
					if last_changed == now then
						_cmp_on_change(self, trigger_event)
					end
				end, 200)
			end

			local function contains_any(s, patterns)
				for _, p in ipairs(patterns) do
					if type(s) == "string" and s:find(p, 1, true) then
						return true
					end
				end
				return false
			end

			local has_words_before = function()
				local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				completion = { completeopt = "menu,menuone,noinsert" },
				experimental = { ghost_text = { hl_group = "CmpGhostText" } },
				sorting = {
					comparators = {
						function(lhs, rhs)
							return lhs:get_kind() > rhs:get_kind()
						end,
						cmp.config.compare.offset,
						cmp.config.compare.exact,
						cmp.config.compare.score,
						function(lhs, rhs)
							lhs:get_kind()
							local _, lhs_under = lhs.completion_item.label:find("^_+")
							local _, rhs_under = rhs.completion_item.label:find("^_+")
							lhs_under = lhs_under or 0
							rhs_under = rhs_under or 0
							return lhs_under < rhs_under
						end,
						cmp.config.compare.kind,
						cmp.config.compare.sort_text,
						cmp.config.compare.length,
						cmp.config.compare.order,
					},
				},
				performance = { async_budget = 1, max_view_entries = 64 },
				enabled = function()
					local context = require("cmp.config.context")
					if
						vim.tbl_contains({ "prompt" }, vim.bo.buftype)
						or vim.tbl_contains({ "oil" }, vim.bo.filetype)
						or vim.fn.reg_recording() ~= ""
						or vim.fn.reg_executing() ~= ""
						or context.in_treesitter_capture("comment")
						or vim.b.bigfile
					then
						return false
					end
					return true
				end,
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				matching = {
					disallow_fuzzy_matching = false,
					disallow_fullfuzzy_matching = false,
					disallow_partial_fuzzy_matching = false,
					disallow_partial_matching = false,
					disallow_prefix_unmatching = false,
				},
				window = {
					completion = {
						scrollbar = false,
						winhighlight = "CmpMenu:CmpMenu,FloatBorder:Comment,CursorLine:PmenuSel",
						side_padding = 1,
						border = vim.g.border,
					},
					documentation = {
						winhighlight = "CmpMenu:CmpMenu,FloatBorder:Comment,CursorLine:PmenuSel",
						max_width = math.max(15, math.ceil(vim.go.columns * 0.41)),
						max_height = math.max(10, math.ceil(vim.go.lines * 0.4)),
						border = vim.g.border,
					},
				},
				mapping = {
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s", "c" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s", "c" }),
					["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i" }),
					["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i" }),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<S-CR>"] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
					["<C-CR>"] = function(fallback)
						cmp.abort()
						fallback()
					end,
				},
				sources = cmp.config.sources({
					{ name = "luasnip", max_item_count = 4, priority = 600 },
					{
						name = "async_path",
						priority = 1000,
						option = {
							get_cwd = function()
								return require("utils.dir").root()
							end,
						},
					},
					{
						name = "nvim_lsp",
						max_item_count = 20,
						entry_filter = function(entry, ctx)
							local item, ft = entry:get_completion_item(), ctx.filetype
							local boilerplate_method =
								contains_any(item.label, { "ReadField", "FastRead", "WriteField", "FastWrite" })
							if ft == "go" and boilerplate_method then
								return false
							end
							return true
						end,
						priority = 900,
					},
					{
						name = "rg",
						keyword_length = 5,
						priority = 300,
						priority_weight = 70,
						option = { additional_arguments = "--smart-case --hidden" },
						entry_filter = function(entry)
							return not entry.exact
						end,
					},
				}),
				formatting = {
					fields = { "kind", "abbr", "menu" },
					format = function(_, vim_item)
						local icons = require("utils.icons").kinds
						if vim_item.kind == "Folder" then
							vim_item.kind = icons.Folder
							vim_item.kind_hl_group = "Directory"
						elseif vim_item.kind == "File" then
							local icon, icon_hl = require("nvim-web-devicons").get_icon(
								vim.fs.basename(vim_item.word),
								vim.fn.fnamemodify(vim_item.word, ":e"),
								{ default = true }
							)
							vim_item.kind = icon or icons.File
							vim_item.kind_hl_group = icon_hl or "CmpItemKindFile"
						else
							vim_item.menu = vim_item.kind
							vim_item.menu_hl_group = "CmpItemKind" .. vim_item.kind
							vim_item.kind = icons[vim_item.kind] or " "
						end

						local function clamp(field, min_width, max_width)
							if not vim_item[field] or not type(vim_item) == "string" then
								return
							end
							if min_width > max_width then
								min_width, max_width = max_width, min_width
							end
							local field_str = vim_item[field]
							local field_width = vim.fn.strdisplaywidth(field_str)
							if field_width > max_width then
								local former_width = math.floor(max_width * 0.6)
								local latter_width = math.max(0, max_width - former_width - 1)
								vim_item[field] =
									fmt("%s󰇘%s", field_str:sub(1, former_width), field_str:sub(-latter_width))
							elseif field_width < min_width then
								vim_item[field] = fmt("%-" .. min_width .. "s", field_str)
							end
						end
						clamp("abbr", vim.go.pw, math.max(10, math.ceil(vim.api.nvim_win_get_width(0) * 0.24)))
						clamp("menu", 0, math.max(10, math.ceil(vim.api.nvim_win_get_width(0) * 0.10)))
						return vim_item
					end,
				},
			})

			cmdline("/", {
				formatting = { fields = { cmp.ItemField.Abbr } },
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "rg", keyword_length = 5 } },
			})
			cmdline("?", {
				formatting = { fields = { cmp.ItemField.Abbr } },
				mapping = cmp.mapping.preset.cmdline(),
				sources = { { name = "rg", keyword_length = 5 } },
			})

			cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				formatting = { fields = { cmp.ItemField.Abbr } },
				sources = {
					{ name = "cmdline", group_index = 1 },
					{ name = "async_path", group_index = 2 },
				},
			})
			cmdline("@", { enabled = false })
			cmdline(">", { enabled = false })
			cmdline("-", { enabled = false })
			cmdline("=", { enabled = false })
		end,
	},
}

local diagIcons = require("utils.icons").diagnostics
return {
	disable_defaults = false,
	go = "go",
	goimport = "gopls",
	fillstruct = "fillstruct",
	gofmt = "gofumpt",
	max_line_len = 128,
	tag_transform = false,
	tag_options = "json=omitempty",
	icons = false,
	verbose = false,
	lsp_cfg = true,
	lsp_gofumpt = false,
	lsp_keymaps = false,
	lsp_codelens = true,
	lsp_document_formatting = true,
	lsp_inlay_hints = { enable = false },
	sign_priority = 5,
	dap_debug = false,
	dap_debug_keymap = false,
	textobjects = false,
	trouble = true,
	test_efm = false,
	luasnip = true,
	iferr_vertical_shift = 4,
	lsp_on_attach = function(client, _)
		if not client.server_capabilities.semanticTokensProvider then
			local semantic = client.config.capabilities.textDocument.semanticTokens
			client.server_capabilities.semanticTokensProvider = {
				full = true,
				legend = { tokenTypes = semantic.tokenTypes, tokenModifiers = semantic.tokenModifiers },
				range = true,
			}
		end
	end,
	diagnostic = {
		underline = true,
		update_in_insert = false,
		severity_sort = true,
		signs = {
			text = { [1] = diagIcons.Error, [2] = diagIcons.Warn, [3] = diagIcons.Hint, [4] = diagIcons.Info },
		},
		virtual_text = {
			spacing = 4,
			source = "if_many",
			prefix = "",
			format = function(d)
				local icons = {}
				for key, value in pairs(diagIcons) do
					icons[key:upper()] = value
				end
				return string.format(" %s : %s ", icons[vim.diagnostic.severity[d.severity]], d.message)
			end,
		},
		float = {
			format = function(d)
				return string.format(" [%s] : %s ", d.source, d.message)
			end,
			source = "if_many",
			severity_sort = true,
			wrap = true,
			border = vim.g.border,
			max_width = math.floor(vim.o.columns / 2),
			max_height = math.floor(vim.o.lines / 3),
		},
	},
}

local diagIcons = require("utils.icons").diagnostics
return require("go").setup({
	disable_defaults = false,
	go = "go",
	goimport = "goimports",
	fillstruct = "gopls",
	gofmt = false,
	max_line_len = 128,
	tag_transform = false,
	tag_options = "",
	icons = false,
	verbose = false,
	lsp_cfg = {
		capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
		settings = {
			gopls = {
				gofumpt = false,
				codelenses = {
					gc_details = false,
					generate = true,
					regenerate_cgo = true,
					run_govulncheck = true,
					test = true,
					tidy = true,
					upgrade_dependency = true,
					vendor = true,
				},
				hints = {
					assignVariableTypes = true,
					compositeLiteralFields = true,
					compositeLiteralTypes = true,
					constantValues = true,
					functionTypeParameters = true,
					parameterNames = true,
					rangeVariableTypes = true,
				},
				analyses = {
					fieldalignment = true,
					nilness = true,
					unusedparams = true,
					unusedwrite = true,
					useany = true,
					unreachable = true,
					ST1003 = true,
					undeclaredname = true,
					fillreturns = true,
					nonewvars = true,
					shadow = true,
				},
				usePlaceholders = true,
				completeUnimported = true,
				staticcheck = true,
				directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
				semanticTokens = true,
				matcher = "Fuzzy",
				diagnosticsDelay = "500ms",
				symbolMatcher = "fuzzy",
				buildFlags = { "-tags", "integration" },
			},
		},
	},
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
	lsp_on_attach = function(client, bufnr)
		require("plugins.lspconfig.default").on_attach(client, bufnr)
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
			text = {
				[vim.diagnostic.severity.ERROR] = diagIcons.Error,
				[vim.diagnostic.severity.WARN] = diagIcons.Warn,
				[vim.diagnostic.severity.INFO] = diagIcons.Hint,
				[vim.diagnostic.severity.HINT] = diagIcons.Info,
			},
			numhl = {
				[vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
				[vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
				[vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
				[vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
			},
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
})

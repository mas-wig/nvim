return {
	{
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		config = function()
			require("nvim-lightbulb").setup({
				autocmd = { enabled = true },
				-- ignore = { clients = { "lua_ls" }, ft = { "lua" } },
				validate_config = "always",
				action_kinds = {
					"source",
					"source.organizeImports",
					"quickfix",
					"refactor",
					"refactor.extract",
					"refactor.inline",
					"refactor.rewrite",
				},
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
			local opts =
				require("lazy.core.plugin").values(require("lazy.core.config").plugins["conform.nvim"], "opts", false)
			local c = require("conform")
			-- just like vim.tbl_deep_extend()
			c.format(require("lazy.core.util").merge(opts.format, { bufnr = vim.api.nvim_get_current_buf() }))
			c.setup({
				format_on_save = { timeout_ms = 5000, lsp_fallback = true },
				formatters_by_ft = {
					["lua"] = { "stylua" },
					["go"] = { "goimports" },
					["javascript"] = { "prettierd" },
					["javascriptreact"] = { "prettierd" },
					["typescript"] = { "prettierd" },
					["typescriptreact"] = { "prettierd" },
					["vue"] = { "prettierd" },
					["css"] = { "prettierd" },
					["scss"] = { "prettierd" },
					["less"] = { "prettierd" },
					["html"] = { "prettierd" },
					["json"] = { "prettierd" },
					["jsonc"] = { "prettierd" },
					["yaml"] = { "prettierd" },
					["markdown"] = { "prettierd" },
					["markdown.mdx"] = { "prettierd" },
					["graphql"] = { "prettierd" },
					["handlebars"] = { "prettierd" },
					["cpp"] = { "clang-format" },
					["c"] = { "clang-format" },
					["sql"] = { "sqlfmt" },
					["mysql"] = { "sqlfmt" },
				},
			})
		end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			max_concurrent_installers = 10,
			PATH = "prepend",
			ensure_installed = {
				"codelldb",
				"clangd",
				"lua-language-server",
				"rust-analyzer",
				"typescript-language-server",
				"phpactor",
				"nomicfoundation-solidity-language-server",
				"solidity",
				"htmx-lsp",
				"templ",
				"html-lsp",
				"css-lsp",
				"marksman",
				"sqlls",

				-- linter
				"solhint",
				"selene",
				"phpcs",
				"phpstan",
				"php-cs-fixer",
				"cpplint",
				"vale",
				"biome",
				"eslint_d",
				"golangci-lint",
				"staticcheck",

				"clang-format",
				"stylua",
				"prettierd",
				"sqlfmt",
				"goimports",
				"goimports-reviser",
			},
		},
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)
			local function ensure_installed()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end
			if mr.refresh then
				mr.refresh(ensure_installed)
			else
				ensure_installed()
			end
		end,
	},
	{
		"neovim/nvim-lspconfig",
		event = "FileType",
		config = function()
			local default = require("plugins.lspconfig.default")
			local function create_lsp_config(key)
				local config = require("plugins.lspconfig.servers")[key]
				if not config then
					config = vim.deepcopy(default)
				else
					config = vim.tbl_deep_extend("force", default, config)
				end
				return config
			end

			local function soft_stop_client(client, force, num_trials)
				if
					client.is_stopped() ---@diagnostic disable-line: invisible
					or not vim.tbl_isempty(vim.lsp.get_buffers_by_client_id(client.id))
				then
					return
				end
				num_trials = num_trials or 3 --max num by default its 4
				if force or num_trials <= 0 then
					vim.notify("[LSP] force stopping detached client " .. client.name)
					client.stop(true)
					return
				end
				client.stop()
				vim.defer_fn(function()
					soft_stop_client(client, force, num_trials - 1)
				end, 500)
			end

			local lsp_autostop_pending
			vim.api.nvim_create_autocmd("BufDelete", {
				group = vim.api.nvim_create_augroup("LspAutoStop", {}),
				desc = "Automatically stop idle language servers.",
				callback = function()
					if lsp_autostop_pending then
						return
					end
					lsp_autostop_pending = true
					vim.defer_fn(function()
						lsp_autostop_pending = nil
						for _, client in ipairs(vim.lsp.get_clients()) do
							if vim.tbl_isempty(vim.lsp.get_buffers_by_client_id(client.id)) then
								soft_stop_client(client)
							end
						end
					end, 60000)
				end,
			})

			for name, icon in pairs(require("utils.icons").diagnostics) do
				name = "DiagnosticSign" .. name
				vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			end
			vim.diagnostic.config(require("utils").diagnostic_conf)
			vim.schedule(function()
				local lspconfig, methods = require("lspconfig"), vim.lsp.protocol.Methods
				require("lspconfig.ui.windows").default_options.border = "single"
				vim.api.nvim_create_autocmd("VimResized", {
					desc = "Reload LspInfo floating window on VimResized.",
					group = vim.api.nvim_create_augroup("LspInfoResize", {}),
					callback = function()
						if vim.bo.ft == "lspinfo" then
							vim.api.nvim_win_close(0, true)
							vim.cmd.LspInfo()
						end
					end,
				})

				local lang_servers, ft_servers =
					{
						lua = { "lua_ls" },
						c = { "clangd" },
						cpp = { "clangd" },
						markdown = { "marksman" },
						rust = { "rust-analyzer" },
						solidity = { "solidity_ls_nomicfoundation" },
						php = { "phpactor" },
						html = { "html-lsp" },
						css = { "css-lsp" },
						sql = { "sqlls" },
					}, {}

				for langs, sname in pairs(lang_servers) do
					ft_servers[langs] = sname
				end

				local function setup_ft(ft)
					local servers = ft_servers[ft]
					if not servers then
						return false
					end
					if type(servers) ~= "table" then
						servers = { servers }
					end
					for _, server in ipairs(servers) do
						lspconfig[server].setup(create_lsp_config(server))
					end
					ft_servers[ft] = nil
					vim.api.nvim_exec_autocmds("FileType", { pattern = ft })
					return true
				end

				for _, buf in ipairs(vim.api.nvim_list_bufs()) do
					setup_ft(vim.bo[buf].ft)
				end

				local groupid = vim.api.nvim_create_augroup("LspServerLazySetup", {})
				for ft, _ in pairs(ft_servers) do
					vim.api.nvim_create_autocmd("FileType", {
						once = true,
						pattern = ft,
						group = groupid,
						callback = function()
							return setup_ft(ft)
						end,
					})
				end

				local register_capability = vim.lsp.handlers[methods.client_registerCapability]
				vim.lsp.handlers[methods.client_registerCapability] = function(err, res, ctx)
					local client = vim.lsp.get_client_by_id(ctx.client_id)
					if not client then
						return
					end
					default.on_attach(client, vim.api.nvim_get_current_buf())
					return register_capability(err, res, ctx)
				end

				local hide = vim.diagnostic.handlers.virtual_text.hide
				local show = vim.diagnostic.handlers.virtual_text.show
				vim.diagnostic.handlers.virtual_text = {
					show = function(ns, bufnr, diagnostics, opts)
						table.sort(diagnostics, function(diag1, diag2)
							return diag1.severity > diag2.severity
						end)
						return show(ns, bufnr, diagnostics, opts)
					end,
					hide = hide,
				}
			end)
		end,
	},
}

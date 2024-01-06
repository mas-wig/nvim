return {
	{
		"kosayoda/nvim-lightbulb",
		event = "LspAttach",
		config = function()
			require("nvim-lightbulb").setup({ autocmd = { enabled = true } })
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		opts = {
			format_on_save = { timeout_ms = 500, lsp_fallback = true },
			formatters_by_ft = { lua = { "stylua" }, go = { "goimports" } },
		},
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		build = ":MasonUpdate",
		opts = {
			ensure_installed = {
				"clangd",
				"stylua",
				"lua-language-server",
				"rust-analyzer",
				"codelldb",
				"typescript-language-server",
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

				local lang_servers = { lua = { "lua_ls" }, c = { "clangd" }, cpp = { "clangd" } }

				local ft_servers = {}
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

				local show_handler = vim.diagnostic.handlers.virtual_text.show
				local hide_handler = vim.diagnostic.handlers.virtual_text.hide
				vim.diagnostic.handlers.virtual_text = {
					show = function(ns, bufnr, diagnostics, opts)
						table.sort(diagnostics, function(diag1, diag2)
							return diag1.severity > diag2.severity
						end)
						return show_handler(ns, bufnr, diagnostics, opts)
					end,
					hide = hide_handler,
				}

				local diagIcons = require("utils.icons").diagnostics
				vim.diagnostic.config({
					underline = true,
					update_in_insert = false,
					severity_sort = true,
					signs = {
						text = {
							[1] = diagIcons.Error,
							[2] = diagIcons.Warn,
							[3] = diagIcons.Hint,
							[4] = diagIcons.Info,
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
				})
			end)
		end,
	},
}

return {
	tools = { hover_actions = { replace_builtin_hover = false } },
	server = {
		on_attach = function(client, bufnr)
			return require("plugins.lspconfig.default").on_attach(client, bufnr)
		end,
		settings = {
			["rust-analyzer"] = {
				cargo = { allFeatures = true, loadOutDirsFromCheck = true, runBuildScripts = true },
				checkOnSave = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
				procMacro = {
					enable = true,
					ignored = {
						["async-trait"] = { "async_trait" },
						["napi-derive"] = { "napi" },
						["async-recursion"] = { "async_recursion" },
					},
				},
			},
		},
	},
}

return {
	marksman = {
		filetypes = { "markdown", "markdown.mdx" },
	},
	lua_ls = {
		on_init = function(client)
			local path = client.workspace_folders[1].name
			if not vim.uv.fs_stat(path .. "/.luarc.json") and not vim.uv.fs_stat(path .. "/.luarc.jsonc") then
				client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
					Lua = {
						hint = { enable = true },
						runtime = { version = "LuaJIT" },
						workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
						diagnostic = { enable = false },
					},
				})
				client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
			end
			return true
		end,
		settings = {
			lua = {
				completion = { callsnippet = "replace" },
				diagnostics = { enable = true },
				workspace = { checkthirdparty = false },
				telemetry = { enable = false },
			},
		},
	},
}

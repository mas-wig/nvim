return {
	lua_ls = {
		settings = {
			lua = {
				completion = { callsnippet = "replace" },
				diagnostics = {
					enable = true,
					globals = {
						"vim",
						"describe",
						"it",
						"before_each",
						"after_each",
						"teardown",
						"pending",
						"s",
						"i",
						"fmt",
						"rep",
						"conds",
						"f",
						"c",
						"t",
					},
				},
				hint = { enable = true },
				workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
				telemetry = { enable = false },
				runtime = { version = "LuaJIT", path = { "?.lua", "?/init.lua" } },
				format = { enable = false },
			},
		},
	},
}

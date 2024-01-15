local A = {}

A.codelldb = {
	type = "server", -- change to executeable
	port = "${port}",
	executable = {
		command = require("mason-registry").get_package("codelldb"):get_install_path() .. "/codelldb",
		args = { "--port", "${port}" },
	},
}

return A

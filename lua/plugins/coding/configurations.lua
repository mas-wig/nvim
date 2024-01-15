local C = {}

local cache = { cpp = { args = {} } }

C.cpp = {
	{
		type = "codelldb",
		name = "Launch file",
		request = "launch",
		program = function()
			local program
			vim.ui.input({
				prompt = "Enter path to executable: ",
				default = require("mason-registry").get_package("codelldb"):get_install_path() .. "/codelldb"
					or cache.cpp.program,
				completion = "file",
			}, function(input)
				program = input
				cache.cpp.program = program
				vim.cmd.stopinsert()
			end)
			return vim.fn.fnamemodify(program, ":p")
		end,
		args = function()
			local args = ""
			local fpath_base = vim.fn.expand("%:p:r")
			vim.ui.input({
				prompt = "Enter arguments: ",
				default = cache.cpp.program and cache.cpp.args[cache.cpp.program] or cache.cpp.args[fpath_base],
				completion = "file",
			}, function(input)
				args = input
				cache.cpp.args[cache.cpp.program or fpath_base] = args
				vim.cmd.stopinsert()
			end)
			return vim.split(args, " ")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

C.c = C.cpp

C.rust = C.cpp

return C

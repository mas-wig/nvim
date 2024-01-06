local A = {}

local mason_registry = require("mason-registry")
local codelldb = mason_registry.get_package("codelldb")
local extension_path = codelldb:get_install_path() .. "/extension/"
local codelldb_path = extension_path .. "adapter/codelldb"
local liblldb_path = ""
if vim.uv.os_uname().sysname:find("Windows") then
	liblldb_path = extension_path .. "lldb\\bin\\liblldb.dll"
elseif vim.fn.has("mac") == 1 then
	liblldb_path = extension_path .. "lldb/lib/liblldb.dylib"
else
	liblldb_path = extension_path .. "lldb/lib/liblldb.so"
end

A.delve =
	{ type = "server", port = "${port}", executable = { command = "dlv", args = { "dap", "-l", "127.0.0.1:${port}" } } }

A.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = tostring(codelldb_path),
		args = { "--liblldb", tostring(liblldb_path), "--port", "${port}" },
	},
}

return A

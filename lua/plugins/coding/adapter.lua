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

A.delve = function(callback, config)
	local stdout = vim.loop.new_pipe(false)
	local handle
	local pid_or_err
	local host = config.host or "127.0.0.1"
	local port = config.port or "38697"
	local addr = string.format("%s:%s", host, port)
	local opts = {
		stdio = { nil, stdout },
		args = { "dap", "-l", addr },
		detached = true,
	}
	handle, pid_or_err = vim.loop.spawn("dlv", opts, function(code)
		stdout:close()
		handle:close()
		if code ~= 0 then
			print("dlv exited with code", code)
		end
	end)
	assert(handle, "Error running dlv: " .. tostring(pid_or_err))
	stdout:read_start(function(err, chunk)
		assert(not err, err)
		if chunk then
			vim.schedule(function()
				require("dap.repl").append(chunk)
			end)
		end
	end)
	vim.defer_fn(function()
		callback({ type = "server", host = "127.0.0.1", port = port })
	end, 100)
end

A.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		command = tostring(codelldb_path),
		args = { "--liblldb", tostring(liblldb_path), "--port", "${port}" },
	},
}

return A

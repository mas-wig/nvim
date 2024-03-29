local utils = require("lazy.core.util")

local M = {}

function M.option(option, silent, values)
	if values then
		if vim.opt_local[option]:get() == values[1] then
			vim.opt_local[option] = values[2]
		else
			vim.opt_local[option] = values[1]
		end
		return utils.info("Set " .. option .. " to " .. vim.opt_local[option]:get(), { title = "Option" })
	end
	vim.opt_local[option] = not vim.opt_local[option]:get()
	if not silent then
		if vim.opt_local[option]:get() then
			utils.info("Enabled " .. option, { title = "Option" })
		else
			utils.warn("Disabled " .. option, { title = "Option" })
		end
	end
end

local nu = { number = true, relativenumber = true }

function M.number()
	if vim.opt_local.number:get() or vim.opt_local.relativenumber:get() then
		nu = { number = vim.opt_local.number:get(), relativenumber = vim.opt_local.relativenumber:get() }
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
		utils.warn("Disabled line numbers", { title = "Option" })
	else
		vim.opt_local.number = nu.number
		vim.opt_local.relativenumber = nu.relativenumber
		utils.info("Enabled line numbers", { title = "Option" })
	end
end

local enabled = true
function M.diagnostics()
	enabled = not enabled
	if enabled then
		vim.diagnostic.enable()
		utils.info("Enabled diagnostics", { title = "Diagnostics" })
	else
		vim.diagnostic.disable()
		utils.warn("Disabled diagnostics", { title = "Diagnostics" })
	end
end

function M.inlay_hints(buf, value)
	local ih = vim.lsp.buf.inlay_hint or vim.lsp.inlay_hint
	if type(ih) == "function" then
		ih(buf, value)
	elseif type(ih) == "table" and ih.enable then
		if value == nil then
			value = not ih.is_enabled(buf)
		end
		ih.enable(buf, value)
	end
end

function M.get_upvalue_ctx(func, name)
	local i = 1
	while true do
		local n, v = debug.getupvalue(func, i)
		if not n then
			break
		end
		if n == name then
			return v
		end
		i = i + 1
	end
end

setmetatable(M, {
	__call = function(m, ...)
		return m.option(...)
	end,
})

return M

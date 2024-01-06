return {
	modules = { maps = false },
	filetypes = { md = true, rmd = true, markdown = true },
	create_dirs = true,
	perspective = {
		priority = "first",
		fallback = "current",
		root_tell = false,
		nvim_wd_heel = false,
		update = false,
	},
	wrap = true,
	silent = false,
	links = {
		style = "markdown",
		name_is_source = false,
		conceal = true,
		context = 0,
		transform_explicit = function()
			math.randomseed(os.time())
			local len = 7
			local chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
			local name = ""
			for _ = 1, len do
				local ridx = math.random(1, #chars)
				name = string.format("%s%s", name, string.sub(chars, ridx, ridx))
			end
			if string.len(name) > len then
				string.lower(name:gsub(" ", "_"))
			end
			return string.format("%s_%s%s", os.date("%d%m%Y"), os.date("%S"), name)
		end,
	},
	to_do = {
		symbols = { " ", "-", "X" },
		update_parents = true,
		not_started = " ",
		in_progress = "-",
		complete = "X",
	},
}

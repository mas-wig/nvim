return require("clangd_extensions").setup({
	inlay_hints = {
		inline = false,
	},
	ast = {
		role_icons = {
			type = " ",
			declaration = " ",
			expression = " ",
			specifier = " ",
			statement = " ",
			["template argument"] = " ",
		},
		kind_icons = {
			Compound = " ",
			Recovery = " ",
			TranslationUnit = " ",
			PackExpansion = " ",
			TemplateTypeParm = " ",
			TemplateTemplateParm = " ",
			TemplateParamObject = " ",
		},
	},
})

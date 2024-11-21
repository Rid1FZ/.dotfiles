local api = vim.api

return function()
	api.nvim_buf_delete(0, { force = true }) -- close previously opened lazy window

	vim.schedule(function()
		vim.cmd("MasonInstallAll")

		-- Keep track of which mason pkgs get installed
		local packages = table.concat(vim.g.mason_binaries_list, " ")

		require("mason-registry"):on("package:install:success", function(pkg)
			packages = string.gsub(packages, pkg.name:gsub("%-", "%%-"), "") -- rm package name
		end)
	end)
end

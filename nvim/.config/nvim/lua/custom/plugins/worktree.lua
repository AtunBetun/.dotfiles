return {
	"ThePrimeagen/git-worktree.nvim",
	config = function()
		require("git-worktree").setup({})

		local worktree = require("git-worktree")
		worktree.on_tree_change(function(op, metadata)
			if op == worktree.Operations.Switch then
				print("Switched from " .. metadata.prev_path .. " to " .. metadata.path)
				local oil = require("oil")
				oil.open(metadata.path)
			end
		end)
	end,
}

local M = {}
local config = {
	repo = "3lv/dot"
}
local HOME = vim.fn.expand("$HOME")
local linuxdocs = vim.fn.expand("$HOME/documents/linux")

local function exec(cmd, opts)
	opts = opts or {}
	local lines
	local job = vim.fn.jobstart(cmd, {
		cwd = opts.cwd or HOME,
		pty = false,
		env = opts.env,
		stdout_buffered = true,
		on_stdout = function(_, _lines)
			lines = _lines
		end,
	})
	vim.fn.jobwait({ job })
	return lines
end

local function install_dotrepo()
	local github = "https://github.com/"
	exec({"rm", "-rf", ".git"})
	exec({"git", "init"})
	exec({"git", "remote", "add", "origin", github .. config.repo})
	exec({"git", "fetch", "origin", "master"})
	exec({"git", "reset", "--hard", "origin/master"})
	-- TODO verbose
end

local function run_installsh()
	local script = HOME .. "/.install.sh"
	exec({"chmod", "u+x", script})
	vim.fn.jobstart({"sudo", "script"},
	{detach = true, pty = false})
	--exec({"./install.sh"})
end

function M.run()
	local has = vim.fn.has
	if has("linux") or has("mac") or has("wsl") then
		install_dotrepo()
	elseif has("win32") then
		return
	end
	--run_installsh()
end

function M.setup(opts)
	vim.tbl_deep_extend("force", config, opts or {})
	vim.api.nvim_create_user_command("Dot", "lua require('boostrap').run()", {})
end

return M

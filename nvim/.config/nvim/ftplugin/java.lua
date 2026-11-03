local function unavailable(message)
	vim.notify("JDTLS: " .. message, vim.log.levels.WARN)
end

local home = vim.env.HOME
local mise = vim.fn.exepath("mise")
if mise == "" and home then
	mise = home .. "/.local/bin/mise"
end
if not home or vim.fn.executable(mise) ~= 1 then
	unavailable("mise is required to resolve the installed global editor JDK")
	return
end
local runtime_env = vim.fn.environ()
runtime_env.JAVA_HOME = nil
runtime_env.MISE_CONFIG_DIR = vim.env.MISE_CONFIG_DIR or (vim.env.XDG_CONFIG_HOME or home .. "/.config") .. "/mise"
runtime_env.MISE_CEILING_PATHS = home
runtime_env.MISE_AUTO_INSTALL = "0"
runtime_env.MISE_EXEC_AUTO_INSTALL = "0"
local runtime = vim.system({ mise, "-C", home, "which", "java" }, {
	text = true,
	clear_env = true,
	env = runtime_env,
}):wait()
local java = vim.trim(runtime.stdout or "")
if runtime.code ~= 0 or java == "" or vim.fn.executable(java) ~= 1 then
	unavailable("installed global Java 21+ is unavailable: " .. vim.trim(runtime.stderr or ""))
	return
end

local mason = vim.fn.stdpath("data") .. "/mason"
local jdtls_share = mason .. "/share/jdtls"
local launcher = jdtls_share .. "/plugins/org.eclipse.equinox.launcher.jar"
local configuration = jdtls_share .. "/config"
local lombok = jdtls_share .. "/lombok.jar"
if vim.fn.filereadable(launcher) ~= 1 or vim.fn.filereadable(configuration .. "/config.ini") ~= 1 then
	unavailable("missing Mason jdtls package; run mise run editor-setup")
	return
end

local available, jdtls = pcall(require, "jdtls")
if not available then
	unavailable("nvim-jdtls plugin is missing; provision plugins with :Lazy restore")
	return
end
local root_dir = require("jdtls.setup").find_root({ ".bemol", ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts" })
	 or vim.fs.dirname(vim.api.nvim_buf_get_name(0))
if not root_dir or root_dir == "" then
	unavailable("save this buffer in a project before starting the language server")
	return
end
root_dir = vim.fs.normalize(root_dir)
local project_name = vim.fn.fnamemodify(root_dir, ":t") .. "-" .. vim.fn.sha256(root_dir):sub(1, 12)
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name
vim.fn.mkdir(workspace_dir, "p")
local config_dir = vim.fn.stdpath("cache") .. "/jdtls/configuration/" .. project_name
vim.fn.mkdir(config_dir, "p")

local command = {
	java,
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dosgi.checkConfiguration=true",
	"-Dosgi.sharedConfiguration.area=" .. vim.fn.resolve(configuration),
	"-Dosgi.sharedConfiguration.area.readOnly=true",
	"-Dosgi.configuration.cascaded=true",
	"-Xmx1g",
	"--add-modules=ALL-SYSTEM",
	"--add-opens", "java.base/java.util=ALL-UNNAMED",
	"--add-opens", "java.base/java.lang=ALL-UNNAMED",
}
if vim.fn.filereadable(lombok) == 1 then
	table.insert(command, "-javaagent:" .. lombok)
end
vim.list_extend(command, { "-jar", vim.fn.resolve(launcher), "-configuration", config_dir, "-data", workspace_dir })

local config = {
	cmd = command,
	root_dir = root_dir,
	capabilities = require("blink.cmp").get_lsp_capabilities(),
	settings = {
		java = {
			references = { includeDecompiledSources = true },
			eclipse = { downloadSources = true },
			maven = { downloadSources = true },
			sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
		},
	},
}

jdtls.start_or_attach(config)

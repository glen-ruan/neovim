-- 由 scripts/bootstrap.ps1 / scripts/bootstrap.sh 通过
--   nvim --headless -i NONE -u <config>/init.lua -l <config>/scripts/bootstrap.lua
-- 调用。需要真实退出码：nvim 对 +cmd 里的错误仍返回 0，而 -l 模式在 Lua
-- 出错时退出码为 1，所以判定逻辑放在这里，而不是 shell 脚本里。
-- 注意 -l 会跳过用户配置，必须显式用 -u 指定 init.lua，否则 lazy 等插件都不存在。

---@param step string
---@param fn fun()
local function run(step, fn)
  local ok, err = pcall(fn)
  if not ok then
    io.stderr:write(string.format("bootstrap 失败 [%s]：%s\n", step, tostring(err)))
    error(string.format("bootstrap 终止于步骤「%s」", step), 0)
  end
  print(string.format("bootstrap 完成 [%s]", step))
end

run("前置检查", function()
  local missing = {}
  for _, name in ipairs({ "git", "curl", "tar", "tree-sitter" }) do
    if vim.fn.executable(name) ~= 1 then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    error("以下命令不在 PATH 中：" .. table.concat(missing, ", "))
  end

  local compiler
  for _, name in ipairs({ "cc", "gcc", "clang", "cl" }) do
    if vim.fn.executable(name) == 1 then
      compiler = vim.fn.exepath(name)
      break
    end
  end
  if not compiler then
    error("找不到 C 编译器（Treesitter 编译解析器需要）")
  end
  print("  C 编译器：" .. compiler)
end)

run("同步插件版本 (:Lazy! restore)", function()
  vim.cmd("Lazy! restore")
end)

run("校验插件目录", function()
  local missing = {}
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    if plugin.url and plugin.dir and vim.fn.isdirectory(plugin.dir) ~= 1 then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    table.sort(missing)
    error("以下插件未安装：" .. table.concat(missing, ", "))
  end
end)

run("安装 mason 工具 (MasonToolsInstallSync)", function()
  vim.cmd("MasonToolsInstallSync")
end)

run("校验 mason 工具", function()
  -- ensure_installed 直接读插件规格文件，避免两处维护导致漏检。
  local expected = {}
  for _, spec in ipairs(dofile(vim.fn.stdpath("config") .. "/lua/plugins/mason.lua")) do
    if type(spec) == "table" and spec.opts and spec.opts.ensure_installed then
      vim.list_extend(expected, spec.opts.ensure_installed)
    end
  end

  local registry = require("mason-registry")
  local missing = {}
  for _, name in ipairs(expected) do
    local ok, package = pcall(registry.get_package, name)
    if not ok or not package:is_installed() then
      missing[#missing + 1] = name
    end
  end
  if #missing > 0 then
    error("以下工具未安装：" .. table.concat(missing, ", "))
  end
end)

run("安装 Treesitter 解析器 (TSInstallConfigured!)", function()
  vim.cmd("TSInstallConfigured!")
end)

print("bootstrap 完成。进入 Neovim 后可用 :checkhealth nvim_distribution 复查。")

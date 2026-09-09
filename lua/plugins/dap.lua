return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")
      local debugpy_root = vim.fn.stdpath("data") .. "/tools/debugpy"
      local adapter = debugpy_root .. (vim.fn.has("win32") == 1 and "/Scripts/python.exe" or "/bin/python")

      if vim.fn.executable(adapter) ~= 1 then
        vim.notify("未找到 debugpy，请检查 " .. adapter, vim.log.levels.ERROR)
        return
      end

      require("dap-python").setup(adapter, { include_configs = false })

      -- Windows 下改用本地 TCP，避免退出调试时出现 stdio/SIGINT 警告。
      if vim.fn.has("win32") == 1 then
        local python_adapter = dap.adapters.python
        dap.adapters.python = function(callback, config)
          python_adapter(function(resolved)
            if resolved.type == "executable" then
              resolved.executable = {
                command = resolved.command,
                args = { "-m", "debugpy.adapter", "--host", "127.0.0.1", "--port", "${port}" },
                detached = false,
              }
              resolved.type = "server"
              resolved.host = "127.0.0.1"
              resolved.port = "${port}"
              resolved.command = nil
              resolved.args = nil
            end
            callback(resolved)
          end, config)
        end
      end

      local function python()
        if vim.g.debug_python then
          return vim.g.debug_python
        end

        for _, prefix in ipairs({ vim.env.VIRTUAL_ENV or "", vim.env.CONDA_PREFIX or "" }) do
          if prefix ~= "" then
            local suffixes = vim.fn.has("win32") == 1 and { "/Scripts/python.exe", "/python.exe" }
              or { "/bin/python", "/bin/python3" }
            for _, suffix in ipairs(suffixes) do
              if vim.fn.executable(prefix .. suffix) == 1 then
                return prefix .. suffix
              end
            end
          end
        end

        local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
        while dir and dir ~= "" do
          for _, name in ipairs({ ".venv", "venv", ".env", "env" }) do
            local suffixes = vim.fn.has("win32") == 1 and { "/Scripts/python.exe", "/python.exe" }
              or { "/bin/python", "/bin/python3" }
            for _, suffix in ipairs(suffixes) do
              local candidate = dir .. "/" .. name .. suffix
              if vim.fn.executable(candidate) == 1 then
                return candidate
              end
            end
          end
          local parent = vim.fs.dirname(dir)
          if parent == dir then
            break
          end
          dir = parent
        end

        local system_python = vim.fn.exepath("python3")
        return system_python ~= "" and system_python or vim.fn.exepath("python")
      end

      require("dap-python").resolve_python = python
      dap.configurations.python = {
        {
          type = "python",
          request = "launch",
          name = "Python: current file",
          program = "${file}",
          cwd = "${workspaceFolder}",
          pythonPath = python,
          console = "integratedTerminal",
          justMyCode = true,
        },
      }

      ui.setup({
        icons = { expanded = "v", collapsed = ">", current_frame = ">" },
        controls = { enabled = false },
        layouts = {
          {
            position = "left",
            size = 40,
            elements = {
              { id = "scopes", size = 0.45 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.15 },
              { id = "breakpoints", size = 0.15 },
            },
          },
          { position = "bottom", size = 10, elements = { "repl" } },
        },
      })

      dap.listeners.after.event_initialized["user_dapui"] = function()
        ui.open()
      end
      dap.listeners.before.event_terminated["user_dapui"] = function()
        ui.close()
      end
      dap.listeners.before.event_exited["user_dapui"] = function()
        ui.close()
      end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

      local map = vim.keymap.set
      map("n", "<F5>", function()
        if not dap.session() then
          vim.cmd("update")
        end
        dap.continue()
      end, { desc = "调试：启动/继续" })
      map("n", "<F9>", dap.toggle_breakpoint, { desc = "调试：切换断点" })
      map("n", "<F10>", dap.step_over, { desc = "调试：单步跳过" })
      map("n", "<F11>", dap.step_into, { desc = "调试：单步进入" })
      map("n", "<S-F11>", dap.step_out, { desc = "调试：跳出" })
      map("n", "<F6>", function()
        dap.terminate()
        ui.close()
      end, { desc = "调试：停止" })
      map("n", "<leader>du", ui.toggle, { desc = "调试：切换面板" })
      map({ "n", "v" }, "<leader>de", ui.eval, { desc = "调试：查看表达式" })
      map("n", "<leader>db", function()
        vim.ui.input({ prompt = "Breakpoint condition: " }, function(value)
          if value and value ~= "" then
            dap.set_breakpoint(value)
          end
        end)
      end, { desc = "调试：条件断点" })

      vim.api.nvim_create_user_command("DebugPython", function(opts)
        local path = vim.fn.fnamemodify(vim.fn.expand(opts.args), ":p")
        if opts.args == "" then
          vim.g.debug_python = nil
          vim.notify("Python：自动选择环境")
        elseif vim.fn.executable(path) == 1 then
          vim.g.debug_python = path
          vim.notify("Python：" .. path)
        else
          vim.notify("找不到 Python：" .. path, vim.log.levels.ERROR)
        end
      end, { nargs = "?", complete = "file", desc = "选择调试使用的 Python；无参数时恢复自动选择" })
    end,
  },
}

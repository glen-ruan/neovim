return {
  {
    "mfussenegger/nvim-dap",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")
      local platform = require("nvim_config.core.platform")
      local adapter = platform.debugpy_python()
      local layout_before_debug
      local debug_ui_open = false

      local function save_layout()
        if layout_before_debug then
          return
        end
        layout_before_debug = {
          restore = vim.fn.winrestcmd(),
          win = vim.api.nvim_get_current_win(),
        }
      end

      local function restore_layout()
        local layout = layout_before_debug
        layout_before_debug = nil
        ui.close()
        debug_ui_open = false
        if not layout then
          return
        end
        vim.schedule(function()
          if layout.restore ~= "" then
            pcall(vim.cmd, layout.restore)
          end
          if vim.api.nvim_win_is_valid(layout.win) then
            vim.api.nvim_set_current_win(layout.win)
          end
        end)
      end

      if adapter then
        require("dap-python").setup(adapter, { include_configs = false })
      end

      -- Use local TCP on Windows to avoid stdio/SIGINT warnings on shutdown.
      if adapter and platform.is_windows then
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
        return platform.project_python(vim.api.nvim_buf_get_name(0))
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
      -- Keep stdout/stderr in the DAP REPL after the program exits.
          console = "internalConsole",
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
        save_layout()
        ui.open()
        debug_ui_open = true
      end

      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

      local map = vim.keymap.set
      map("n", "<F5>", function()
        if not adapter then
          vim.notify("debugpy was not found; run :MasonToolsInstall or set DEBUGPY_PYTHON", vim.log.levels.ERROR)
          return
        end
        if not dap.session() then
          vim.cmd("update")
          save_layout()
        end
        dap.continue()
      end, { desc = "Debug: start/continue" })
      map("n", "<F9>", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
      map("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
      map("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
      map("n", "<S-F11>", dap.step_out, { desc = "Debug: step out" })
      map("n", "<F6>", function()
        dap.terminate()
        restore_layout()
      end, { desc = "Debug: stop" })
      map("n", "<leader>du", function()
        if debug_ui_open then
          restore_layout()
        else
          save_layout()
          ui.open()
          debug_ui_open = true
        end
      end, { desc = "Debug: toggle UI and restore layout" })
      map({ "n", "v" }, "<leader>de", ui.eval, { desc = "Debug: evaluate expression" })
      map("n", "<leader>db", function()
        vim.ui.input({ prompt = "Breakpoint condition: " }, function(value)
          if value and value ~= "" then
            dap.set_breakpoint(value)
          end
        end)
      end, { desc = "Debug: conditional breakpoint" })

      vim.api.nvim_create_user_command("DebugPython", function(opts)
        local path = vim.fn.fnamemodify(vim.fn.expand(opts.args), ":p")
        if opts.args == "" then
          vim.g.debug_python = nil
          vim.notify("Python: environment selection is automatic")
        elseif vim.fn.executable(path) == 1 then
          vim.g.debug_python = path
          vim.notify("Python：" .. path)
        else
          vim.notify("Python was not found: " .. path, vim.log.levels.ERROR)
        end
      end, {
        nargs = "?",
        complete = "file",
        desc = "Select the Python debugger interpreter; omit the path to restore automatic selection",
      })
    end,
  },
}

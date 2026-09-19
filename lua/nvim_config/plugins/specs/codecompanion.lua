--- Agent CLIs CodeCompanion can drive. An entry is only used when the command
--- it needs is on PATH, so a machine without these tools is unaffected and a
--- newly installed agent is picked up the next time Neovim starts.
---
--- `acp_command` is what the ACP chat adapter runs (`opencode acp`, `codex-acp`,
--- `claude-agent-acp`, `copilot --acp`), `cli_command` is the interactive CLI
--- used by the terminal interaction.
local agents = {
  {
    name = "opencode",
    adapter = "opencode",
    acp_command = "opencode",
    cli_command = "opencode",
    description = "OpenCode",
  },
  {
    name = "claude_code",
    adapter = "claude_code",
    acp_command = "claude-agent-acp",
    cli_command = "claude",
    description = "Claude Code",
  },
  {
    name = "codex",
    adapter = "codex",
    acp_command = "codex-acp",
    cli_command = "codex",
    description = "Codex",
  },
  {
    name = "copilot_acp",
    adapter = "copilot_acp",
    acp_command = "copilot",
    cli_command = "copilot",
    description = "GitHub Copilot",
  },
}

local function executable(name)
  return vim.fn.executable(name) == 1
end

--- Agents whose ACP command is available, in preference order.
local function chat_agents()
  local found = {}
  for _, agent in ipairs(agents) do
    if executable(agent.acp_command) then
      found[#found + 1] = agent
    end
  end
  return found
end

--- CLI agents keyed by name, as `interactions.cli.agents` expects them.
local function terminal_agents()
  local found = {}
  for _, agent in ipairs(agents) do
    if executable(agent.cli_command) then
      found[agent.name] = {
        cmd = agent.cli_command,
        description = agent.description,
      }
    end
  end
  return found
end

--- Ask which installed agent to run, then open its terminal interaction.
local function pick_agent()
  local items = {}
  for _, agent in ipairs(agents) do
    if executable(agent.cli_command) then
      items[#items + 1] = {
        text = agent.description .. " (" .. agent.cli_command .. ")",
        agent = agent,
      }
    end
  end

  if #items == 0 then
    vim.notify("No AI agent CLI was found on PATH", vim.log.levels.WARN, { title = "CodeCompanion" })
    return
  end

  Snacks.picker({
    title = "AI agents",
    items = items,
    format = function(item)
      return { { item.text, "SnacksPickerLabel" } }
    end,
    preview = "preview",
    confirm = function(picker, item)
      picker:close()
      vim.schedule(function()
        require("codecompanion").cli({ agent = item.agent.name })
      end)
    end,
  })
end

return {
  "olimorris/codecompanion.nvim",
  cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionCLI", "CodeCompanionActions" },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = function()
    local chat = chat_agents()
    local terminal = terminal_agents()

    local opts = {
      interactions = {
        cli = {
          agents = terminal,
          -- Run the first installed agent when no agent is given on the command line.
          agent = next(terminal),
        },
      },
      display = {
        chat = {
          window = {
            layout = "float",
            position = "right",
            width = 0.45,
            height = 0.85,
            border = "rounded",
          },
        },
      },
    }

    if chat[1] then
      opts.interactions.chat = { adapter = chat[1].adapter }
    end

    return opts
  end,
  keys = {
    {
      "<leader>ac",
      function()
        require("codecompanion").toggle({ window_opts = { layout = "float" } })
      end,
      desc = "Toggle AI chat window",
      mode = { "n", "v" },
    },
    { "<leader>an", "<cmd>CodeCompanionChat<CR>", desc = "New AI chat", mode = { "n", "v" } },
    { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "AI actions", mode = { "n", "v" } },
    { "<leader>ai", "<cmd>CodeCompanion<CR>", desc = "AI inline prompt", mode = { "n", "v" } },
    { "<leader>at", pick_agent, desc = "AI agent in a terminal window" },
  },
}

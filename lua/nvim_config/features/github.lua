local M = {}

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "GitHub" })
end

local function trim(value)
  return vim.trim(value or "")
end

local function run_gh(args, callback)
  if vim.fn.executable("gh") ~= 1 then
    notify("GitHub CLI is not available", vim.log.levels.ERROR)
    return
  end

  vim.system(
    args,
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        local message = trim(result.stderr)
        notify(message ~= "" and message or "GitHub CLI request failed", vim.log.levels.ERROR)
        return
      end

      local ok, decoded = pcall(vim.json.decode, result.stdout or "")
      if not ok or type(decoded) ~= "table" then
        notify("GitHub CLI returned invalid JSON", vim.log.levels.ERROR)
        return
      end
      callback(decoded)
    end)
  )
end

local function prompt(label, callback, default)
  vim.ui.input({ prompt = label, default = default }, function(value)
    value = trim(value)
    if value ~= "" then
      callback(value)
    end
  end)
end

local function regular_buffer(buffer, current)
  return buffer ~= current
    and vim.api.nvim_buf_is_valid(buffer)
    and vim.bo[buffer].buflisted
    and vim.bo[buffer].buftype == ""
end

local function replacement_buffer(current)
  local alternate = vim.fn.bufnr("#")
  if alternate >= 0 and regular_buffer(alternate, current) then
    return alternate
  end

  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if regular_buffer(buffer, current) then
      return buffer
    end
  end

  return vim.api.nvim_create_buf(true, false)
end

function M.close_view()
  local current = vim.api.nvim_get_current_buf()
  if vim.bo[current].modified then
    notify("Save or discard changes before closing this GitHub view", vim.log.levels.WARN)
    return false
  end

  local window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(window, replacement_buffer(current))
  if vim.api.nvim_buf_is_valid(current) then
    vim.api.nvim_buf_delete(current, { force = false })
  end
  return true
end

local function map_safe_close(buffer)
  for _, lhs in ipairs({ "q", "<leader>q" }) do
    vim.keymap.set("n", lhs, M.close_view, {
      buffer = buffer,
      silent = true,
      desc = "Close GitHub view safely",
    })
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup("NvimConfigGitHubViews", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "octo",
    callback = function(event)
      map_safe_close(event.buf)
    end,
  })
end

local function repository_items(repositories)
  local items = {}
  for _, repository in ipairs(repositories) do
    local description = trim(repository.description)
    local language = repository.language or ""
    local stars = tonumber(repository.stargazersCount) or 0
    items[#items + 1] = {
      text = table.concat({ repository.fullName or "", description, language }, " "),
      repo = repository.fullName,
      description = description,
      language = language,
      stars = stars,
      url = repository.url,
      preview = {
        ft = "markdown",
        text = table.concat({
          "# " .. (repository.fullName or "Unknown repository"),
          "",
          description ~= "" and description or "No description.",
          "",
          "- Stars: " .. stars,
          "- Language: " .. (language ~= "" and language or "Unknown"),
          "- Visibility: " .. (repository.visibility or "unknown"),
          "- Updated: " .. (repository.updatedAt or "unknown"),
          "- URL: " .. (repository.url or "unknown"),
        }, "\n"),
      },
    }
  end
  return items
end

local function open_repository(item)
  if not item or not item.repo then
    return
  end
  vim.api.nvim_cmd({ cmd = "Octo", args = { "repo", "view", item.repo } }, {})
end

function M.search_repositories()
  prompt("Search GitHub repositories: ", function(query)
    run_gh({
      "gh",
      "search",
      "repos",
      query,
      "--limit",
      "100",
      "--json",
      "fullName,description,stargazersCount,updatedAt,url,visibility,language",
    }, function(repositories)
      local items = repository_items(repositories)
      if #items == 0 then
        notify("No repositories matched the search")
        return
      end

      Snacks.picker({
        title = "GitHub repositories",
        items = items,
        format = function(item)
          return {
            { item.repo, "SnacksPickerLabel" },
            { string.format("  ★ %d", item.stars), "Number" },
            { item.description ~= "" and ("  " .. item.description) or "", "Comment" },
          }
        end,
        preview = "preview",
        confirm = function(picker, item)
          picker:close()
          vim.schedule(function()
            open_repository(item)
          end)
        end,
      })
    end)
  end)
end

local function code_items(response)
  local items = {}
  for _, result in ipairs(response.items or {}) do
    local repository = result.repository and result.repository.full_name or "unknown/unknown"
    local fragments = {}
    for _, match in ipairs(result.text_matches or {}) do
      if match.fragment then
        fragments[#fragments + 1] = match.fragment
      end
    end
    local reference = (result.html_url or ""):match("/blob/([^/]+)/")
    items[#items + 1] = {
      text = table.concat({ repository, result.path or "", table.concat(fragments, " ") }, " "),
      repo = repository,
      path = result.path,
      reference = reference,
      fragments = fragments,
      preview = {
        ft = vim.filetype.match({ filename = result.path or "" }) or "text",
        text = #fragments > 0 and table.concat(fragments, "\n\n---\n\n") or "No text preview returned.",
      },
    }
  end
  return items
end

local function encode_path(path)
  local parts = vim.split(path or "", "/", { plain = true })
  for index, part in ipairs(parts) do
    parts[index] = vim.uri_encode(part)
  end
  return table.concat(parts, "/")
end

local function find_named_buffer(name)
  for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_get_name(buffer) == name then
      return buffer
    end
  end
end

local function show_remote_file(item, content)
  local name = string.format("github://%s/%s@%s", item.repo, item.path, (item.reference or "HEAD"):sub(1, 12))
  local buffer = find_named_buffer(name) or vim.api.nvim_create_buf(true, false)

  vim.bo[buffer].modifiable = true
  vim.bo[buffer].buftype = "nofile"
  vim.bo[buffer].bufhidden = "hide"
  vim.bo[buffer].swapfile = false
  if vim.api.nvim_buf_get_name(buffer) == "" then
    vim.api.nvim_buf_set_name(buffer, name)
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, vim.split(content, "\n", { plain = true }))
  vim.bo[buffer].filetype = vim.filetype.match({ filename = item.path }) or ""
  vim.bo[buffer].modified = false
  vim.bo[buffer].modifiable = false
  vim.bo[buffer].readonly = true
  vim.api.nvim_win_set_buf(0, buffer)
  map_safe_close(buffer)
end

local function open_code_result(item)
  if not item or not item.repo or not item.path or not item.reference then
    notify("The selected code result is missing repository information", vim.log.levels.ERROR)
    return
  end

  local endpoint = string.format("repos/%s/contents/%s", item.repo, encode_path(item.path))
  vim.system(
    {
      "gh",
      "api",
      "-X",
      "GET",
      endpoint,
      "-f",
      "ref=" .. item.reference,
      "-H",
      "Accept: application/vnd.github.raw+json",
    },
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code ~= 0 then
        notify(
          trim(result.stderr) ~= "" and trim(result.stderr) or "Unable to load the remote file",
          vim.log.levels.ERROR
        )
        return
      end
      show_remote_file(item, result.stdout or "")
    end)
  )
end

function M.search_code()
  prompt("Search GitHub code: ", function(query)
    run_gh({
      "gh",
      "api",
      "-X",
      "GET",
      "search/code",
      "-f",
      "q=" .. query,
      "-F",
      "per_page=100",
      "-H",
      "Accept: application/vnd.github.text-match+json",
    }, function(response)
      local items = code_items(response)
      if #items == 0 then
        notify("No code matched the search")
        return
      end

      Snacks.picker({
        title = "GitHub code",
        items = items,
        format = function(item)
          return {
            { item.repo, "SnacksPickerLabel" },
            { "  " .. item.path, "Directory" },
          }
        end,
        preview = "preview",
        confirm = function(picker, item)
          picker:close()
          vim.schedule(function()
            open_code_result(item)
          end)
        end,
      })
    end)
  end)
end

function M.search_octo(qualifier, label)
  prompt(label or "Search GitHub: ", function(query)
    local search = trim(table.concat({ qualifier or "", query }, " "))
    vim.api.nvim_cmd({ cmd = "Octo", args = { "search", search } }, {})
  end)
end

M._repository_items = repository_items
M._code_items = code_items

return M

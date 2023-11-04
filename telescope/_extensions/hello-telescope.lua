local strings = require("plenary.strings")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local conf = require("telescope.config").values
local action_set = require("telescope.actions.set")
local action_state = require("telescope.actions.state")

local get_selected_text = function(prompt_bufnr)
    local selection = action_state.get_selected_entry(prompt_bufnr)
    return selection.text
end

local prompt_text = function(prompt_bufnr)
  local selection = get_selected_text(prompt_bufnr)
  return selection.text
end

local hello_telescope_fcn = function(opts)
  opts = opts or {}
  local output = { "hello", "world" }
  local results = {}
  local widths = {
    text = 0,
  }

  local parse_line = function(line)
    local entry = {
      text = line,
    }
    local index = #results + 1
    for key, val in pairs(widths) do
      local entry_len = strings.strdisplaywidth(entry[key] or "")
      widths[key] = math.max(val, entry_len)
    end
    table.insert(results, index, entry)
  end

  for _, line in ipairs(output) do
    parse_line(line)
  end

  if #results == 0 then
    return
  end

  local displayer = require("telescope.pickers.entry_display").create {
    separator = " ",
    items = {
      { width = widths.text },
    },
  }

  local make_display = function(entry)
    return displayer {
      { entry.text, "TelescopeResultsIdentifier" },
    }
  end

  pickers.new(opts or {}, {
      prompt_title = "Hello World picker",
      finder = finders.new_table {
          results = results,
          entry_maker = function(entry)
              entry.value = entry.text
              entry.ordinal = entry.text
              entry.display = make_display
              return entry
          end,
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(_, map)
          action_set.select:replace(prompt_text)
          return true
      end
  }):find()
end

return require("telescope").register_extension(
           {
        exports = {
            hello_telescope = hello_telescope_fcn
        }
    })

local config = require('ecl.config')
local util = require('ecl.util')

-- asynchronously syntax check the provided file (defaults to %)
local check = function (file, on_success)
  local cmd = util.shfmt(
    '%s --logfile %s -syntax %s',
    config.get('eclcc.path'),
    config.get('eclcc.log'),
    vim.fn.expand(util.default(file, '%'))
  )

  local jobstart = vim.fn.jobstart
  local getqf = vim.fn.getqflist
  local setqf = vim.fn.setqflist

  jobstart(cmd, {
    stderr_buffered = true,
    on_stderr = function (_, lines)
      table.remove(lines)  -- empty line
      table.remove(lines)  -- x error, y warning

      local qf = getqf({
        efm = '%f(%l\\,%c): error C%n: %m',
        lines = lines,
      })

      setqf(qf.items, 'r')

      if #qf.items > 0 then
        vim.cmd('copen')
      else
        vim.cmd('cclose')
        print('All good')
        if on_success then on_success(file) end
      end
    end,
  })
end

return {
  check = check,
}

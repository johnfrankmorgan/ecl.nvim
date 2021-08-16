local config = require('ecl.config')
local util = require('ecl.util')

local __cluster_password = ''

local get_password = function ()
  local cfg_pwd = config.get('cluster.password')

  if cfg_pwd and cfg_pwd ~= '' then
    return cfg_pwd
  end

  if __cluster_password == '' then
    __cluster_password = vim.fn.inputsecret(
      vim.fn.printf(
        'Enter password for cluster %s (%s): ',
        config.get('cluster.name'),
        config.get('cluster.address')
      )
    )
  end

  return __cluster_password
end

local draw_results = function (results)

  vim.cmd(vim.fn.printf([[
py3 <<EOF
import vim
import xml.etree.ElementTree as xml
from xml.dom import minidom

def draw_el(el, name):
    vim.command('tabedit')
    vim.command('file {}'.format(name))
    vim.command('setlocal filetype=xml')
    vim.command('setlocal buftype=nofile')
    vim.command('let b:ecl_results=1')

    str = minidom.parseString(xml.tostring(el)).toprettyxml(indent = '  ')
    vim.current.buffer[:] = [l.rstrip() for l in str.split('\n') if l.strip()]

results = xml.fromstring("""%s""")

for i, warning in enumerate(results.findall('.//Warning')):
    draw_el(warning, 'Warning {}'.format(i + 1))

for result in results.findall('.//Dataset'):
    draw_el(result, result.attrib['name'])
EOF
  ]], vim.fn.join(results, '')))

  vim.cmd('1')
end

-- asynchronously run the provided file (defaults to %)
local run = function (file)
  local cmd = util.shfmt(
    '%s run %s --server=%s --username=%s --password=%s --limit=%d %s',
    config.get('ecl.path'),
    config.get('ecl.target'),
    config.get('cluster.address'),
    config.get('cluster.username'),
    get_password(),
    config.get('ecl.limit'),
    vim.fn.expand(util.default(file, '%'))
  )

  vim.fn.jobstart(cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function (_, lines)
      draw_results(lines)
    end,
    on_stderr = function (_, lines)
      local err = vim.fn.join(lines, '\n')
      error(err)
    end,
  })
end

return {
  run = function (file)
    require('ecl.syntax').check(file, run)
  end,
}

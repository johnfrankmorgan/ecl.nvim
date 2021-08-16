local config = {
  cluster = {
    name = 'Local',
    address = '127.0.0.1',
    username = os.getenv('USER'),
    password = '',
  },

  ecl = {
    path = 'ecl',
    target = 'roxie',
    limit = 1000,
  },

  eclcc = {
    path = 'eclcc',
    log = '/dev/null',
  },
}

local get = function (key, default)
  local obj = config
  local keys = vim.fn.split(key or '', '\\.')

  for _, key in ipairs(keys) do
    obj = obj[key] or {}
  end

  if obj then
    return obj
  end

  return default
end

local set = function (cfg)
  config = vim.tbl_deep_extend('force', config, cfg or {})
end

return {
  get = get,
  set = set,
}

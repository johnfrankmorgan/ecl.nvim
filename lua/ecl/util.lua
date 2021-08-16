local is_string = function (var)
  return type(var) == 'string'
end

local shfmt = function (fmt, ...)
  local shesc = vim.fn.shellescape
  local args = {}

  for i = 1, select('#', ...) do
    local arg = select(i, ...)

    if is_string(arg) then
      arg = shesc(arg)
    end

    table.insert(args, arg)
  end

  return string.format(fmt, unpack(args))
end

local default = function (val, def)
  local val = val or ''

  if string.len(val) == 0 then
    return def
  end

  return val
end

return {
  shfmt = shfmt,
  default = default,
}

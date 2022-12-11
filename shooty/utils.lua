function clamp(x, min, max)
  return math.max(min, math.min(max, x))
end

function mod(a, m)
  return a - (m * math.floor(a / m))
end

function round(n, m)
  local mult = m or 1
  local num = n / mult
  local floor = math.floor(num)
  if num - floor < 0.5 then
    return floor * mult
  end
  return math.ceil(num) * mult
end

function sign(n)
  if n > 0 then return 1 end
  if n < 0 then return -1 end
  return 0
end

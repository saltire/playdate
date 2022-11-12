function clamp(x, min, max)
  return math.max(min, math.min(max, x))
end

function mod(a, m)
  return a - (m * math.floor(a / m))
end

function sign(n)
  if n > 0 then return 1 end
  if n < 0 then return -1 end
  return 0
end

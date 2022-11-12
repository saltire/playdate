import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

local gfx <const> = playdate.graphics
local pressed <const> = playdate.buttonIsPressed


local playerSprite = nil

local lastElapsed = 0

local cx, cy = 200, 120 -- Camera position
local cvx, cvy = 0, 0 -- Camera velocity

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

function setup()
  local playerImage = gfx.image.new('images/player.png')
  assert(playerImage)

  local enemyImage = gfx.image.new('images/enemy.png')
  assert(enemyImage)

  local bulletImage = gfx.image.new('images/bullet.png')
  assert(bulletImage)

  local backgroundImage = gfx.image.new('images/halftone.png')
  assert(backgroundImage)

  playerSprite = gfx.sprite.new(playerImage)
  playerSprite:moveTo(200, 120)
  playerSprite:add()

  local bw, bh = backgroundImage:getSize()

  gfx.sprite.setBackgroundDrawingCallback(
    function (x, y, width, height)
      -- Point on the background that goes at the top left of the draw area.
      local ox, oy = mod(x + cx - 200, bw), mod(y + cy - 120, bh)
      -- Width and height of the section of background to draw.
      local dw, dh = math.min(bw - ox, width), math.min(bh - oy, height)

      backgroundImage:draw(x, y, nil, ox, oy, dw, dh)

      -- If the section of background doesn't fill the draw area,
      -- draw it again to the right and/or below.
      if dw < width then
        backgroundImage:draw(math.ceil(x + dw), y, nil, 0, oy, width - dw, dh)
      end
      if dh < height then
        backgroundImage:draw(x, math.ceil(y + dh), nil, ox, 0, dw, height - dh)
      end
      if dw < width and dh < height then
        backgroundImage:draw(math.ceil(x + dw), math.ceil(y + dh), nil, 0, 0, width - dw, height - dh)
      end
    end
  )

  playdate.startAccelerometer()
end

setup()

local playerSpeed = 1.5
local cameraSpring = 30

function playdate.update()
  local dx, dy = 0, 0

  local elapsed = playdate.getElapsedTime()
  local deltaTime = elapsed - lastElapsed
  lastElapsed = elapsed

  if pressed(playdate.kButtonUp) then
    dy -= playerSpeed
  end

  if pressed(playdate.kButtonRight) then
    dx += playerSpeed
  end

  if pressed(playdate.kButtonDown) then
    dy += playerSpeed
  end

  if pressed(playdate.kButtonLeft) then
    dx -= playerSpeed
  end

  px = playerSprite.x + dx * playerSpeed
  py = playerSprite.y + dy * playerSpeed
  playerSprite:moveTo(px, py)

  function adjustVelocity(targetPos, currentPos, currentVelocity)
    local distance = targetPos - currentPos
    local springForce = distance * cameraSpring
    local dampingForce = currentVelocity * 2 * math.sqrt(cameraSpring)
    return currentVelocity + (springForce - dampingForce) * deltaTime
  end

  cvx = adjustVelocity(px, cx, cvx)
  cx += cvx * deltaTime

  cvy = adjustVelocity(py, cy, cvy)
  cy += cvy * deltaTime

  gfx.setDrawOffset(200 - cx, 120 - cy)
  gfx.sprite.redrawBackground()

  gfx.sprite.update()

  playdate.timer.updateTimers()
end

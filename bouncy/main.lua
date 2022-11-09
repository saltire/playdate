import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'

local gfx <const> = playdate.graphics
local pressed <const> = playdate.buttonIsPressed


local playerSprite = nil

function setup()
  local playerImage = gfx.image.new('images/invader.png')
  assert(playerImage)

  playerSprite = gfx.sprite.new(playerImage)
  playerSprite:moveTo(200, 120)
  playerSprite:add()

  local backgroundImage = gfx.image.new('images/diffuse.png')
  assert(backgroundImage)

  gfx.sprite.setBackgroundDrawingCallback(
    function (x, y, width, height)
      backgroundImage:draw(0, 0)
    end
  )

  playdate.startAccelerometer()
end

setup()

function clamp(x, min, max)
  return math.max(min, math.min(max, x))
end

local dx, dy = 0, 0

local thrust = 0.6
local gravity = 0.4
local bounce = 0.6
local friction = 0.02
local wallFriction = 0.06

function playdate.update()
  if pressed(playdate.kButtonUp) then
    dy -= thrust
  end

  if pressed(playdate.kButtonRight) then
    dx += thrust
  end

  if pressed(playdate.kButtonDown) then
    dy += thrust
  end

  if pressed(playdate.kButtonLeft) then
    dx -= thrust
  end

  local gx, gy = playdate.readAccelerometer()

  dx += gx * gravity
  dy += gy * gravity

  dx *= (1 - friction)
  dy *= (1 - friction)

  playerSprite:moveTo(clamp(playerSprite.x + dx, 0, 400), clamp(playerSprite.y + dy, 0, 240))

  if playerSprite.x == 0 or playerSprite.x == 400 then
    dx *= -bounce
    dy *= (1 - wallFriction)
  end
  if playerSprite.y == 0 or playerSprite.y == 240 then
    dy *= -bounce
    dx *= (1 - wallFriction)
  end

  gfx.sprite.update()

  playdate.timer.updateTimers()
end

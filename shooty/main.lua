import 'CoreLibs/object'
import 'CoreLibs/graphics'
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoreLibs/ui'

import 'utils'

local gfx <const> = playdate.graphics
local pressed <const> = playdate.buttonIsPressed


local lastElapsed = 0

local cx, cy = 200, 120 -- Camera position
local cvx, cvy = 0, 0 -- Camera velocity

local playerSprite = nil
local arrowSprite = nil
local playerDir = 5
local playerTable = nil
local walkingTime = 0
local walkingFrame = 1
local walkingFrameTime = 0.25
local walkingFrames = 4

function setup()
  local backgroundImage = gfx.image.new('images/halftone.png')
  assert(backgroundImage)
  local enemyImage = gfx.image.new('images/enemy.png')
  assert(enemyImage)
  local arrowImage = gfx.image.new('images/arrow.png')
  assert(arrowImage)
  local bulletImage = gfx.image.new('images/bullet.png')
  assert(bulletImage)

  playerTable = gfx.imagetable.new('images/player')
  playerSprite = gfx.sprite.new(playerTable:getImage(playerDir, 1))
  playerSprite:moveTo(200, 120)
  playerSprite:add()

  arrowSprite = gfx.sprite.new(arrowImage)
  arrowSprite:setCenter(0.5, 1.0)
  arrowSprite:moveTo(playerSprite.x, playerSprite.y)
  arrowSprite:add()

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

  playdate.ui.crankIndicator:start()
end

setup()

local playerSpeed = 1.5
local cameraSpring = 30

function playdate.update()
  local px, py = playerSprite.x, playerSprite.y
  local dx, dy = 0, 0

  local elapsed = playdate.getElapsedTime()
  local deltaTime = elapsed - lastElapsed
  lastElapsed = elapsed


  -- Player movement

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

  if dx ~= 0 or dy ~= 0 then
    px += dx * playerSpeed
    py += dy * playerSpeed
    playerSprite:moveTo(px, py)
    arrowSprite:moveTo(px, py)

    walkingTime += deltaTime
    walkingFrame = math.ceil(walkingTime / walkingFrameTime) % walkingFrames + 1
    if walkingFrame == 3 then
      walkingFrame = 1
    elseif walkingFrame == 4 then
      walkingFrame = 3
    end
    playerSprite:setImage(playerTable:getImage(playerDir, walkingFrame))

  elseif walkingTime > 0 then
    walkingTime = 0
    walkingFrame = 1
    playerSprite:setImage(playerTable:getImage(playerDir, walkingFrame))
  end


  -- Camera movement

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

  if playdate.isCrankDocked() then
    playdate.ui.crankIndicator:update()
  else
    local crankAngle = playdate.getCrankPosition()

    local crankDir = math.floor((crankAngle + 22.5) / 45) % 8 + 1
    if crankDir ~= playerDir then
      playerDir = crankDir
      playerSprite:setImage(playerTable:getImage(playerDir, walkingFrame))
    end

    if crankAngle ~= arrowSprite:getRotation() then
      arrowSprite:setRotation(crankAngle)
    end
  end

  playdate.timer.updateTimers()
end

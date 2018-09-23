function RGB(r,g,b)
  return { r/255, g/255, b/255, 1 }
end

function clamp(x, min, max)
  if x > max then return max
  elseif x < min then return min
  else return x end
end

-- options
gridsize = { x = 9, y = 9 }
maxlev = 999
colorcode = false

-- gamedata
highscore = 0
function love.load()
  me = { x = love.math.random(gridsize.x), y = love.math.random(gridsize.y), lev = 0 }
  pnts = 0
  wd = { width = gridsize.x, height = gridsize.y }
  for j=1,wd.height do
    wd[j] = {}
    for i=1,wd.width do
      wd[j][i] = 0
    end
  end
  wd[me.y][me.x] = me.lev
  died = false

end

-- graphics
gs = 128
space = gs/4
line = gs
numberpos = gs/2
diedvis = "cell"
colors = { background = RGB(0,43,54), default = RGB(253,246,227), character = RGB(38, 139, 210), died = RGB(220, 50, 47),
           ok = RGB(113, 153, 0), bad = RGB(203, 75, 22), text = RGB(253, 246, 227), tile = RGB(181, 137, 0)}
while gs * gridsize.y > love.graphics.getHeight() - 16 or gs * gridsize.x > love.graphics.getWidth() - 128 do
  gs = gs-4
  numberpos = gs/3
  line = gs
  space = gs/4
end

-- font = love.graphics.newFont("font.pcf", 20)

-- music
music = love.audio.newSource("music.wav", "stream")

music:setLooping(true)
music:setVolume(0.1)
music:play()

soundfiles = {"die","level","step","restart"}
sound = {}
for _, i in ipairs(soundfiles) do
  sound[i] = love.audio.newSource("sfx/" .. i .. ".wav", "static")
end

-- callback
touchx = 0
touchy = 0
function touchpressed(x,y)
    touchx = x
    touchy = y
end

function touchreleased(x,y)
    all = {up = -(y - touchy), down = (y - touchy), left = -(x - touchx) , right = (x - touchx)}
    power = math.max(all.up, all.down, all.left, all.right)
    v = "space"
    if power > gs*2 then
        for keyl, am in pairs(all) do
            if am >= power then
                v = keyl
                break
            end
        end
    end
    love.keypressed(v)
end

function love.mousepressed(x, y, button, istouch)
  if button == 1 or istouch then touchpressed(x,y) end
end

function love.mousereleased(x, y, button, istouch)
  if button == 1 or istouch then touchreleased(x,y) end
end

function love.update(dt)
    if love.touch.getTouches()[1] or love.mouse.isDown(1) or love.keyboard.isDown("space") then
        timer = timer + dt
    else
        timer = 0
    end
    if timer > 1 then
        love.keypressed("space")
    end
end

function spawnelem()
  newcordx, newcordy = love.math.random(wd.width), love.math.random(wd.height)
  if (wd[newcordy][newcordx] == 0) and me.lev < maxlev then
    newelem = clamp(love.math.random(me.lev+4)-2+me.lev, 1, maxlev)
    wd[newcordy][newcordx] = newelem
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.load()
    sound.restart:play()
    return
  end
  if died then
    return
  end
  wd[me.y][me.x] = 0
  vel = { x = 0, y = 0 }
  if key == "down" and me.y<wd.height then
    vel.x = 0
    vel.y = 1
  end
  if key == "up" and me.y>1 then
    vel.x = 0
    vel.y = -1
  end
  if key == "right" and me.x<wd.width then
    vel.x = 1
    vel.y = 0
  end
  if key == "left" and me.x>1 then
    vel.x = -1
    vel.y = 0
  end

  elem = wd[me.y + vel.y][me.x + vel.x]
  if elem > me.lev then
    died = true
    me.x = -1
    me.y = -1
    if pnts > highscore then
      highscore = pnts
    end
    sound.die:play()
    return
  elseif elem > 0 or me.lev == 0 and me.lev < maxlev then
    me.lev = me.lev + 1
    pnts = pnts + 1
    sound.level:play()
  elseif not (vel.x == 0 and vel.y == 0) then
    sound.step:play()
  end
  me.x = me.x + vel.x
  me.y = me.y + vel.y
  wd[me.y][me.x] = me.lev

  spawnelem()
end

function love.draw()
--  love.graphics.setFont(font)
  love.graphics.setBackgroundColor(colors.background)
  love.graphics.setLineWidth( space/4 )
  for x=1,wd.width do
    for y=1,wd.height do
      elem = wd[y][x]
      if died then
        love.graphics.setColor(colors.died)
      elseif x == me.x and y == me.y then
        love.graphics.setColor(colors.character)
      elseif elem == 0 then
        love.graphics.setColor(colors.default)
      elseif not colorcode then
        love.graphics.setColor(colors.tile)
      elseif elem > me.lev then
        love.graphics.setColor(colors.bad)
      else
        love.graphics.setColor(colors.ok)
      end
      love.graphics.rectangle("line", gs*x-gs+space, gs*y-gs+space, gs*1-space, gs*1-space)
      love.graphics.setColor(colors.text)
      love.graphics.print(elem, gs*x-gs+numberpos, gs*y-gs+numberpos)
    end
  end
  love.graphics.setColor(colors.text)
  love.graphics.print("points: " .. pnts, gs*wd.width+gs, gs)
  love.graphics.print("highscore: " .. highscore, gs*wd.width+gs, gs*2)
end

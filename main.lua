function RGB(r,g,b)
  return { r/255, g/255, b/255, 1 }
end

function clamp(x, min, max)
  if x > max then return max
  elseif x < min then return min
  else return x end
end

-- options
gridsize = { x = 8, y = 8 }
maxspawn = 989
colorcode = false

-- gamedata
function love.load()
  me = { x = love.math.random(gridsize.x), y = love.math.random(gridsize.y), lev = 0 }
  pnts = me.lev
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
gs = 256
space = gs/4
line = gs
numberpos = gs/2
diedvis = "cell"
colors = { background = RGB(0,43,54), default = RGB(253,246,227), character = RGB(38, 139, 210), died = RGB(220, 50, 47),
           ok = RGB(113, 153, 0), bad = RGB(203, 75, 22), text = RGB(253, 246, 227)}
while gs * gridsize.y > love.graphics.getHeight() - 16 do
  gs = gs-4
  numberpos = gs/2
  line = gs
  space = gs/4
end


-- callbacks
touchx = 0
touchy = 0
function love.touchpressed(id,x,y,pres)
    touchx = x
    touchy = y
end

function love.touchreleased(id,x,y,pres)
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

function love.keypressed(key)
  if key == "escape" then
    love.load()
    return
  end
  if died then
    return
  end
  wd[me.y][me.x] = 0
  vel = { x = 0, y = 0 }
  if key == "down" and me.x<wd.height then
    vel.x =  1
    vel.y = 0
  end
  if key == "up" and me.x>1 then
    vel.x = -1
    vel.y = 0
  end
  if key == "right" and me.y<wd.width then
    vel.x = 0
    vel.y = 1
  end
  if key == "left" and me.y>1 then
    vel.x = 0
    vel.y = -1
  end
  elem = wd[me.y + vel.y][me.x + vel.x]
  if elem > me.lev then
    died = true
    me.x = -1
    me.y = -1
    return
  elseif elem > 0 or me.lev == 0 then
    me.lev = me.lev + 1
  end
  me.x = me.x + vel.x
  me.y = me.y + vel.y
  wd[me.y][me.x] = me.lev

  newcordx, newcordy = love.math.random(wd.width), love.math.random(wd.height)
  if (wd[newcordy][newcordx] == 0) then
    newelem = clamp(love.math.random(me.lev+4)-2+me.lev, 1, maxspawn)
    wd[newcordy][newcordx] = newelem
  end

end

function love.draw()
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
      elseif elem <= me.lev and colorcode then
        love.graphics.setColor(colors.ok)
      else
        love.graphics.setColor(colors.bad)
      end
      love.graphics.rectangle("line", gs*y-gs+space, gs*x-gs+space, gs*1-space, gs*1-space)
      love.graphics.setColor(colors.text)
      love.graphics.print(elem, gs*y-gs+numberpos, gs*x-gs+numberpos)
    end
  end
  love.graphics.setColor(colors.character)
end

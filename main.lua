function RGB(r,g,b)
  return { r/255, g/255, b/255, 1 }
end

function clamp(x, min, max)
  if x > max then return max
  elseif x < min then return min
  else return x end
end

-- gamedata
function love.load()
  me = { x = 1, y = 1, lev = 1 }
  pnts = me.lev
  wd = { width = 8, height = 8 }
  for j=1,wd.height do
    wd[j] = {}
    for i=1,wd.width do
      wd[j][i] = 0
    end
  end
  wd[me.y][me.x] = me.lev
  wd[4][4] = 4
  died = false
end

-- graphics
gs = 64
space = gs/4
line = gs
numberpos = gs/2
diedvis = "cell"
colors = { background = RGB(0,43,54), default = RGB(253, 246, 227), character = RGB(38, 139, 210), died = RGB(220, 50, 47),
           ok = RGB(113, 153, 0), bad = RGB(203, 75, 22)}

-- callbacks
touchx = 0
touchy = 0
function love.touchpressed(id,x,y,pres)
    touchx = x
    touchy = y
end

all = {up = 0, down = 0, left = 0, right = 0}
power = 0
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
    newelem = clamp(love.math.random(me.lev+4)-2+me.lev, 1, 89)
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
      elseif elem > me.lev then
        love.graphics.setColor(colors.bad)
      else
        love.graphics.setColor(colors.ok)
      end
      love.graphics.rectangle("line", gs*y-gs+space, gs*x-gs+space, gs*1-space, gs*1-space)
      love.graphics.print(elem, gs*y-gs+numberpos, gs*x-gs+numberpos)
    end
  end
  love.graphics.setColor(colors.character)
end

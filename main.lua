function RGB(r,g,b)
  return r/255, g/255, b/255, 1
end

-- gamedata
me = { x = 1, y = 1, lev = 1 }
pnts = me.lev
wd = { width = 8, height = 8 }
for i=1,wd.width do
  wd[i] = {}
  for j=1,wd.height do
    wd[i][j] = 0
  end
end
wd[me.x][me.y] = me.lev

-- graphics
gs = 64

-- callbacks

function love.keypressed(key)
  wd[me.x][me.y] = 0
  vel = { x = 0, y = 0 }
  if key == "down" and me.x<wd.height then
    vel.x = 1
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
  me.x = me.x + vel.x
  me.y = me.y + vel.y
  wd[me.x][me.y] = me.lev
end

function love.draw()
  love.graphics.setBackgroundColor(RGB(40,40,40))
  for x=1,wd.width do
    for y=1,wd.height do
      love.graphics.setColor(RGB(248,248,248))
      love.graphics.rectangle("line", gs*x, gs*y, gs*1, gs*1)
      love.graphics.print(wd[y][x], gs*x+(gs/2), gs*y+(gs/2))
    end
  end
  love.graphics.print(me.x .. " and " .. me.y, wd.width * gs + gs, wd.height * gs + gs)
end

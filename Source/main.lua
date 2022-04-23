local gfx = playdate.graphics
import ('CoreLibs/object')
import ('CoreLibs/graphics')

gfx.setColor(gfx.kColorBlack)

buildings = {
  {1, x = 140, y = 60, width = 40, height = 20, z_height = 1.5, distance = 0},
  {2, x = 220, y = 20, width = 40, height = 40, z_height = 3.0, distance = 0},
  {3, x = 160, y = 100, width = 20, height = 20, z_height = 1.1, distance = 0},
  {4, x = 160, y = 140, width = 20, height = 20, z_height = 1.3, distance = 0},
  {5, x = 240, y = 80, width = 20, height = 20, z_height = 4.0, distance = 0},
  {6, x = 220, y = 120, width = 20, height = 20, z_height = 1.2, distance = 0},
  {7, x = 160, y = 180, width = 20, height = 20, z_height = 2.0, distance = 0},
  }
player = {x = 200, y = 120, x_vel = 0, y_vel = 0, height = 0, moving = false}

printTable(buildings)
printTable(player)

function compare(a,b)
  return a[1] > b[1]
end

function playdate.update()
    gfx.clear()
    
    -- draw player
    gfx.drawCircleAtPoint(player.x, player.y, 5)
    
    -- shift buildings
    for building in pairs(buildings) do 
        buildings[building].y -= player.y_vel
        buildings[building].x -= player.x_vel
    end
    
    --update player velocity
    if leftDown then 
      player.x_vel = -2
    elseif rightDown then
      player.x_vel = 2
    elseif player.x_vel >= -1 and player.x_vel <= 1 then
      player.x_vel = 0
    else
      player.x_vel = player.x_vel *.8
    end
    if upDown then 
      player.y_vel = -2
    elseif downDown then
      player.y_vel = 2
    elseif player.y_vel >= -1 and player.y_vel <= 1 then
      player.y_vel = 0
    else
      player.y_vel = player.y_vel *.8
    end
    
    --sort buildings (this means the furthest ones draw first and don't draw over near buildings)
    for i, v in ipairs(buildings) do
        buildings[i][1] = math.sqrt((player.x - buildings[i].x - buildings[i].width/2)^2 + (player.y - buildings[i].y - buildings[i].height/2)^2)
    end
    table.sort(buildings, compare)
    
    for building, v in ipairs(buildings) do
      -- lazy maths
      local width = buildings[building].width
      local height = buildings[building].height
      local topscale = buildings[building].z_height
      local base_nw = {buildings[building].x, buildings[building].y} 
      local base_ne = {base_nw[1] + width , base_nw[2]} 
      local base_se = {base_ne[1], base_ne[2] + height} 
      local base_sw = {base_nw[1], base_se[2]}
      local top_nw = {player.x - (player.x - base_nw[1]) * topscale, player.y - (player.y - base_nw[2]) * topscale}
      local top_ne = {top_nw[1] + width * topscale, top_nw[2]} 
      local top_se = {top_ne[1], top_ne[2] + height * topscale}
      local top_sw = {top_nw[1], top_se[2]}
      
      -- draw base (temp for debugging)
      gfx.drawRect(base_nw[1], base_nw[2], width, height)
      
      -- only draw visible sides
      if player.x - base_ne[1] > 0 then
          gfx.fillPolygon(base_se[1], base_se[2], base_ne[1], base_ne[2], top_ne[1], top_ne[2], top_se[1], top_se[2])
      elseif player.x - base_nw[1] < 0 then
          gfx.fillPolygon(base_sw[1], base_sw[2], base_nw[1], base_nw[2], top_nw[1], top_nw[2], top_sw[1], top_sw[2])
      end
      if player.y - base_se[2] > 0 then
          gfx.fillPolygon(base_sw[1], base_sw[2], base_se[1], base_se[2], top_se[1], top_se[2], top_sw[1], top_sw[2])
      elseif player.y - base_ne[2] <0 then
          gfx.fillPolygon(base_nw[1], base_nw[2], base_ne[1], base_ne[2], top_ne[1], top_ne[2], top_nw[1], top_nw[2])
      end
      
      -- draw top
      gfx.setColor(playdate.graphics.kColorBlack)
      gfx.fillPolygon(top_nw[1], top_nw[2], top_ne[1], top_ne[2], top_se[1], top_se[2], top_sw[1], top_sw[2])
      
      -- add lines to top and visible sides
      gfx.setColor(playdate.graphics.kColorWhite)
      if player.x - base_ne[1] > 0 then
          gfx.drawPolygon(base_se[1], base_se[2], base_ne[1], base_ne[2], top_ne[1], top_ne[2], top_se[1], top_se[2])
      elseif player.x - base_nw[1] < 0 then
          gfx.drawPolygon(base_sw[1], base_sw[2], base_nw[1], base_nw[2], top_nw[1], top_nw[2], top_sw[1], top_sw[2])
      end
      if player.y - base_se[2] > 0 then
          gfx.drawPolygon(base_sw[1], base_sw[2], base_se[1], base_se[2], top_se[1], top_se[2], top_sw[1], top_sw[2])
      elseif player.y - base_ne[2] <0 then
          gfx.drawPolygon(base_nw[1], base_nw[2], base_ne[1], base_ne[2], top_ne[1], top_ne[2], top_nw[1], top_nw[2])
      end
      gfx.drawPolygon(top_nw[1], top_nw[2], top_ne[1], top_ne[2], top_se[1], top_se[2], top_sw[1], top_sw[2])
      
      gfx.setColor(playdate.graphics.kColorBlack)
    end

    playdate.drawFPS(0,0)
end

function playdate.leftButtonDown() leftDown = true end
function playdate.leftButtonUp() leftDown = false end
function playdate.rightButtonDown() rightDown = true end
function playdate.rightButtonUp() rightDown = false end
function playdate.upButtonDown() upDown = true end
function playdate.upButtonUp() upDown = false end
function playdate.downButtonDown() downDown = true end
function playdate.downButtonUp() downDown = false end
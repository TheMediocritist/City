local gfx = playdate.graphics
import ('CoreLibs/object')
import ('CoreLibs/graphics')

gfx.setColor(gfx.kColorBlack)

buildings = {}
buildings.first =   {x = 140, y = 60, width = 40, height = 20, z_height = 1.5, distance = 0}
buildings.second =  {x = 220, y = 20, width = 40, height = 40, z_height = 3.0, distance = 0}
buildings.third =   {x = 160, y = 100, width = 20, height = 20, z_height = 1.1, distance = 0}
buildings.fourth =  {x = 160, y = 140, width = 20, height = 20, z_height = 1.3, distance = 0}
buildings.fifth =   {x = 240, y = 80, width = 20, height = 20, z_height = 4.0, distance = 0}
buildings.sixth =   {x = 220, y = 120, width = 20, height = 20, z_height = 1.2, distance = 0}
buildings.seventh = {x = 160, y = 180, width = 20, height = 20, z_height = 2.0, distance = 0}

player = {x = 200, y = 120, x_vel = 0, y_vel = 0, height = 0}

printTable(buildings)
printTable(player)

for k in pairs(buildings) do print(k) end

function pairsByKeys (t, f)
  local a = {}
  for n in pairs(t) do table.insert(a, n) end
  table.sort(a, f)
  
  printTable(a)
  local i = 0      -- iterator variable
  local iter = function ()   -- iterator function
    i = i + 1
    if a[i] == nil then return nil
    else return a[i], t[a[i]]
    end
  end
  return iter
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
    if player.x_vel >= -1 and player.x_vel <= 1 then
        player.x_vel = 0 
    else
        player.x_vel = player.x_vel * 0.8
    end
    if player.y_vel >= -1 and player.y_vel <= 1 then
        player.y_vel = 0 
    else
        player.y_vel = player.y_vel * 0.8
    end
    
    -- sort buildings
    local buildings_distances = {}
    local max_building_distance = 0
    for i, building in ipairs(buildings) do
        print(i)
        buildings[i].distance = math.sqrt((player.x - buildings[i].x)^2 + (player.y - buildings[i].y)^2)
        local buildingkey = {buildings[i].distance, i}
        table.insert(buildings_distances, buildingkey)
        -- if buildings[building].distance >= max_building_distance then
        --     max_building_distance = buildings[building].distance
        -- end
    end
    
    -- draw buildings
    for building in pairs(buildings) do
        
        -- lazy maths
        topscale = buildings[building].z_height
        base_nw = {buildings[building].x, buildings[building].y} 
        base_ne = {base_nw[1] + buildings[building].width , base_nw[2]} 
        base_se = {base_ne[1], base_ne[2] + buildings[building].height} 
        base_sw = {base_nw[1], base_se[2]}
        top_nw = {player.x - (player.x - buildings[building].x) * topscale, player.y - (player.y - buildings[building].y) * topscale}
        top_ne = {top_nw[1] + buildings[building].width * topscale, top_nw[2]} 
        top_se = {top_ne[1], top_ne[2] + buildings[building].height * topscale}
        top_sw = {top_nw[1], top_se[2]}
        
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

function playdate.leftButtonDown()
    player.x_vel -= 5
end

function playdate.rightButtonDown()
    player.x_vel += 5
end

function playdate.upButtonDown()
    player.y_vel -= 5
end

function playdate.downButtonDown()
    player.y_vel += 5

end

FIND_DOORS = false -- debugging for finding doors
ROT = toybox.rot()

 --local log = function(nn) end-- if nn == "item wood wall,woodenWall" then error() end end

currentFireFrame = 0
_currentFireFrame = 0

function badTiles()
    for x, i in ipairs(self.allTiles) do
        l = true
        for xx = 1, 8 do
            local tt = self:getTile(i._x+dirs8[xx][1], i._y+dirs8[xx][2])
            if tt and not tt:isSolid() then
                l = false
                break
            end
        end
        if l then 
            i:destroy()
        end
    end
end

function markTiles()
    Map.Tile.after_draw=function(self) if self.hasPath then
        draw_rect("line", self.x,self.y,self.w,self.h)
        end
        end
end


intro_map = {
"####################",
"#########e##########",
"########ete#####l###",
"#######e...e########",
"######e.....e#######",
"#####e.......e######",
"####e...x.o..te#####",
"#####e.......e######",
"######e.....e#######",
"#######e...e########",
"########ete#########",
"#########e##########",
"####################",
}

tutorial_map = {
"####################",
"##############.l..##",
"#############.lwl.##",
"#############..l.###",
"##############...###",
"####################",
"##..t....#####..t##",
"##....n..####.....##",
"#D.....h..jp+T...>##",
"##.x......###.....##",
"##......######.k.###",
"####################",
"####################",
"####################",
}



tutorial_map = {
"####################",
"#####GGGGPW#q##.l..##",
"####GGGGG#####lwl.##",
"####GGFG#####..l.###",
"####GGGG######...###",
"##ee#.#e############",
"##..U.U..#####..t##",
"##...Un..####.....##",
"#D.xU..h..jp+T...>##",
"##...U....e##....k##",
"##..U.U.######.k.###",
"####ee#e############",
"#####e##############",
"####################",
}

tutorial_map_2 = {
"################################################################",
"#################################...############......._____####",
"####.....#..########....c.#####.......###########.....____....##",
"####w...#<....###.....g...####..........#########....t..__....##",
"####..........+s.......g.#####.g..........+....+.......___..d..#",
"######.......###.......g.~.. +.....g.....#######....>j.___...###",
"################....g.....O...####.......######......______.####",
"###################...c ......#####..############....._____#####",
"##################........o ######################....______####",
"##################################################..._______####",
"###############################################################",
"################################################################",
}

tutorial_map_3 = {
"#######################################################################",
"#################################...###################.......m....####",
"##....##############....t.#####...k...##################...m..m..m...##",
"###.....#<....#...###..g...########D#####################..t.m..mm..###",
"##............+s.......g.#####.gz....y..e^+^...+....*.v^L.....m..m.mj..#",
"###...###########..##..g.~.. +.....b....#################.....m..m...####",
"###...##########...........O...#######################.......m..m.#####",
"##w..##########...............#####n....################......m...#####",
"###############......#....o ########.~.##################.m...~..m..####",
"##################......#############.####################......c...####",
"######################################################################",
"#######################################################################",
}

tutorial_map_4 = {
"####################",
"##########t#########",
"#########...########",
"########.....#######",
"#######t..>..t######",
"########.....########",
"#########...########",
"##########t#########",
"####################",
}

tutorial_map_5 = {
"######################################################################",
"##########t###########################################################",
"#########...#################.............#####################t#####",
"########.....############..........t.........####........#......######",
"#######t..<x....#####..+....#............#.....+.........+....e.#####",
"########..............##...#.#....#.#...#.#....###..#######......#######",
"#########.......k.o.k.##....#.....#.#....#......###########..t.#######",
"##########.###########.............A.............############..#######",
"########################...........#...........#############..#########",
"############################......###.....############################",
"##########t#################.....##.##....############################",
"#########...################...###.>.###...###########################",
"########.....##############.....##...##.....##########################",
"#######t.....t##############.#...##.##...#.###########################",
"########.....###############.##...#D#...##.###########################",
"#########...#################.##.##.##.##.############################",
"##########t###################...........#############################",
"################################........##############################",
"##################################...################################",
"######################################################################",
}

tutorial_map_6 = {
"####################################################",
"####################################################",
"####################################################",
"####################################################",
"####################################################",
"####################################################",
"####..##################################.###########",
"###..##################################...##########",
"##..........................x.+..y......k.......####",
"##...>..##########################.............#####",
"###...############################....k.o.k...######",
"####..#############################..........#######",
"##################################......k.....######",
"#################################..............#####",
"################################................####",
"##############################....................##",
"####################################################",
"####################################################",
}
 function findRef(target)
    local references = {}
    local stack = {}       -- Stack for iterative DFS
    local seen = {}        -- Track visited tables to avoid cycles
    
    -- Initialize with global environment
    stack[1] = {tbl = _G, prefix = "_G"}
    seen[_G] = true
    
    -- Iterative depth-first search
    while #stack > 0 do
        local current = table.remove(stack)
        local tbl, prefix = current.tbl, current.prefix
        
        for k, v in pairs(tbl) do
            -- Check if value matches target
            if v == target then
                references[#references + 1] = prefix .. ">" .. tostring(k)
            end
            
            -- Process nested tables
            if type(v) == "table" and not seen[v] and v~=target and k~='toybox.libs.animx' and k~='animx' then
                seen[v] = true
                stack[#stack + 1] = {
                    tbl = v,
                    prefix = prefix .. ">" .. tostring(k)
                }
            end
        end
    end
    
for _, path in ipairs(references) do
    print("Reference found at:".. path)
end
    return references
end
local iceColorShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total <= 0.2) {
        float diff = 0.0;
    	// vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
    	return vec4(69.0/255.0, 137.0/255.0, 159.0/255.0, Texel(img, tc).a)*color;
	} else
	return color*Texel(img,tc);//vec4(vec3(color.r, color.g, color.b), (color.a*Texel(img, tc).a));
}
]])

local brownBlackShader = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (total <= 0.2) {
        float diff = 0.0;
    	// vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
    	return vec4(121.0/255.0, 95.0/255.0, 32.0/255.0, 0.0);//Texel(img, tc).a);
	} else
	return vec4(vec3(color.r, color.b, color.g), (color.a*Texel(img, tc).a));
}
]])


local brownBlackShader2 = love.graphics.newShader([[
    
vec4 effect(vec4 color, Image img, vec2 tc, vec2 fc)
{
    vec4 col = Texel(img, tc);
    float total = col.r+col.g+col.b;
    
    if (col.r <102.0/255.0) {//== 121.0/255.0 && col.g == 95.0/255.0 && col.b == 32.0/255.0) {
        float diff = 0.0;
    	// vec3 gc = vec3(dot(vec3(color.r,color.g,color.b), vec3(0.3*diff, 0.59*diff, 0.11*diff)));
    	return vec4(0,0,0,Texel(img,tc).a);//121.0/255.0, 95.0/255.0, 32.0/255.0, Texel(img, tc).a);
	} else
	return color*Texel(img, tc);//vec4(vec3(color.r, color.g, color.b), (color.a*Texel(img, tc).a));
}
]])

local rgba = {"r", "g", "b", "a"}
local function screenmultiply(col1, col2)
    local col = {}
    for x = 1, 4 do
        local a = col1[x] or col1[rgba[x]] or 1
        local b = col2[x] or col2[rgba[x]] or 1
        
        local val = 1 - (1-a)*(1-b)
        
        col[x] = val
    end
    return col
end

local low  = {.3, .4, .5}
local function multiply(t, color, ...)
    local nn, nn2 = 0,2,0,1
    if not color then return t end
    
    for i = 1, #color do
        local ci = color[i]
        local ti = t[i]
        ci = ci == 0 and ti ~= 0 and low[i] or ci
        ti = ti == 0 and ti ~= 0 and low[i] or ti
        
        t[i] = ti*ci-- (math.floor(((t[i] or 1)*255) * (color[i]*255) / 255 + 0.5))/255
    end
    return multiply(t, ...)
end

local _Path = class:extend("_Path")
function _Path:__init__(x,y)
    self.x = x
    self.y = y
end

function _Path:getX()
    return self.x
end

function _Path:getY()
    return self.y
end

function _Path:getPos()
    return self.x, self.y
end

getSpaceTile = function(self)
    local tile
    local count = 0
    local found = false
    local ttile
    local room = room or self
    
    while not tile and count < 100 do
        tile = lume.randomchoice(self:getSpaceTiles())--checkIsPosition(position, lume.eliminate(aTiles), notHave)
        ttile = tile
        
        if tile and not tile.unit then --position == "center" then
            break
        else
            tile = nil
        end
        count = count + 1
    end
    return tile or ttile
end
local function trackedRoom(originalClass)
    return setmetatable({}, {
        __call = function(_, ...)
            -- Create instance through ORIGINAL class, not hardcoded path
            local instance = originalClass(...)
            
            -- Add tracking metatable while preserving existing one
            local originalMeta = getmetatable(instance) or {}
            local trackingMeta = {
                __gc = function(self)
                    print("Room destroyed:", self.name)
                    if self.cleanup then self:cleanup() end
                    -- Preserve original __gc if it existed
                    if originalMeta.__gc then originalMeta.__gc(self) end
                end,
                __index = originalMeta.__index or nil,
                __newindex = originalMeta.__newindex or nil
            }
            
            setmetatable(instance, trackingMeta)
            print("Room created:", inspect(instance, {depth = 1}))
            return instance
        end
    })
end

-- Proper initialization (assuming toybox.Room is the constructor)
Map = trackedRoom(toybox.Room)("Map")  -- First () wraps class, second () creates instance

Object = toybox.BaseObject("Object")

package.loaded["nest.map.dungeonMaker"] = nil
req "map.dungeonMaker"

local BaseObject = toybox.BaseObject("Base")

function Object:create(k)
    k = k or {}
    k.solid = k.solid == nil and false or k.solid
    k.static = k.static == nil and true or k.static
    k.w, k.h = k.w or tw, k.h or th
    
    BaseObject.create(self, k)
   -- self.debug = 1
    self.solid = k.solid == nil and false or k.solid
    self:center()
    
end

local Tile = Tile or Object:extend("Tile")
Map.Tile = Tile

function Tile:create(k)
    k.w, k.h = tw, th
    Object.create(self, k)
    self._x = k._x
    self._y = k._y
    self.fires = 0
    self.lights = 0
    self.gases = {}
    self.gasesAmount = 0
    
    self.myLights = {}
    self.lightIDs = {}
    self.enchantingLights = {}
    self.light = 0
    
    self.life = 10
    
    self.isTile = true
    self.isEntity = true
    
    self.puddles = {}
    self.puddlesLen = 0
    self.puddlesTable = {}
    
    self.temperature = k.temperature or 7
    
    
end

function Tile:__step()
    return
end

function Tile:getAttacked(att, attacker)
    if self.web then
        self.web = nil
    end
    
    if not self.solid or self.chasm then
        return
    end
    
    if self._x == self.room.maxTileX or self._y == self.room.maxTileY or
       self._x == self.room.minTileX or self._y == self.room.minTileY then
        return
    end
    
    local n = 1
    if self._x > (self.room.maxTileX-n) or self._y > (self.room.maxTileY-n) or
       self._x < (self.room.minTileX+n) or self._y < (self.room.minTileY+n) then
        return
    end
    
    if type(att) == "table" then
        attacker = att
        att = att.attack
    end
    
    att = att or 1
    self.life = self.life - att
    
    self.crack = self.life <= 2 and 3 or self.life <= 5 and 2 or self.life <= 8 and 1 or nil
    self:play_sound(string.format("stone_%s",math.random(1,4)))
    
    self:shake(30,.3,35)
    -- self:flash(.15)
        
    if self.life <= 0 then
        self.solid = false
        self.room:reloadFov()
        
        if self.onAttacked then
            self:onAttacked(attacker)
        end
        
        if self.onDestroyed then
            if self:canBeSeen() then
                Entity.spawnDebris(self)
            end
            self:onDestroyed(attacker)
        end
        --p:spawn(
        
        if self.egg then
            local e = self.room:spawn(getValue(self.egg), self)
            if self.egg_postMake then
                self.egg_postMake(e)
            end
        end
        
        if self.seen then
        
        local source = string.format("effects/scorch_%d.png",math.random(1,2))

        local t = self
        if t and not self.chasm then
        
            local i = t.scorch_image or t:add_image(source)
            t.scorch_image = i
            t.scorch_source = i.source
            
            i.color = {1,1,1,.8}
            t.scorch_timer = self.room.timer:tween(45,i.color,{[4]=.01})
        end
        
        end
    end
end

function Tile:canBeSeen()
    return self.drawID == self.room.drawID
end

function Tile:__draw()
    if self == self.room.previousFloorTile then
        self.depth = DEPTHS.WALLS + .1
    end
    
    if self.lava then
        if self == self.room.previousFloorTile or self == self.room.nextFloorTile then
            self:removeWater()
        end
    end
    
    if self.solid or self.wall or self.floor then
        self.grass = nil
    end
    
    
    if self.solid and self.water then
        self.source = getValue(self.room.wallSource)
        self:removeWater()
    end
    
    if self.water and self.fires > 0 then
        self:removeFires()
    end
    
    if self.oldSolid ~= self.solid then
        self.depth = self.solid and DEPTHS.WALLS or DEPTHS.FLOOR
        self.oldSolid = self.solid
    end
    
    if self.item and self.item.tile ~= self and self.item.tile then-- self.item.isCarried then
        self.item = nil
    end
    
    if self.empty then
        return --self.source = nil
    end
    
    local drawn
    
    if self.drawID == self.room.drawID or (self.liglht or 0) >=.5 or lightAll then
        drawn = true
        
        if self.scorch_image then
            local img = self.scorch_image
            img.noDraw = false
        end
        
        Object.__draw(self)
    elseif self.unit or self.item then
        if self.unit then
           self.unit.light_alpha = mmj or 0
           self.room:unsee(self.unit)
        end
        
        if self.item then
            self.item.light_alpha = 0
            self.room:unsee(self.item)
        end
    end
    
    if not drawn and self.seen and not noSee then
        
        if self.scorch_image then
            local img = self.scorch_image
            img.noDraw = true
        end
        
        if self.source or self.hasWaterBorder then
            local nn = .5--.2--.1
            local r,g,b,a = set_color(nn,nn,nn)
            self:simpleDraw(r,g,b,a,nil,true)--draw_image(self.source)
            set_color(r,g,b,a)
        end
    end
    
    if drawn and not nkk then
        self.room:updateCanvasTile(self)
    end
    
    self:drawThrowing()
    -- self.name_tag = math.floor(self:getTemperature()*100)/(100).." (from )"..math.floor(self.temperature*100)/100
end

function Tile:drawThrowing()
    
    if self.throwing then
        local r,g,b,a = set_color(getColor((self.room.throwTooFar or self.throwingBad) and "red" or colors.lime,.5))
        self:draw_image(self.throwingDest and "tileSelectLast.png" or "tileSelect.png")--draw_rect("line",self.x,self.y,self.w,self.h)
        set_color(r,g,b,a)
    end
end

function Tile:increaseTemperature(val)
    log("[Tile] Increasing temperature by "..val)
    self.temperature = self.temperature + val
end


function Tile:decreaseTemperature(val)
    log("[Tile] Decreasing temperature by "..val)
    self.temperature = self.temperature - val
end

function Tile:getTemperature()
    local l = 0
    for ll = 1, #self.myLights do
        l = l + self.myLights[ll][1]
    end
    
    return self.temperature + l
end

function Tile:isCold()
    return self:getTemperature() <= 3
end

function Tile:get_X()
    return self._x
end

function Tile:get_Y()
    return self._y
end

function Tile:isFree(except, obj)
    if self.item and self.item.isObstacle and self.item ~= except then
        return
    end
    
    if self.item and self.item.isWall then error() end
    
    if self.item and self.pedestalLocked and (not self.pedestalLocked.unlocked) and not self.takenPedestalItem then
        -- return
    end
    
    if self.empty then
        -- return
    end
    

    
    local pass = (not self.solid or self.chasm or obj and obj.tile == self) and ((not self.unit or self.unit == except or self.unit == obj) or (nil and obj and obj.team == self.unit.team) or (obj and G_allowUnitPath))
    
    if not pass and not self.solid and self.unit and obj then
        G_unitBlockedPath = true
    end
    
    -- log(string.format("isFree team-%s - team-%s - pass:%s solid:%s", self.unit and self.unit.team or self.unit and "u" or "?", obj and obj.team or obj and "obj" or "?", pass, self.solid))
    
    return pass and not self.isLocked
end

local nn = 7

maxdis = lume.distance(0,0,nn*tw2,nn*th2)

function Tile:addLight(l)
    self.myLights[#self.myLights+1] = l
    self.lightIDs[l[3]] = l
    self.lights = self.lights + 1
    self.light = (self.light or 0)+ l[1]
end

function Tile:removeLight(light)
    local l = self.lightIDs[light] assert(l)
    self.lights = self.lights - 1
    self.lightIDs[light] = nil
    self.light = lume.max(0,(self.light or 0) - l[1])
    assert(lume.remove(self.myLights, l))
end

local waterEdges = {}
local mask_shader =
love.graphics.newShader[[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      if (Texel(texture, texture_coords).rgba == vec4(0.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }  if (Texel(texture, texture_coords).rgb == vec3(1.0)) {
         // a discarded pixel wont be applied as the stencil.
         discard;
      }
      return vec4(1.0);
   }
]]

local toWater

local function drawWaterEdge()
    love.graphics.setShader(mask_shader)
    toWater:draw_image(toWater.waterEdge)
    love.graphics.setShader()
end

    local function multitply(cr,c1)
        for x = 1, #cr do
            cr[x]=cr[x]*(c1[x] or 1)
        end
    end
    
function Tile:draw(dt) --self.name_tag=self.lights..": "..(self.light or "0")
    if self.chasm and self.scorch_image then
        self.scorch_image.alpha = 0
    end
    
    local player = self.room.player
    self:check_shake(player.dt or 1/30)
    
    local dis = lume.distance(self.x, self.y, player.x, player.y)
    self.dis = dis
    local r,g,b,a = lg.getColor()
    
    if self.solid and (self.nextFloor or self.previousFloor) then
        self.solid = nil
    end
    if not lightAll then
        local aa = dis/(maxdis+(self.room.addedSight or 0)+(ADDED or 0))
        local light = 1
        local light2 = 0
     --   if ddis then
       --     light2 = 1
    --    end
    
   -- self.color = {0,0,0}
    
        local oc = self.color
        
        local lightSource = 0
            
        local lenm = #self.myLights --debugp
        if lightAll or lenm>0 or self.myLight then--??
            light = myLight or light or lightAll and 1 or 0--self.myLight or light or 1
            light2 = lightAll and 1 or 0--1
            local donec= {}
            local col = self.color
            local doAdd
            for i = 1, lenm or 1 or lenm do
                --i = math.random(1,lenm)
                local addc = addc
                local l = self.myLights[i]
                if l[3].source and l[3].source.oiRemoved then
                    self.room:removeLight(l[3])
                end
                
                if l[3].source == self then
                    lightSource = lightSource + 1
                end
                
                local lightVal = math.abs(self.light or 0)
                local ii =(((1-aa)*light)+(lightVal))/((lightVal) + 1)-- l[4]
                local iii = II or l[6]--addLight---1--lightth
                --local ii = 1
                ii = lume.min(ii, .9)
                local color = l[2] or colors.green--getColor(l[2] or "black")--, l[3].alpha)
                if l[3].alpha then
                    color = lume.copy(getColor(color))
                    for x = 1, 3 do
                        color[x] = color[x]--*l[3].alpha assert(color[x]>=0) assert(ii<=1,ii)
                    end
                    ii=.5--self.color = color
                    -- light.alpha
                    color[4]=l[3].dying and l[3].alpha or lume.max(.4,l[3].alpha)
                    local k = 1-color[4]
                    iii = lume.min(iii,color[4])
                    if lenm == 1 then
                        local kk = getColor(self.color or "white")
                        
                        local k1, k2, k3 = 1, 1, 1
                        color = {lume.min(color[1]+(k1-color[1])*k,1), lume.min(color[2]+(k2-color[2])*k,1), lume.min(color[3]+(k3-color[3])*k,1)}
                    else
                        color = {lume.min(color[1]+(1-color[1])*k,1), lume.min(color[2]+(1-color[2])*k,1), lume.min(color[3]+(1-color[3])*k,1)}
                    end
                    
                    addc = addc2
                    -- doAdd = true
                    --break
                end
                
                --local color = donec[l[2]] and {0,0,0} or color--
                
                local ff = 1
                -- if not l[3].flick then l[3].flick=true l[3].flicker=math.random()>.4 end
                if l[3].flicker then
                    if (not l[3].flickerTimer or (love.timer.getTime()-l[3].flickerTimer)>(l[3].flickerTime or .2)) then
                        l[3].flickerTimer = love.timer.getTime()
                        l[3].flickerTime = math.random(15,30)/100
                        l[3].flicker = math.random(70, 100)/100
                    end
                    ff = l[3].flicker
                end
                
                local color = {
                    lume.max(0.1,(color[1]+1*iii)*ff),
                    lume.max(0.1,(color[2]+1*iii)*ff),
                    lume.max(0.1,(color[3]+1*iii)*ff)
                }
                
                self.color =
                    lenm == 1 and color or
                    (doAdding and addc(getColor(self.color or "black"),color,0.5 or ii)) or 
                    (not mcc or true) and multiply(getColor(self.color or "white"),color)
                    -- or addc(getColor(self.color or "black"),color or color,ii)
                
                donec[l[2]] = true
                light = light + lume.max(not l[3].dying and l[1] or 0,0)
                if  l[3].enchanting then
                    self.color = color--addc(getColor(col or "white"),color,ii)
                    break
                end
            end
            
            if lenm == 0 then self.color = nil oc = nil end
        end
        --self.color = self.room:getTileLight(self)--lightcol
        
        local lightVal = lume.max(self.light or 0, 0)
        local lightD = (self.light and self.light<=0 and 0 or lume.min(3,self.lights or 1))
        local p = lume.max(1-aa, lume.max((((1-aa)*light)+(lightVal and 0))/(lume.max(1,lightD)),.2))+(lightVal>.15 and (lightVal/lightD) or 0)+(lightSource/2)+(self.unit and self.unit.light and 3 or 0)
        --self.name_tag = (math.floor(p*100)/100)..","..(math.floor((self.light or 0)*10)/100)
        
            if self.color then for x = 1,#self.color do self.color[x] = math.floor(self.color[x]*100)/100 end
                --self.name_tag = inspect(self.color)
            end
        
        
        if self.unit == self.room.player then p = 1 end
        
        self.color = self.color or {1,1,1}
        self.lightp = p
        self.colorp = self.color
        
        if self.unit then
            self.unit.light_alpha = lume.max(mmj or 0,(self.unit.skinAlpha)-(1-p))
            self.unit.color = ccl or self.color and getColor(self.color,1)--or self.unit.color
            self.unit.colorr = self.unit.color or self.unit.col
            local p = self.room.player
            if self.unit:isSubmerged() then
                if not p.tile.water then
                    self.room:unsee(self.unit)
                    self.unit.light_alpha = 0
                
                -- partially see unit
                elseif not p.submerged then
                    self.room:see(self.unit)
                    self.unit.light_alpha = self.unit.light_alpha*.6
                
                -- player is fully submerged too
                else
                    self.room:see(self.unit)
                end
                
            elseif p.submerged then
                if self.water then
                    self.room:see(self.unit)
                    self.unit.light_alpha = self.unit.light_alpha*.6
                else
                    self.room:unsee(self.unit)
                    self.unit.light_alpha = 0
                end
            else
                self.room:see(self.unit)
            end
        end
        
        if self.item then
            self.item.light_alpha = p
            self.item.color = self.item.color and addc(getColor(self.item.color),getColor(self.color),.5) or self.color
            self.room:see(self.item)
            if self.item.isDestroyed then
                self.item = nil
                log("HMMMMMMMM hm, item was lurking in tile","yellow")
            end
            
        end
        
        if self.scorch_image then
            local img = self.scorch_image
            img.light_alpha = p
            img.color = self.color
        end
        
        local tile = self
        --tile.name_tag=tile.light and ((tile.light)/1)..","..self.lights
        
        if not self.color then
            local pp = p
            local p = 1
            love.graphics.setColor(p,p,p,pp+light2)
        else
            love.graphics.setColor(getColor(self.color,(((nil and self.color[4]) or p+light2))/2))
        end
        self.color = oc
        self.image_alpha = p+light2
    end
    
    
    local tr, tg, tb, ta = lg.getColor()
    local ta = self.image_alpha
    
    self.colorUsed = {tr*ta, tg*ta, tb*ta, 1}
    lg.setColor(1,1,1,1)
    self.color = nil
    self.image_alpha=1
    if self.userCol then warn(": "..inspect(self.colorUsed)..","..inspect(self.userCol)) end
    
    self.seen = true
    
    local keepLeftChasmLine, keepRightChasmLine
    self.shader = nil
    
    -- self.soily = true
    
    self.soily = self.soily or self.room.soily
    
    if not self:isSolid() and self.soily and not self.water and not self.chasm then
        self.shader = brownBlackShader2
        -- if self.unit then self.unit.shader = brownBlackShader3 end
        -- if self.item then self.item.shader = brownBlackShader3 end
    elseif not self:isSolid() and (self.icy or self.room.icy) then
        self.shader = iceColorShader
    else
        self.ogShader = getValue(self.solid and self.room.wallShader or self.room.floorShader)
        self.shader = self.ogShader or nil
    end
    
    --[[
    Duplicate of this code is a little bit more down
    if self.soily and not self.solid then
        self.imId = self.imId or getValue({1,2,3,4,4,5,6,6,5,6,6,6,5,6,6}) math.random(1,5)
        self.source = not self.solid and self.floorSource or string.format("tiles/patch/patch%s.png", self.imId%2+1) or string.format("tiles/soil/soil%s.png",self.imId%2)
    end
    ]]
    
    self.shader = self.ogShader or self.shader
    
    if self:isSolid() or self.doored then
        --local sh = brownBlackShader--self.room.solidTileShader
        
        self.solidPic = true
        
        self.pedestal = nil
        
        self.source = self.hasWall and nil
        if not self.hasWall then
            self.wallSource = getValue(wallSource) or self.wallSource or getValue(self.room.wallSource) or "tile.png"--draw_rect("line",self.x,self.y,self.w,self.h)
            self.source = self.source or self.wallSource
        end
        
        local ro = self.room
        local t = self.room:getTile(self._x, self._y-1)
        local tr = ro:getTile(self._x+1, self._y)
        local tl = ro:getTile(self._x-1, self._y)
        local td = ro:getTile(self._x, self._y+1)
        if (not t or not t:isSolid()) and (not tr or tr:isSolid()) and (not tl or tl:isSolid()) then
            --self.source = "toptile.png"
        end
        
        local self = self.item and self.item.isWall and self.item or self
        
        local border = self.soily and "borders" or "borders_straight"
        if (not tr or not tr:isSolid()) and not self.drawRightBorder then
            local i = self:add_image(string.format("tiles/%s/right.png", border))
            i.shader = sh
            self.drawRightBorder = i
        end
        
        if (not tl or not tl:isSolid()) and not self.drawLeftBorder then
            local i = self:add_image(string.format("tiles/%s/left.png", border))
            i.shader = sh
            self.drawLeftBorder = i
        end
        
        if (not td or not td:isSolid()) then 
            if not self.drawBottomBorder and (not td or not td:isChasm()) then
                self.drawBottomBorder = self:add_image(string.format("tiles/%s/bottom.png", border))
            elseif td and td:isChasm() and self.drawBottomBorder then
                self:remove_image(self.drawBottomBorder)
                self.drawBottomBorder = nil
            end
        end
        
        if (not t or not t:isSolid()) and not self.drawTopBorder then
            self.source = self.isItem and self.source or "toptile2.png"
            self.drawTopBorder = true
            local i = self:add_image(string.format("tiles/%s/top.png", border))
            i.shader = sh
        end
        
    elseif self:isChasm() then
    
        if self.scorch_image then
            if self.scorch_timer then
                self.room.timer:cancel(self.scorch_timer)
                self.scorch_timer = nil
            end
            self.scorch_image.color[4] = 0
        end
        
        
        
        if self.water then
            for t, d in pairs(self.waterSurrounds) do
                t.waterSurrounding[d] = nil
                t.hasWaterBorder = false
            end
            
            self.water, self.waterSurrounds = nil
        end
        
        
        
        local m = mmm or .05
        local nn = 0
        local r,g,b,a = set_color(.25,.25,.25,.25)--m,m,m)--colors.white)
        draw_rect("fill",self.x+nn,self.y+nn,self.w-nn,self.h-nn)
        set_color(r,g,b,a)
        
        local ro = self.room
        local t = self.room:getTile(self._x, self._y-1)
        local tr = ro:getTile(self._x+1, self._y)
        local tl = ro:getTile(self._x-1, self._y)
        local td = ro:getTile(self._x, self._y+1)
        if (not t or not t:isSolid()) and (not tr or tr:isSolid()) and (not tl or tl:isSolid()) then
            --self.source = "toptile.png"
        end
        
        self.grass = nil
        self.source = nil
        local self = self.item and self.item.isWall and self.item or self
        
        
    
        local border = "borders_straight"
        if (tr and not tr:isSolid()) then
            if not self.drawRightBorder and not tr:isChasm() then
                self.drawRightBorder = self:add_image(string.format("tiles/%s/right.png", border))
            elseif tr:isChasm() and self.drawRightBorder then
            
                -- checking
                self.drawRightBorder.w = "nil"
                self.drawRightBorder.source = "creatures/wisp/0.png"
                
                self:remove_image(self.drawRightBorder)
                self.drawRightBorder = nil
            end
            
            if tr:isChasm() and not tr.drawTopBorder and self.drawTopBorder then
                local n = self.w-2
                self.rightChasmLine = self.rightChasmLine or self:add_image("tiles/right_chasm_line.png")
                keepRightChasmLine = true
                
                --lg.line(self.x+n, self.y, self.x+n, self.y+self.h/3)
            end
            
        end
        
        if (tl and not tl:isSolid()) then
            if not self.drawLeftBorder and not tl:isChasm() then
                self.drawLeftBorder = self:add_image(string.format("tiles/%s/left.png", border))
            elseif tl:isChasm() and self.drawLeftBorder then
                self:remove_image(self.drawLeftBorder)
                self.drawLeftBorder = nil
            end
            
            if tl:isChasm() and not tl.drawTopBorder and self.drawTopBorder then
                local n = 2
                self.leftChasmLine = self.leftChasmLine or self:add_image("tiles/left_chasm_line.png")
                keepLeftChasmLine = true
                
                --lg.line(self.x+n, self.y, self.x+n, self.y+self.h/3)
            end
        end
        
        if (td and not td:isSolid()) then 
            if not self.drawBottomBorder and not td:isChasm() then
                self.drawBottomBorder = self:add_image(string.format("tiles/%s/left.png", border))
                local d = self.drawBottomBorder
                d.offset_y = self.offset_y+self.h-2
                d.angle = 90
                
                
            elseif td.isChasm and self.drawBottomBorder then
                self:remove_image(self.drawBottomBorder)
                self.drawBottomBorder = nil
            end
        end
        
        if (t and not t:isSolid()) then
            if not t:isChasm() and not self.drawTopBorder then
                --self.source = self.isItem and self.source or "toptile2.png"
                self.drawTopBorder = true
                local border = "borders"
                self.drawTopBorder = self:add_image(string.format("tiles/%s/top.png", border))
                local k = self:add_image(string.format("tiles/chasm_top.png", border))
                --k.offset_y = self.offset_y + self.h/3
                self.drawTopBorder2 = k
            elseif t:isChasm() and self.drawTopBorder then
                self:remove_image(self.drawTopBorder)
                self:remove_image(self.drawTopBorder2)
                self.drawTopBorder = nil
                self.drawTopBorder2 = nil
            end
            
        end
    
    
    else
        if self.solidPic then
            self.images = {}
            self._imagesLen = 0
            self.solidPic = nil
        end
        
        self.imId = self.imId or getValue({1,2,3,4,4,5,5,5,6,6,6,6,6,6,6}) math.random(1,5)
        self.source = self.floorSource or self._floorSource or getValue(self.room.floorSource) or string.format("tiles/floors/floor%s.png",self.imId)
        self._floorSource = self.source or self._floorSource
    end
    
    
    if self.soily and not self.solid then
        self.imId = self.imId or getValue({1,2,3,4,4,5,6,6,5,6,6,6,5,6,6}) math.random(1,5)
        self.source = not self.solid and self.floorSource or string.format("tiles/patch/patch%s.png", self.imId%2+1) or string.format("tiles/soil/soil%s.png",self.imId%2)
    end
    
    
    if (self.rightChasmLine) and (not keepRightChasmLine) then
        self:remove_image(self.rightChasmLine)
        self.rightChasmLine = nil
    end
    
    if (self.leftChasmLine) and (not keepLeftChasmLine) then
        self:remove_image(self.leftChasmLine)
        self.leftChasmLine = nil
    end

    
    if true then
        for x, i in pairs(self.noises or {}) do
            local alpha = lume.min(1.5,i[1])
            i.val = (i.val or i[1] or 1) - 1/2
            if i.val > 0 then
            lg.setColor(1,0,0,(i.val+alpha/2)/2)
            local n = 0
            local n2 = n/2
            draw_rect("fill",self.x+n2,self.y+n2,self.w-n,self.h-n)
            end
        end
    end
    
    if true then
        for x = 1, #self.enchantingLights do
            i = self.enchantingLights[x]
            local alpha
            if i then
                alpha = i[3].alipha or lume.min(1.5,i[1])
                i.val = (i.val or i[3].lifeTime or (i[1] or 1)/3) - (self.room.dt or 1/30)--lifeTime
            end
            
            if i and i.val > 0 then
                -- lg.setColor(getColor(i[2],(i.val+alpha)/2))
                self.colorUsed = getColor(i[2],(i.val+alpha)/2)
                local n = 0
                local n2 = n/2
                -- draw_rect("fill",self.x+n2,self.y+n2,self.w-n,self.h-n)
            elseif i then
                table.remove(self.enchantingLights, x)
            end
        end
    end
    
    
    local rr,gg,bb,aa=r,g,b,a
    local r,g,b,a = lg.getColor()
    do local rr,gg,bb,aa =set_color(r*a,g*a,b*a,1) end
    self:simpleDraw(rr,gg,bb,1,true)
end

function addCarpetsToRoom(room)
    local x = room.minTileX
    local y = room.maxTileY
     
    for x, i in ipairs(room.allTiles) do
    
        local carpet2 = true
        local c2 = 0
        local free = not i:isSolid()
        
        for d = 1, not free and 0 or 4 do
            local dd = dirs4[d]
            local t = i.room:getTile(i._x+dd[1], i._y+dd[2])
            local t2 = i.room:getTile(i._x+dd[1]*2, i._y+dd[2]*2)
            if (
                ((t and not t:isSolid()) and (t2 and t2:isSolid() or not t2)) or
                (t and t.hasDoor or t2 and t2.hasDoor)
            ) then
                
                c2 = c2 + 1
                
                
            end
            
            if t and t:isSolid() then
                c2 = 5
            end
        end
        
        carpet2 = c2 == 1 or c2 == 3 or c2 == 2
        
        if free and not i:isChasm() then
            i.isCorridor = true
            i.isEntrance = true
            i.room:spawnItem(carpet2 and "carpetFloor2" or "carpetFloor", i)
        end
    end
end
                

function chasm() for x = 1, 8 do for y=1,2 do local d = dirs8[x]
    local xx = toybox.room:getTile(pl.tile._x+d[1]*y, pl.tile._y+d[2]*y)
    if xx then xx.chasm = true end end end
end

function Tile:isChasm()
    if self.nextFloor or self.previousFloor then
        self.chasm = nil
    end
    
    return self.chasm
end

Tile.dhraw=function(self)
    local r,g,b,a = set_color(getColor(self.color or self.solid and "white" or "black",self.image_alpha))
    draw_rect(self.solid and "line" or "fill",self.x,self.y,self.w,self.h)
    set_color(r,g,b,a)
end

-- where r,g,b,a are the origional colour values to return to
function Tile:simpleDraw(r,g,b,a,notSimple,notSeen)
    -- set_color(r,g,b,a)
    
    if self.colorUsed and not notSeen then
        -- set_color(self.colorUsed)
        self.color=nil
    end
    
    --assert(a>=1,a)
    local i = {}
    if self.room.player.submeruged and not self.water then
    
        local n = colors.black--royalblue
        local rr,gg,bb,aa = set_color(n[1],n[2],n[3],.7)
        
        draw_rect("fill",self.x,self.y,self.w,self.h)
        
        set_color(rr,gg,bb,aa)--r,g,b,a)
        --return
    end
    
    if self.solid then
        self.water = nil
    end
    
    if self.water then
        self.source = self.lava and currentLavaSource or currentWaterSource
        
        -- for now --!!??
        self.isDeep = nil
        self.water.isDeep = nil
        -- end for now --
        
        if self.water.color then
            set_color(getColor(self.water.color))
        end
        
        if self.water.isDeep then
            local r,g,b,a = lg.getColor()
            local v = .2
            set_color(r*v, g*v, b*v, a)
        end
    end
    
    local lr,lgg,lbb,la = lg.getColor()
   -- self.color = {lr,lgg,lbb,la}
    
    if self:isChasm() then
        self.source = nil
        self.water = nil
    end
    
    if self.floor then
        self:draw_image(self.floor.source)
    else
        self:draw_source_image()
    end
    
    if self.water then
        if not self.water.isDeep  then
            local ii = self.colorUsed
            --assert(ii[1]==lr and ii[2]==lgg and ii[3]==lbb,inspect(ii)..","..inspect({lr,lgg,lbb}))
        end
        --self.source = currentWaterSource
    elseif self.waterSurrounding and not self.solid then
        for x, i in pairs(self.waterSurrounding) do
            
            if i.water and i.water.isDeep then
                i.water.isDeep = false
            end
            
            local source = string.format("water_edges/%s.png", x)
            
            toWater = self
            
            local r,g,b,a,r2,g2,b2,a2
            
            
            if self:isChasm() then
                if (x == "bottom" and self.drawTopBorder) then
                else
                    goto skip
                end
            end
            
            if i.colorUsed then
                --r,g,b,a = set_color(i.colorUsed)
               -- set_color(r*a,g*a,b*a,1)
            end
            
            if i.water.color then
                r,g,b,a = set_color(getColor(i.water.color))
            end
            
            -- local dd,gg,bv,aa=lg.getColor() assert(aa>=1,aa..","..inspect(i.colorUsed))
            
            -- no draw border of water
            --if 1 then self:draw_image(source) end
            
            self.waterEdge = source
            
            r2,g2,b2,a2 = set_color(1,1,1)
            lg.stencil(drawWaterEdge, "replace", 1)
            lg.setStencilTest("greater", 0)
            
            -- mj =mj or i tjj=tjj or self
            -- i.userCol = i==mj and self==tjj and {r2,g2,b2,a2,i.colorUsed and true or false}
            
            set_color(r2,g2,b2,a2)
            
            if 1 then self:draw_image(i.lava and currentLavaSource or currentWaterSource, true) end
            lg.setStencilTest()
            
            self:draw_image(string.format("water_edges/%s_outline.png", x), true)
            
            if x == "top" then
                self:draw_image("water_edges/top_cover.png",true)
            end
            
            self.source = nil
            toWater = nil
            
            if r then
                set_color(r,g,b,a)
            end
            
            ::skip::
            
        end
    end
    
    self:draw_images()
    
    self.crack = self.life <= 2 and 3 or self.life <= 5 and 2 or self.life <= 8 and 1 or nil
    
    if self.crack and self.solid then
        local img = game:getAsset(string.format("tiles/cracks/%s.png",self.crack-1))
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th)
        local gww, ghh = tw, th
        lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
    end
    
    if self.drawCrack then
        local img = game:getAsset(string.format("tiles/cracks/%s.png",self.drawCrack-1))
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th)
        local gww, ghh = tw, th
        lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
    end
    
    -- chess effect
    if false or CHESS then
    if (self._x+self._y)%2 == 0 then
    local r,g,b,a = set_color(getColor("grey",.3))
    draw_rect("fill",self.x,self.y,self.w,self.h)
    set_color(r,g,b,a)
    end
    end

    self:drawPuddles()
    self:drawVent()
    
    
    if self.grass then
        local g = self.grass
        local img = game:getAsset(g.source)
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, g.w or tw, g.h or th)
        lg.draw(img, self.x+g.w/2, self.y-(g.h-th)+g.h/2, 0, gw, gh, iw/2, ih/2)
    end
    
    
    if self.pedestal then
        local img = game:getAsset("pedestal.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th)
        local gww, ghh = tw, th
        lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
    end
    
    self:drawDoor()
    
    if self.nextFloor or self.previousFloor then
        self:draw_source_image()
        local img = game:getAsset(self.previousFloor and "upstairs.png" or "downstairs.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th*2)
        local gww, ghh = tw, th*2
        lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
    end
    
    self:drawWeb()
    
    
    if self.ice then
        local img = game:getAsset("ice.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th)
        local gww, ghh = tw, th
        self.ice:draw()---- lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
    end
    
    
    
   if true and self.fires>0 then
   set_color(1,1,1,1)
   for id, gas in pairs(self.gases) do
        if gas[3].isFire then
            gas[3]:drawFire(self, gas)
            break
        end
    end end
    
    
    
    --self.color = oc
    lg.setColor(r,g,b,a)
    
    
    
    local currentTurn = self.room.currentTurn--(self.room.player.currentTurn or 0)
    local toUpdate = (self.lastUpdated or 0) ~= currentTurn
    
    local temp = self:getTemperature()
    local lowTemp = temp<=3
    lowLowTemp = temp<0
    
    if lowTemp and notSimple and toUpdate then
        if math.random() > .8 then
            spawnFrost(self)
        end
    end
    
    if toUpdate and self.hasDoor and self:doorIsOpen() then
    
        if self.item or self.unit then
            self.leaveOpen = 3
        end
        
        self.leaveOpen = (self.leaveOpen or 2)-1
        
        if (self.leaveOpen or 0) <= 0 then
            self.leaveOpen = nil
        end
        
    end
    
    
    if (self.water or self.puddlesLen>0) and (self.lastIce or 0)<=0 and lowLowTemp and not self.ice and toUpdate then
        self.lastIce = 3
        self:spawnIce(temp)
    end
    
    if toUpdate then
        self.lastIce = (self.lastIce or 0)-1
        
        if self.toSolidify then
            self.toSolidify = self.toSolidify - 1
            if self.toSolidify <= 0 then
                self.toSolidify = nil
                self.chasm = nil
            end
        end
        
        local t = self.temperature
        if t > 8 and self.fires<1 then
            t = t - .5
        elseif t < 4 and not self.ice then
            t = t + .5
        end
        self.temperature = t
    end
    
    self.lastUpdated = currentTurn

end

function Tile:spawnIce(v)

        self.ice = self.room:spawnItem("ice", self, nil, true)--self.water
        assert(self.room.items[self.ice])
        self.ice:addLog("Some ice forms!")
        
        self:play_sound("freeze")
         
        if self.ice then
            self.ice.water = self.water
        
            self.ice.color = self.water and self.water.color or self.puddleColor or self.ice.color
            
            log("[ICE] temp "..math.abs((v or math.abs(temp))).." | "..tostring(self.ice))
            self.ice.lifeTime = math.abs((v or math.abs(temp)))+3
            self.ice.life = self.ice.lifeTime
            self.iceLifeTime = nil
            

            self.ice.itemColor = self.ice.color
            warn(inspect(self.ice.color).." ice color ")
        
            if self.water then
                if self.water.isWaterBody then
                    self.ice.isObstacle = false
                    self.ice.isThrowObstacle = true
                    self.iceFloor = true
                end
            
                self:removeWater()
            end
        end
end

local function runeExclude(self, creature)
    self.excluded[creature] = true
    
    return self
end

local function runeInclude(self, creature)
    self.excluded[creature] = false
    
    return self
end

local function runeDestroy(self)
    self.room:addEnchantLight(self.tile, 3, self.color, 3)
    self.tile.rune = nil
    
    self.teleportRune = false
    
    return self
end

function Tile:addRune(image, color, data)
    self.rune = data and lume.copy(data) or {source=image or "rune.png"}
    self.rune.light = self.room:addLight(self, 3, color or "lime")
    self.rune.color = color or "lime"
    
    self.rune.tile = self
    self.rune.room = self.room
    
    self.rune.exclude = self.rune.exclude or runeExclude
    self.rune.include = self.rune.include or runeInclude
    self.rune.destroy = self.rune.destroy or runeDestroy
    self.rune.excluded = self.rune.excluded and lume.copy(self.rune.excluded) or {[self.room.player] = true}
    
    return self.rune
end

function Tile:addTeleportRune(...)
    local rune = self:addRune(...)
    self.teleportRune = true
    
    self.room.teleportRunes[#self.room.teleportRunes+1] = self
    self.teleportRuneID = #self.room.teleportRunes
    
    return rune
end

function Tile:_getTileToTeleportTo()
    local tid = self.teleportRuneID
    local list = self.room.teleportRunes
    if tid then
        for x = tid+1, #list do
            local tile = list[x]
            if tile and tile.rune then
                return tile
            end
        end
        
        local t = list[1]
        
        if t == self then
            return false
        end
        
        return t
    end
end

function Tile:getTileToTeleportTo(isItem)
    local tile = self:_getTileToTeleportTo()
    
    if tile and (isItem or (not tile.unit and not self.item)) then
        return tile
    else
        return false
    end
end

local wdirs = {{1,0},{-1,0},{0,-1},{0,1}}
local dirNames = {"right", "left", "top", "bottom"}
function Tile:addWater(data, spread, isWaterBody, isDeep, wcolor, lava) -- addpuddle
    local sp = type(data) ~= "table" and data
    if sp then
        data = nil
    end
    
    sp = sp or spread
    
    local water = data or {
        spread = sp or false,
        color = wcolor or nil
    }
    
    if water.lava or lava then
        self.lava = true
        self.room:addLight(self, 3, "orange")
    end

    
    if self.water then
        local w = self.water
        w.value = (w.value or 0)+(water.value or 0)
        
        if w.value == 0 then
            w.value = nil
        end
        
        w.spread = water.spread or w.spread
        
    else
    
    self.waterSurrounds = {}
    for x = 1, 4 do
        local d = wdirs[x]
        local t = self.room:getTile(self._x+d[1], self._y+d[2])
        if t and not t.water then
            t.waterSurrounding = t.waterSurrounding or {}
            t.waterSurrounding[dirNames[x]] = self
            self.waterSurrounds[t] = dirNames[x]
            t.hasWaterBorder = true
        end
    end
    
    self.water = water
    end
    
    
    self.water.isDeep = isDeep or self.water.isDeep
    self.water.isWaterBody = isWaterBody or self.water.isWaterBody
    
    self.room.checkPuddles[self] = true
end

function Tile:removeWater()
    local w = self.water
    
    if not w then
        return
    end
    
    
    for x = 1, 4 do
        local d = wdirs[x]
        local t = self.room:getTile(self._x+d[1], self._y+d[2])
        if t and t.waterSurrounding then
            t.waterSurrounding = t.waterSurrounding or {}
            t.waterSurrounding[dirNames[x]] = nil
        end
    end
    
    if self.puddlesLen <= 0 then
        self.room.checkPuddles[self] = nil
    end
    
    self.water = nil
    self.lava = nil
end


function Tile:doorIsOpen()
    return self.item or self.unit or self.leaveOpen
end

function Tile:drawDoor()

    if self.hasDoor then
        local r,g,b,a = lg.getColor()
        
        if self.isLocked then
            --self.solid = true----set_color(colors.darkgrey)
        else
            self.solid = false
        end
        
        local nn = 1
        local img = game:getAsset(self:doorIsOpen() and "door_open.png" or self.isLocked and "locked_door.png" or "doork.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, tw, th*nn)
        local gww, ghh = tw, th*nn
        lg.draw(img, self.x+gww/2, self.y-(ghh-th)+ghh/2, 0, gw, gh, iw/2, ih/2)
        
        set_color(r,g,b,a)
        
    elseif self.doored then
        self.doored:drawDoor()
    end
end

function Tile:blocksView()
    return self:isSolid() or (self.hasDoor and not self:doorIsOpen())
end


function Tile:drawVent()
    if self.pressurePlate then
        local r,gg,b,a = set_color(getColor(self.pressurePlate.color or "white", self.image_alpha))
        
        local g = self
        
        local img = game:getAsset(
            (self.unit or self.item) and (self.pressurePlate.onSource or "items/buttons/on.png") or
            self.pressurePlate.offSource or self.pressurePlate.source or "items/buttons/off.png"
        )
        
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, g.w or tw, g.h or th)
        lg.draw(img, self.x+g.w/2, self.y-(g.h-th)+g.h/2, 0, gw, gh, iw/2, ih/2)
        
        set_color(r,gg,b,a)
        
    end
    
    if self.vent then
        local g = self.vent
        local img = game:getAsset(g.source or "vent.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, g.w or tw, g.h or th)
        g.w, g.h = g.w or tw, g.h or th
        
        lg.draw(img, self.x+g.w/2, self.y-(g.h-th)+g.h/2, 0, gw, gh, iw/2, ih/2)
    end
    
end

function Tile:drawWeb()
    if self.web then
        local r,gg,b,a = set_color(getColor(self.web.color or "white", self.image_alpha))
        local g = self.web
        local img = game:getAsset(g.source or "web.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, g.w or tw, g.h or th)
        g.w, g.h = g.w or tw, g.h or th
        lg.draw(img, self.x+g.w/2, self.y-(g.h-th)+g.h/2, 0, gw, gh, iw/2, ih/2)
        set_color(r,gg,b,a)
    end
    
    if self.rune then
        local r,gg,b,a = set_color(getColor(self.rune.color or "white", self.image_alpha))
        local g = self.rune
        local img = game:getAsset(g.source or "rune.png")
        local iw, ih = img:getDimensions()
        local gw, gh = resizeImage(img, g.w or tw, g.h or th)
        g.w, g.h = g.w or tw, g.h or th
        lg.draw(img, self.x+g.w/2, self.y-(g.h-th)+g.h/2, 0, gw, gh, iw/2, ih/2)
        set_color(r,gg,b,a)
        if self.teleportRuneID then
            local r,g,b,a = set_color(1,1,1,a)
            local font = lg.getFont()
            local scale = 2.5
            local text = tostring(self.teleportRuneID)
            local w = font:getWidth(text)*scale
            local h = font:getHeight()*scale
            lg.print(text, self.x+self.w/2-w/2, self.y+self.h/2-h/2,0,scale,scale)
            set_color(r,g,b,a)
        end
    end
end

function Tile:addWeb(w)
    if self.fires > 1 or (self.unit and self.unit.onFire) then
        self.web = nil
        return
    end
    
    if not self.web then
        self.web = lume.copy(w)
    else
        self.web.color = w.color or self.web.color
        self.web.strength = self.web.strength + w.strength
    end
end

function Tile:isWebbable()
    if self.solid or self.fires > 1 or (self.unit and self.unit.onFire) then
        return false
    end
        
    return true
end

function Tile:splashPuddles()
    local done
    
    if self.puddlesLen > 1 then
        self:play_sound(string.format("splash_%s", math.random(1,2)))
    end
    
    for x = 1, self.puddlesLen do
        done = true
        local p = self.puddles[x]
        
        self:drawSplash(p.color, p.value+.2)
        
        p.splashed = p.splashed or {count = 0}
        
        if p.value >= .25 and p.splashed.count < 4 then
            local value = p.value/2
            local newValue = p.value/8
            p.splashed.count = p.splashed.count + 1
            
            for d = 1, 4 do
                local dir = dirs4[d]
                local tile = self.room:getTile(self._x+dir[1], self._y+dir[2])
                if not tile.solid and (p.added or 0)<2 and math.random()>.5 and not p.noSpread then
                    p.value = p.value - newValue
                    local newP = lume.copy(p)
                    newP.splashed.count = (tile.puddlesLen or 0)>0 and 100 or 2
                    tile:addPuddle(newP)
                end
            end
        end
    end
    
    return done
end

function Tile:spreadWater()
    local w = self.water
    
    if w and w.spread and not w.spreaded then
    
        local v = w.value or type(w.spread) == "number" and w.spread or 1
        
        local p = w
        p.value = v
        
        if v >= .125 then
            local newValue = v/4
            for d = 1, 4 do
                local dir = dirs4[d]
                local tile = self.room:getTile(self._x+dir[1], self._y+dir[2])
                if tile and not tile.solid then
                    local pp = lume.copy(p)
                    pp.value = newValue
                    tile:addWater(pp)
                end
            end
            
            p.value = p.value - newValue
            w.spreaded = true
        end
        
        
    end
end

function Tile:removeFires()
    for id, gas in pairs(self.gases) do
        if gas[3].isFire then
            gas[3]:releaseTile(self)
        end
    end
end

function getPuddle(potion, force, value)
    if potion.data and potion.data.doGas or force then
        local puddle = {}
    
        puddle.data = potion
        puddle.color = (potion.data or potion).color or  (potion.data or potion).pcolor or potion.color
        puddle.noSpread = (potion.data or potion).noSpread or potion.noSpread
        
        puddle.uuid = lume.uuid()
        
        puddle.value = value or 1
        
        puddle.source = string.format("effects/stain/stain_%s.png", math.random(1,4))
        
        return puddle
    end
end
    
function puddleEvaporate(puddle)
   do
       local self = puddle.data or {}
       puddle.data = puddle.data or {}
            Gas:new({
                source = puddle.tile,
                buff = self.buff,
                buffIntensity = self.intensity,
                buffTime = self.buffTime,
                lifeBonus = -(self.gasAttack or 0),
                corrosive = self.corrosive or nil,
                color = self.pcolor or puddle.pcolor or puddle.color
            })
    end
end

function condenseGas(tile, gas)
    local parent = gas[3]
    
    local puddle = getPuddle(parent, true)
    
    tile:addPuddle(puddle)
    parent:releaseTile(tile)
    
end


function Tile:addPuddle(puddle)
    local data = self.puddlesTable[puddle.uuid]
    if data then
        puddle.value = data.value + puddle.value
        puddle.added = (data.added or 0)+1
    end
    
    self.puddles[self.puddlesLen+1] = puddle
    self.puddlesLen = self.puddlesLen + 1
    
    self.puddlesTable[puddle.uuid] = puddle
    
    self.room.checkPuddles[self] = true
    
    
    local col = lume.copy(getColor("white"))
    local v = 0
    for x = 1, self.puddlesLen do
        local p = self.puddles[x]
        v = v + p.value
        if p.color or p.data.color then
            col = multiply(col, getColor(p.color or p.data.color)) or addc(col, getColor(p.color or p.data.color), .5)
        end
    end
    
    self.puddleColor = {col[1],col[2],col[3],lume.min(v, 1/.75)*.75}
    
    if not puddle.flammability or puddle.flammability <= 0 then
        self:removeFires()
    end
    
    self:drawSplash(puddle.color)
end

function Tile:removePuddle(puddle, x)
    if x then
        table.remove(self.puddles, x)
    else
        lume.remove(self.puddles, puddle)
    end
    
    self.puddlesTable[puddle.uuid] = nil
    
    self.puddlesLen = self.puddlesLen - 1
    
    
    local col = lume.copy(getColor("white"))
    local v = 0
    for x = 1, self.puddlesLen do
        local p = self.puddles[x]
        v = v + p.value
        if p.color or p.data.color then
            col = multiply(col, getColor(p.color or p.data.color)) or addc(col, getColor(p.color or p.data.color), .5)
        end
    end
    
    self.puddleColor = v ~= 0 and {col[1],col[2],col[3],lume.min(v, 1/.75)*.75}
    
    if self.puddlesLen <= 0 and not self.water then
        self.room.checkPuddles[self] = nil
    end
end

function Tile:drawPuddles()
    if self.puddlesLen <= 0 or self.ice then
        return
    end
    
    self.puddleSource = self.puddleSource or string.format("effects/stain/stain_%s.png", math.random(1,4))
     
    local col = lume.copy(getColor(self.colorUsed or self.color or "white"))
    local v = 0
    if self.puddlesLen == 1 then
        local p = self.puddles[1]
        col = getColor(p.color)
        v = p.value
    else
      for x = 1, self.puddlesLen do
        local p = self.puddles[x]
        v = v + p.value
        if p.color or p.data.color then
            col = multiply(col, getColor(p.color or p.data.color)) or addc(col, getColor(p.color or p.data.color), .5)
        end
      end
    end
    
    self.puddleColor = {col[1],col[2],col[3],lume.min(v, 1/.75)*.75}
    set_color(self.puddleColor)
    
    local img = game:getAsset(self.puddleSource)--getValue(self.puddles).source)
    local iw, ih = img:getDimensions()
    local gw, gh = resizeImage(img, tw, th)
    lg.draw(img, self.x+tw/2, self.y-(th-th)+th/2, 0, gw, gh, iw/2, ih/2)
    
end

function Tile:drawSplash(color, alpha)
        
        local o = self
        
        local vv = 1.1*.5*(math.random(8,13))/10
        local tx = self.x+self.w/2
        local ty = self.y+self.h/2
        
        local obj = toybox.NewBaseObject({x=tx, y=ty, w = self.w*vv, h=self.w*vv})
        obj.solid = false
        obj.sprite = toybox.new_sprite(obj, {
            animations = {
                idle = {
                     source = "setpieces/splash",
                     delay = (nil and .03 or 0.05)/1.5,
                     mode = "once",
                     useImages = true,
                     onAnimOver = function()
                         obj:destroy()
                     end
                }
            }
        })
        obj.color = color
        obj.image_alpha = alpha or 1
        obj:center()--obj.offset_x=0 obj.offset_y=0
end

function Tile:checkPuddles()
    -- only actively evaporate if above normal temperature
    local temp = self:getTemperature()
    local evaporate = temp >= 12
    
    for x = 1, self.puddlesLen do
        local p = self.puddles[x]
        
        if p then
            p.value = p.value - .1*(evaporate and (temp/12)*.5 or 0)
            
            local evaporate = p.value <= 0-- or evaporate
            if evaporate then
                puddleEvaporate(p)
                self:addLog("A puddle evaporated")
                self:removePuddle(p, x)
            end
        end
            
    end
    
    self:spreadWater()
end

function Tile:addLog(...)
    if self:canBeSeen() then
        return self.room:addLog(...)
    end
end

function Tile:isAntiFire()
    local liquid = (self.water or self.puddles[1])
    hasFab = liquid and liquid.flammability
    
    if liquid and not hasFab then
        return true
    end
    
    return false
end

function Tile:isFlammable(noGrass)
    local tile = self
    local liquid = (self.water or self.puddle)
    hasFab = liquid and liquid.flammability
    
    if liquid and not hasFab then
        return false
    end
    
    do
        local burn = (
            --tile.unit and tile.unit:isFlammable() or
            tile.item and (tile.item.flammable or ((tile.item.flammability or 0)>0 and tile.item.flammability))
            or (not noGrass) and ((tile.grass and ((tile.grass.flammability or 0)>0 and tile.grass.flammability)))
            or self.explode and lume.distance(ogg._x,ogg._y,tile._x,tile._y)<=(self.range) and (log("expppp") or 1)
        )
        local ffl = type(burn) == "number" and burn or 0
        local fl = 0
        for x, i in pairs(tile.gases) do
            local f = i.flammability or i[3].flammability
            if f and f > 0 and x ~= self.uuid and i[1] > .01 then
                fl = lume.max(fl, f)
            end
        end
        fl = fl + ffl
    
        return fl>0 and fl or false
    end
end

function Tile:getFlammability(noGrass)
    return self:isFlammable(noGrass) or 0
end

function Tile:setType(name)
    if name == "stone" then
        self.solid = true
    elseif not self.edge and not self.keepSolid then
        self.solid = false
    end
end

function Tile:isLastWall()
    return self._x == self.room.minTileX or self._x == self.room.maxTileX or self._y == self.room.minTileY or self._y == self.room.maxTileY -- self.edge
end

function Tile:solidify()
    self.solid = true
end

local morph = {
    rat = 150,
    goblin = 50,
    skeleton = 30,
    angel = 1
}

-- Trap:new(gas, fire, vents = int, ventDistance = {min,max}, onStep = null)
traps = {
    polymorphTrap = {
        name = "polymorphing trap",
        color = "lightgreen",
        
        onStep = function(tile)
            if tile.unit then
                tile.unit:polymorph(getValue(morph),5)
            end
        end
    },
    
    poisonGasTrap = {
        name = "poisonous gas",
        vents = {0,0,1,1,2},
        ventDistance = {2,6},
        color = "purple",
        
        gas = {
            intensity = 7,
            flammability = 2,
            color = gasColors.poison,
            range = 3,
            lifeBonus = -3
        },
    },
    
    
    paralysisGasTrap = {
        name = "paralysis gas",
        vents = {0,1,2,2,3},
        ventDistance = {2,6},
        
        gas = {
            intensity = 7,
            flammability = 2,
            color = gasColors.peach,
            range = 3,
            lifeBonus = 0
        },
    },
    
    confusionGasTrap = {
        name = "confusion gas",
        vents = {0,0,1,1,2},
        ventDistance = {2,6},
        color = "yellow",
        
        gas = {
            intensity = 7,
            flammability = 2,
            color = gasColors.yellow,
            range = 3,
            lifeBonus = 0
        },
    },
    
    fireTrap = {
        name = "fire trap",
        vents = {0,0,0,2,2},
        ventDistance = {2,6},
        color = "red",

        
        fire = {
            range = 2,
            inteneity = 4,
            forceSpread = true
        }
    },
    
    
    explosiveTrap = {
        name = "explosive gas",
        vents = {0,0,2,2},
        ventDistance = {2,6},
        color = "orange",
 
        
        fire = {
            range = 2,
            inteneity = 4,
            explode = true,
            forceSpread = true
        }
    }
}

Tile.get_volume = Creature.get_volume

Trap = class:extend("Trap")

function Trap:__init__(k, simple)
    self.gas = k.gas
    self.fire = k.fire
    self.name = k.name
    
    self.silent = k.silent
    
    self.color = k.color or nil
    
    self.ventsNumber = simple and 0 or getValue(k.vents or 0)
    self.ventDistance = k.ventDistance or {5,10}
    
    self.onStep = k.onStep or k.onSteppedOn or null
    self.onRelease = k.onRelease or k.onReleased or k.onOff or null
    
    self.pressurePlate = {parent=self, color=self.color or nil}
    self.vents = {}
end

function Trap:deactivate()
    self.activated = false
    self.onRelease(self.pressurePlate.tile)
    local player = (self.pressurePlate.tile.unit or self.pressurePlate.tile)
    player:play_sound("switch")
end

function Trap:activate()
    local vents = #self.vents
    
    self.onStep(self.pressurePlate.tile)
    local player = (self.pressurePlate.tile.unit or self.pressurePlate.tile)
    player:play_sound("door_slam")
    
    self.activated = true
    
    if vents > 0 then
        self.pressurePlate.tile:addLog(
            self.gas and string.format("%s creeps out from underneath %s vent%s!",
                self.gas.name or self.name or "gas", vents > 1 and "some" or "a", vents > 1 and "s" or ""
            ) or
            self.fire and string.format("%s roar out from underneath %s vent%s!",
                self.fire.name or self.name or "flames", vents > 1 and "some" or "a", vents > 1 and "s" or ""
            )
        )
    elseif not self.silent then
        self.pressurePlate.tile:addLog(
            self.gas and string.format("%s seeps out from the pressure plates!",
                self.gas.name or "gas"
            ) or
            self.fire and string.format("%s roar out from underneath the pressure plate!",
                self.fire.name or "flames"
            ) or
            "A pressure plate clicked"
        )
    end
    
    for x = 1, lume.max(#self.vents, 1) do
        local v = self.vents[x] or self.pressurePlate
        
        if self.gas then
            self.gas.source = v.tile
            Gas:new(self.gas)
        end
        
        if self.fire then
            self.fire.source = v.tile
            Fire:new(self.fire)
        end
    end

end

function Trap:setup(room, pos)
    room = room or toybox.room
    self.room = room
    
    local pos = pos and pos.isTile and pos or (pos or room):getRandomSpaceTile()
    
    self.tile = pos
    
    self.pressurePlate.x = pos.x
    self.pressurePlate.y = pos.y
    self.pressurePlate.tile = pos
    
    pos.pressurePlate = self.pressurePlate
    
    local min = self.ventDistance[1]
    local max = self.ventDistance[2]
    local ventsToMake = self.ventsNumber

    while ventsToMake > 0 do
        local tile = pos
        local count = 0
        local notPlaced = true
        
        if self.ventsNumber == 0 then error() end
        
        while (notPlaced) do
        
            if count > 30 then
                tile = self.room:getRandomSpaceTile()
            else
                tile = pos.roomData:getRandomSpaceTile()
            end
            
            count = count + 1
            
            notPlaced = false
            for x = 1, #self.vents + 1 do
                local vent = self.vents[x] or pos
                local dis = lume.distance(vent._x, vent._y, tile._x, tile._y)
                
                if (dis > max or dis < min) then
                    notPlaced = true
                    break
                end
            end
                
            if count > 100 then
                error("Vents are shizzy")
            end
        end
        
        ventsToMake = ventsToMake - 1
        self:addVent(tile)
    end
    
    
end

function Tile:isSolid()
    if self:isChasm() then return false end
    
    return self.solid or self.item and self.item.isWall
end

function Tile:isFreeSpace()
    return not self:isSolid() and
    not self.pressurePlate and
    not self.chasm and
    not self.lava and
    (not self.water or not self.water.isDeep)
end

function Tile:unlock()
    if not self.isLocked then
        return
    end
    
    self.isLocked = false
    self.solid = false
end

function Tile:makeDoor(locked)
    self.hasDoor = true
    self.isEntrance = true
   -- self.doored = true
   -- self.source = "tile.png"
   
    if self.hasWall then
        self.room:destroyItem(self.hasWall)
    end
    
    local t = self.room:getTile(self._x, self._y-1)
    if nil and t then
        t.doored = self
        t.source = "tile.png"
    end
    
    if locked then
        self.isLocked = true
        -- no! (for proper drawing) self.solid = true
    end
    
    local dung = self
    local doneIt = 0
                for ii = 1, 2 do
                    for x = 1,8 do
                        local d = dirs8[x]
                        local tt = self.room:getTile(dung._x+d[1], dung._y+d[2])
                        if tt and (not tt:isSolid()) then
                            tt.isEntrance = true
                            tt.isCorridor = true
                            doneIt = doneIt+1
                            -- tt.draw=function(self) draw_rect("fill",self.x,self.y,self.w, self.h) end
                        end
                    end
                end
                
                --if doneIt < 4 then error(doneIt.." cleared is not enough space made for doors") end
end

function Trap:addVent(tile)
    local v = {
        _x = tile._x, _y = tile._y,
        tile = tile
    }
    
    -- doesn't really matter if a tile has more than 1 vent from different traps
    tile.vent = v
    self.vents[#self.vents+1] = v
    
    return v
end

function Trap.loadTrap(data, pos, simple)
    local trap = Trap:new(data, simple)
    trap:setup(toybox.room, pos)
    
    return trap
end

BACKGROUND = 0
GOOI = 4
FOREGROUND = 10


local n = "nearest"
love.graphics.setDefaultFilter(n,n)

tw, th = 125
th = tw

Room = class:extend("Room")
function Room:__init__(k)
    toybox.make_grid(self)
    
    self.kwargs = k
    
    self.getRandomSpaceTile = getSpaceTile
    
    
    self.parent = k.parent or toybox.room
    self.data = k.data
    
    self.onEnter = k.onEnter or null
    self.onLeave = k.onLeave or null
    
    self.room = self.parent
    
    self.walls = {}
    self.tiles = {}
    self.spaces = {}
    
    self.digOffsetx = 0
    self.digOffsety = 0
    
    local room = self.data
    
    if k.simple then return end
    
    --if #room.walls>0 then return {floors = room.spaces, walls = room.walls} end
    
    --check Bottom should actually be top(in kivy coords) else switch
    local spaces = {}
    local walls =  {}
    local color = getValue(colors)
    local function dd(self)
        local r,g,b,a = set_color(color)
        draw_rect("line",self.x,self.y,self.w,self.h)
        set_color(r,g,b,a)
    end
    
    local useMap = k.useMap
    local useMapFunction = k.useMapFunction


    if not k.noLoadTiles then
    local done
    
    local top = room:getTop()+self.digOffsety
    local bottom = room:getBottom()+self.digOffsety
    local left = room:getLeft()+self.digOffsetx
    local right = room:getRight()+self.digOffsetx
    for t = top-1,bottom+1 do
        for r = left-1,right+1 do
            local dung = useMap and (useMap[r] and useMap[r][t]) or (not useMap and self.parent:getTile(r,t))
            if useMapFunction then
                dung = useMapFunction(r, t, dung)-- or dung
            end
            
            if dung then
                --dung.__draw = dd
                
                dung.roomData = self
                dung.realRoom = k.real and self
                if dung.solid then-- == "wall" then
                    table.insert(self.walls,{x=r,y=t,[1]=r,[2]=t})
                else
                    table.insert(self.spaces,{x=r,y=t,[1]=r,[2]=t})
                    for x = 1,8 do
                        local d = dirs8[x]
                        local tt = self.parent:getTile(dung._x+d[1], dung._y+d[2])
                        if tt and (tt.isCorridor or tt.hasDoor) then
                            dung.isEntrance = true
                            break
                        end
                    end
                end
                
                done = true
            
            
                self:storeTile(dung)
            end
        end
    end
    if not done then error(inspect(room,2)..room:getTop()..","..self.digOffsetx..","..self.digOffsety) end
    assert(done, "No tiles!")
    
    self.doors = {}
    local function addDoor(x,y)
        local tile = self.parent:getTile((k.dx or 0)+x,(k.dy or 0)+y)
        self.doors[#self.doors+1] = tile
        self.parent.doors[#self.parent.doors+1] = tile
    end
    
    self.data:getDoors(addDoor)
    
    self._x = self.minTileX
    self._y = self.minTileY
    self.w  = right-left+2
    self.h  = bottom-top+2
    
    end
    
    self.roomTypes = {}
    
end


function Room:loadTile(t, k)
    k = k or self.kwargs
    t.realRoom = k.real or self
    if t.solid then
        table.insert(self.walls, {x=t._x, y=t._y, [1]=t._x, [2]=t._y})
    else
        table.insert(self.spaces, {x=t._x, y=t._y, [1]=t._x, [2]=t._y})
        for x = 1,8 do
            local d = dirs8[x]
            local tt = self.parent:getTile(t._x+d[1], t._y+d[2])
            if tt and (tt.isCorridor or tt.hasDoor) then
                t.isEntrance = true
                break
            end
        end
    end
    
    self:storeTile(t)
    
    self._x = self.minTileX
    self._y = self.minTileY
    
    self.w = self.maxTileX - self.minTileX
    self.h = self.maxTileY - self.minTileY
end

                

--data.grasses = {}
grasses = {}
grasses.grass = {
    source = "grass/grass.png",
    variant = "tallGrass",
    name = "some grass",
    variantChance = 50,
    flammability = 1
}

grasses.tallGrass = {
    source = {"grass/tallgrass.png","grass/tallgrass2.png"},
    flammability = 1,
    name = "some tall grass",
    h = th*2
}

local roomy, ggrass
local function grassy(x,y,v)
    ggras = 
        (ggrass.variant and math.random(100)<=(ggrass.variantChance or 10) and 
        grasses[ggrass.variant] )
        or ggrass
    
    ggras.w, ggras.h = ggras.w or tw, ggras.h or th
    
    if v == 1 then
        local t = roomy.isTile and roomy or roomy:getTile(roomy.minTileX-1+x, roomy.minTileY-1+y)
        if t and not t.solid then
            t.grass = lume.copy(ggras)
            t.grass.source = getValue(ggras.source) --elseif t then t.solid = false
         elseif t then t.solid=true end
    end
end

function Map:makeGrass(tile, grass)
    roomy, ggrass = tile, grass and grasses[grass] or grass or grasses.grass
    grass = ggrass
    grass.w, grass.h = grass.w or tw, grass.h or th
    
    grassy(nil,nil,1)
end

function Map:grassify(room, grass)
    roomy, ggrass = room, grass
    grass.w, grass.h = grass.w or tw, grass.h or th
    
    local r = toybox.rot().Map.Cellular(self.digW, self.digH/(z==3 and 2 or 1), {
        --caveChance = z==3 and 1 or 0
    })
    
    r:randomize(.6)
    
    r:create(grassy)
    
    roomy, ggrass = nil
end


    local draws = function(self)
        local s = self
        local r,g,b,a = set_color(getColor(self.color or "white",self.alpha))
        lg.circle("line",s.x+s.b.shake_x,s.y+s.b.shake_y,s.size1)
        
        if not s.onlySize1 and not s.b.onlyLine then
            -- so alpha of 1 plus .5 equals .5
            set_color(getColor(self.color or "white",(self.alpha+.5)/3))
            lg.circle("fill",s.x+s.b.shake_x,s.y+s.b.shake_y,s.size)
            lg.circle("fill",s.x+s.b.shake_x,s.y+s.b.shake_y,s.size2)
        end
        
        set_color(r,g,b,a)
    end
    
function Map:shout(tile,max,color,stall)
    
    local s = {x=x,y=y,draw=draws,color=color or "red"}
    s.max = max or tw
    max = s.max
    s.size1 = 0
    s.size = 0
    s.size2 = 0
    
    --s.onlySize1 = onlyLine
    
    s.x = tile.x+tw/2
    s.y = tile.y+th/2
    
    s.alpha = 0
    
    local time = 1*(max/(tw*10))*(type(stall)=="number" and stall or stall and 2 or 1)
    
    local out2 = function()
        self.sounds[s] = nil
        s.b:destroy()
    end
   
    
    local oq = "out-quad" -- out-quad
    
    local function out()
        -- self:after(.1,out2)
        self:tween(.5,s,{alpha=0},oq,out2)
    end
    
    local function out3()
        self:tween(time,s,{size2=s.max},oq,oIut)
        self:after(time*.5, out)
    end
    
    local function out1()
        self:tween(time*.7,s,{size=s.max},oq)
        self:after(time*.25, out3)
    end
    
    local function start()
        self:tween(time*.5,s,{size1=s.max},oq)
        self:after(time*.25, out1)
    end
    
    
    local b = toybox.NewBaseObject({x=s.x,y=s.y,solid=false})
    self:must_update(b)
    b.__draw = function()
        s:draw()
    end
    
    self:must_draw(b)
    s.b = b
    b:shake(35,time,300)
    
    self:tween(.02,s,{alpha=1},"in-quad",start)
    
    self.sounds = self.sounds or {}
    self.sounds[s] = true
    
    return b
end

function shout(color)
    toybox.room:shout(pl.tile, tw*5, color or "red")
end

local function tileHash(tile)
    return string.format("%s%s%s%s%s%s%s",
        tile.water,
        tile.chasm,
        tile.colorUsed,
        tile.unit,
        tile.lightp,
        tile.seen,
        tile.solid
    )
end

function Map:updateCanvasTile(tile)
    if not self.canvasTiles then
        return
    end
    
    local tid = tostring(tile)
    local currentTileData = self.canvasTiles[tid]
    local tHash = tileHash(tile)
    
    if currentTileData and currentTileData.hash == tHash then
        return
    end
    
    self.canvasTiles[tid] = {
        hash = tHash,
        _x = tile._x, _y = tile._y,
        water = tile.water,
        chasm = tile.chasm,
        colorUsed = tile.colorUsed,
        unit = tile.unit,
        item = tile.item,
        solid = tile.solid,
        myLights = tile.myLights,
        seen = tile.seen,
        canBeSeen = function() return tile:canBeSeen() end,
        lightp = tile.lightp,
        drawID = tile.drawID
    }
    self.updateCanvas = true
end

local lowColor = {.2, .2, .2}
function Map:reloadCanvas(dt)
    if self.drawMap == 0 then
        return
    end
    
    self.canvas = self.canvas or lg.newCanvas(W(), H())
    
    self.canvasTiles = self.canvasTiles or {}--self.allTiles or {}
    
    local tilesH = math.floor(H()/(self.maxTileY+1))
    local tilesW = tilesH or math.floor(W()/(self.maxTileX+1))
    
    local n1, n2 = lg.getDefaultFilter()
    lg.setDefaultFilter("nearest", "nearest")
    
    local alpha = self.drawMap == 1 and .62 or .65
    
    lg.setCanvas(self.canvas)
    local r,g,b,a = set_color(0, 0, 0, alpha)
    
    -- draw_rect("fill", 0, 0, W(), H())
    
    local count = 0
    
    -- lg.clear() -- edit
    
    for i, tile in pairs(self.canvasTiles) do
    
        count = count + 1
        set_color(getColor(
            tile.water and "lightblue" or
            tile.chasm and "grey" or
            tile.solid and "white" or
            #tile.myLights > 1 and tile.colorUsed or
            "black"
        , alpha))
        
        if tile.seen then
            draw_rect(((tile.solid) and "line") or "fill", tile._x*tilesW, tile._y*tilesH, tilesW, tilesH)
            
            local nn = 1
            
            if tile.unit then
                local u = tile.unit
                local good = self.player and u.team == self.player.team
                local bad = self.player and u:isEnemy(self.player)
                local color =  good and "lime" or bad and "red" or "white"
        
                local i = tile.item
                local rr, gg, bb, aa = set_color(getColor(
                    tile.unit.isPlayer and "orange" or color, tile.unit.isPlayer and 1 or alpha
                ))
                
                local n = tile.unit.isPlayer and 2 or 2.5
                lg.circle(("fill") or "fill", tile._x*tilesW+(tilesW/(n*nn))+(tilesW/2-(tilesW/(n*nn))), tile._y*tilesH+(tilesW/(n*nn))+(tilesH/2-(tilesW/(n*nn))), tilesW/n)
            end
            
            if tile.item then
                local i = tile.item
                local rr, gg, bb, aa = set_color(getColor(
                    i and "cyan"
                ), alpha)
                
                local n = 4
                lg.circle(("line") or "fill", tile._x*tilesW+tilesW/2-(tilesW/(n*nn)), tile._y*tilesH+tilesH/2-(tilesW/(n*nn)), tilesW/n)
            end
            
        end
    end
    
    -- INFORM_PLAYER(count)
    
    set_color(1,1,1,alpha)
    -- lg.circle("line", 0+W()/4, 0+W()/4, W()/4)
    -- draw_rect("line", 0, 0, W()-5, H()-5, 5, 5)
    
    set_color(r,g,b,a)
    lg.setDefaultFilter(n1, n2)
    lg.setCanvas()
end

function Map:drawCanvas(dt)
    local cd = self.canvasMapData self.doDrawMap = true self.drawMap = 1
    
    if self.canvas and (self.doDrawMap or 1) then
        local alpha = 1
        self.canvas:setFilter("linear", "linear")
        local alpha2 = self.drawMap == 1 and .62 or .65
        local radius = 10
        
        local w, h, x, y = cd.w, cd.h, cd.x, cd.y
        
        local r,g,b,a = set_color(0,0,0,alpha2)
        
        draw_rect("fill", x, y, w, h, radius, radius)
        
        set_color(1,1,1,alpha)
        local n1, n2 = lg.getDefaultFilter()
        lg.setDefaultFilter("nearest", "nearest")
        
        lg.draw(self.canvas, x, y, 0, w/W(), h/H())
        draw_rect("line", x, y, w, h, radius, radius)
        
        
        lg.setDefaultFilter(n1, n2)
        set_color(r,g,b,a)
    end
end

local lowColor = {.2, .7, .2}
function Map:reloadLightCanvas(dt)
    if self.drawMap == 0 then
        -- return
    end
    
    self.lightCanvas = self.lightCanvas or lg.newCanvas(W(), H())
    
    self.canvasTiles = self.canvasTiles or {}--self.allTiles or {}
    
    local tilesH = 1 or math.floor(H()/(self.maxTileY+1))
    local tilesW = tilesH or math.floor(W()/(self.maxTileX+1))
    
    local n1, n2 = lg.getDefaultFilter()
    lg.setDefaultFilter("nearest", "nearest")
    
    local alpha = self.drawMap == 1 and .62 or .65
    
    lg.setCanvas(self.lightCanvas)
    local r,g,b,a = set_color(0, 0, 0, alpha)
    
    
    local count = 0
    
    lg.clear() -- edit
    --draw_rect("fill", 0, 0, W(), H())
    
    for i, tile in pairs(self.canvasTiles) do
    
        set_color(tile.colorUsed)
        local n = (tile.drawID == self.drawID and getColor(tile.colorUsed or tile.lightp and {tile.lightp, tile.lightp,tile.lightp}) or getColor(tile.colorUsed or tile.seen and lowColor or "black"))
        -- tile:__ reloadc canvast
        draw_rect(((tile.solid) and "fill") or "fill", tile._x*tilesW, tile._y*tilesH, tilesW, tilesH, tilesW*.45, tilesH*.45)
        
    end
    
    
    -- INFORM_PLAYER(count)
    
    set_color(1,1,1,alpha)
    -- lg.circle("line", 0+W()/4, 0+W()/4, W()/4)
    -- draw_rect("line", 0, 0, W()-5, H()-5, 5, 5)
    
    set_color(r,g,b,a)
    lg.setDefaultFilter(n1, n2)
    lg.setCanvas()
end

function Map:drawLightCanvas(dt) self.camera:attach()
    local cd = self.canvasMapData -- self.doDrawMap = true self.drawMap = 1
    
    if self.lightCanvas then--and (self.doDrawMap or 1) then
        local alpha = 1
        self.lightCanvas:setFilter("linear", "linear")
        local alpha2 = self.drawMap == 1 and .62 or .65
        local radius = 10
        
        local w, h, x, y = cd.w, cd.h, cd.x, cd.y
        
        local r,g,b,a = set_color(0,0,0,alpha2)
        
        -- draw_rect("fill", x, y, w, h, radius, radius)
        
        set_color(1,1,1,alpha)
        local n1, n2 = lg.getDefaultFilter()
        lg.setDefaultFilter("linear", "linear")
        
        -- lg.draw(self.lightCanvas, x, y, 0, w/W(), h/H())
        -- draw_rect("line", x, y, w, h, radius, radius)
        
        local tilew = math.floor(H()/(self.maxTileY+1))
        local ba, ga = lg.getBlendMode()
        lg.setBlendMode("multiply","premultiplied")
        local w = H()*tw--(self.maxTileY+1)*tw-- tilew*(tw/tilew)
        local _w, _h = resizeImage(self.canvas, W()*tw, w)
        lg.draw(self.lightCanvas, -tw, -th, 0,_w, _h)
        lg.setBlendMode(ba, ga)
        
        lg.setDefaultFilter(n1, n2)
        set_color(r,g,b,a)
    else
        local r,g,b,a = set_color(1,1,0)
        lg.rectangle("fill", pl.x,pl.y,10,10)
        set_color(r,g,b,a)
    end self.camera:detach()
end

function doMapThing(map)
    local r = map--pl and pl.room or toybox.room
    r.canvasTiles = {}
    
    r.timer:after(.1, function()
        r:reloadCanvas()
        r:reloadLightCanvas()
    end)
    r.timer:every(.25, function()
        if r.updateCanvas then
            r.updateCanvas = nil
            -- r:reloadCanvas()
            r:reloadLightCanvas()
        end
    end)
end


function Map:shatterTile(tile, time)
    time = time or .4
    
    local function br()
        local func = function()
            tile:getAttacked(tile.life, self)
        end
                
        tile.room.timer:tween(.3, tile, {life=0}, "out-quad", func)
    end
    
    tile:shake(10,time+.4,15)
    tile.room:after(time, br)
end

function Map:fixCorridors()
    for x, i in ipairs(self.digger._corridors) do--:getRooms()) do
        --for xx, cor in ipairs(i.corridors) do
    self.map = self
    local sx, sy, length, dx, dy = i._sx, i._sy, i._length, i._dx, i._dy
    local digCallback = function(x,y,nn,ii) 
       local t = self.map:getTile(x,y) --t.debug=1
       if t then 
       --t.crazy = 4 
       t.isCorridor = ii 
       --if t._cdug then return end
       end
       self.digC(x,y,nn,ii)
       --local r = self.digger:saveTunnel(x,y,nn,ii)
       --if ii then assert(t.isCorridor) end
    end
    
    local fillUp = math.random(1,100)>35
    local fillDown = math.random(1,100)>(not fillUp and 20 or 70)
    if math.random(1,100)>50 then
        local filUp = fillUp
        fillUp = fillDown
        fillDown = filUp
    end
    
    local stair, dos, _nildos, nildos = math.random(2,3), true, math.random()>.5
    
    for i=0,length-1 do
        local x=sx+i*dx
        local y=sy+i*dy
    
        local lx = 1--lume.max(3,length) 
        
        if dy~=0 then
            --Make roof and floor corridors
            if fillUp or truek then
            digCallback(x-1,y,0,1)
            end
            if fillDown or truek then
            digCallback(x+1,y,0,1)
            end
            
            
            --make corridors extend into rooms
            for ll = 0, mm0 or lx do
                digCallback(x,y+ll,nil,1)
                digCallback(x,y-ll,nil,1)
            if fillUp or truek then
            digCallback(x-1,y+ll,0,1)
            end
            if fillDown or truek then
            digCallback(x+1,y-ll,0,1)
            end
            if fillUp or truek then
            digCallback(x-1,y-ll,0,1)
            end
            if fillDown or truek then
            digCallback(x+1,y+ll,0,1)
            end
            end
            
            if fillUp and fillDown then
                if dos and stair == 3 then
                    local t = self.map:getTile(x+3,y+2)
                    if t then
                        --t:solidify(nil,true)
                        t._cdug = true
                    end
                    stair = 2
                    dos = false
                elseif dos and stair == 2 then
                    local t = self.map:getTile(x-1+2,y+2)
                    if t then
                        --t:solidify(nil,true)
                        t._cdug = true
                    end
                    stair = 3
                    dos = false
                elseif dos==false then
                    dos = nil
                    nildos = _nildos
             --   elseif nildos then
                    nildos = nil
                else
                    dos = true
                end
            elseif fillUp or fillDown then

                if dos and stair == 3 then
                    local t = self.map:getTile(x+2,y+2)
                    if t then
                       -- t:solidify(nil,true)
                        t._cdug = true
                    end
                    stair = 2
                    dos = false
                elseif dos and stair == 2 then
                    local t = self.map:getTile(x+(fillUp and -1 or 1)+2,y+2)
                    if t then
                        --t:solidify(nil,true)
                        t._cdug = true
                    end
                    stair = 3
                    dos = false
                elseif dos==false then
                    dos = nil
                    nildos = _nildos
                --elseif nildos then
                    nildos = nil
                else
                    dos = true
                end
            end
        end
        if dx~=0 then
            if fillUp then
            digCallback(x,y-1,0,1)
            end
            if fillDown then
            digCallback(x,y+1,0,1)
            end
            
            for ll = 1, lx do
                digCallback(x-ll,y,nil,1)
                digCallback(x+ll,y,nil,1)
            if fillUp then
            digCallback(x-ll,y-1,0,1)
            end
            if fillDown then
            digCallback(x-ll,y+1,0,1)
            end
            if fillUp then
            digCallback(x+ll,y-1,0,1)
            end
            if fillDown then
            digCallback(x+ll,y+1,0,1)
            end
            end
        end
        
        if nil then--i == length-1 or i == 0 then
            if dy ~= 0 then
                local diff = 1
                if up then
                    diff = -1
                end
                
                digCallback(x+diff, y,0,1)
            else
                local diff = 1
                if up then
                    diff = -1
                end
                
                digCallback(x,y+diff,0,1)
            end
        end
    end
    end
end



local function getOld(name)
    local oldMap = oldMap or toybox.room
    return oldMap and oldMap[name]-- or oldMap and (log("??"..tostring(name)..","..inspect(oldMap,1)) or 1) and nil
end

function Map.depth_sorter(a, b)
  -- checkDrawDepth should return other object to draw first, if nil returned then use normla calculation
  
  if a.isExplosion then
    return false
  end
  
  if b.isExplosion then
    return true
  end
  
  if a.isBone then
    if b.isBone then return b.time_alive > a.time_alive end
    return false
  end

  if b.isBone then
    return true
  end
  
  if a.isC_reature then
    if b.isCreature then
      return b.time_alive > a.time_alive
    end
    
    if b.previousFloor then
      return b.y > (a.tile and a.tile.y or a.y)
    end
    
    return false -- draw b before a
  elseif a.nextFloor or a.previousFloor then
  end
  
  
  if b.previousFloor and not a.isTile then
      return b.y > (a.tile and a.tile.y or a.y or 0)
  end
  
  if a.previousFloor and not b.isTile then
      return a.y < (b.tile and b.tile.y or b.y or 0)
  end
  solids = solids or {}
  

  
  
    
  if a.checkDrawDepth then
    -- return a:checkDrawDepth(b) == a
  end
  
  if b.checkDrawDepth then
   -- return b:checkDrawDepth(a) == a
  end
  
  
  
  local ay = a.tile and a.tile.y or a.y or 0
  local by = b.tile and b.tile.y or b.y or 0
  
  if not a.depth then error(inspect(a,1)) end
  if not b.depth then error(inspect(b,1)) end
  
  if a.previousFloor then a.depth = -.1 end--4 return by<ay end
  if b.previousFloor then b.depth = -.1 end--return by<ay end
  
  if b.depthFunction then b.depth = b:depthFunction() end
  if a.depthFunction then a.depth = a:depthFunction()
  -- log("ddeptha "..a.depth)
  end
  local bd, ad = b.depth, a.depth
  
  if a.isTile and (b.isBlood or b.isBone) or b.isTile and (a.isBlood or a.isBone) then
      -- log("DEPTH  "..a.depth..","..tostring(a.isTile and "a tile" or "")..b.depth)
      -- return bd > ad
  end
  
  if (a.previousFloor or a.isItem or a.isCreature) and (b.previousFloor or b.isItem or b.isCreature) then
    if by == ay then
      if bd == ad then
        b.time_alive = b.time_alive or 1
        a.time_alive = a.time_alive or 0
        return b.time_alive > a.time_alive
      end
      return bd > ad
    end
    
    return by > ay
  end
  
  
  --[[local ay, by = a.tile and not a.noUseTileDepth and a.tile.y or (a.isTile and a.y) or nil0, b.tile and b.noUseTileDepth and b.tile.y or (b.isTile and b.y) or nil0
  
  if not ay or not by then
      ay = 0
      by = 0
  else
      ay = ay/tw
      by = by/tw
  end]]
  
  local atile = a.tile or a
  local btile = b.tile or b
  
  local av = 0 -- (a.pllreviousFloor and ay>by and tw+1 or 0)
  local bv = 0 -- (b.pllreviousFloor and by>ay and tw+1 or 0)
  
  bd = bd + by/tw + bv--(by and ay and by/tw or 0)
  ad = ad + ay/tw + av--(by and ay and ay/tw or 0)
  
  if bd == ad then
      b.time_alive = b.time_alive or 1
      a.time_alive = a.time_alive or 0
      return b.time_alive > a.time_alive
  end
  

  return bd > ad--.depth
end

local dirsWalls ={{1,0},{0,1},{1,1},{-1,1}}
function Map:fixDoors()
    for i = 1, #self.doors do
        local t = self.doors[i]
        if t then
            for x = 1, 8 do
                local t2 = self:getTile(t._x+dirs8[x][1], t._y+dirs8[x][2])
                if t2 and t2.door then
                    t2.hasDoor = false  -- makeDoor
                    lume.remove(self.doors, t2)
                end
            end
            
            local count = 0
            for n = 1, 4 do
                local d = dirsWalls[n]
                for xx = 1, 2 do
                    local v = (xx==2 and -1 or xx)
                    local wall = self:getTile(t._x+d[1]*v, t._y+d[2]*v)
                    if wall and (wall.solid) then
                        count = count+1
                    end
                end
                
                if count > 2 then
                    break
                end
            end
            
            if count ~= 2 or not t.hasDoor then
                t.hasDoor = false
                lume.remove(self.doors, t)
            end
        end
    end
end
        

function Map:setup(k)
    self.camera._flash = self.camera.flash
    
    if not oldMap then gooi.components = {} end
    
    k = k or {}
    
    currentWaterSource = "wat/0.png"
    currentLavaSource = "lava/0.png"
    
    local c = 0
    local c2 = 0
    self.timer:every(.3, function()
        c = c + 1
        c2 = c2 + 1
        
        if c2 > 7 then c2 = 0 end
        if c > 3 then c = 0 end
        
        currentWaterSource = string.format("wat/%s.png",c)
        currentLavaSource = string.format("lava/%s.png",c2)
        
    end)
    
    self.isFirst = game.isFirst
    
    toybox.make_grid(self)
    self.getRandomSpaceTile = getSpaceTile
    
    self.rooms = {}
    self.doors = {}

    local m = req "map.mutation"
    mmm=m({})
    self.mutator = mmm
    
    self.effectObjects = {}
    
    self.binaryGrid = {}
    self.toMoveToNext = {}
    
    if not k.mapData then
    
    self.digW, self.digH = 38, 25 -- 45-7,25,40,20--k.digW or 60 or 15,k.digH or 35 or 20,60,35 --,50,40,70, 50,50,30--250,30--scale =
    
    local levelDat = k.level and dungeon[k.level] or k.level and error(string.format("%s not a real level!",k.level)) or {}
    self.levelDat = levelDat
    
    if levelDat.digWScale then
        self.digW = math.floor(self.digW*getValue(levelDat.digWScale))
    end
    if levelDat.digW then
        self.digW = getValue(levelDat.digW)
    end
    if levelDat.digHScale then
        self.digH = math.floor(self.digH*getValue(levelDat.digHScale))
    end
    if levelDat.digH then
        self.digH = getValue(levelDat.digH)
    end
    
    
    nn = 0
    local gridTmp = {}
    local function rmake(x,y,v,isCorridor)
        --gridTmp[x] = gridTmp[x] or {}
        
        gridTmp[#gridTmp+1] = {x,y,v,isCorridor}
    end
    
    local function make(x,y,v,isCorridor,e,xx,yy)
        if  xx > self.maxSpaceX+5 or x < self.minSpaceX-5 or
            yy > self.maxSpaceY+5 or y < self.minSpaceY-5 then
            
            return
        end
        
        local nn = 0
        
        local t = self:getTile(x,y) or Tile:new({
            _x = x,
            _y = y,
            x = (x-1)*tw-nn,
            y = (y-1)*th,
            solid = v == 1
        })
        t.space = v ~= 1
        t.isCorridor = isCorridor
        t.isEntrance = isCorridor
        t.isEntrance = v == 2
        
        
        if v ~=0 and v~=1 then error() end
        t.edge = t._x == 1 or t._y == 1 or t._x == self.digW or t._y == self.digH
        
       -- tv==1
        if t.solid and t.space and (self.caving and not t.realRoom or not self.caving) 
        and not t.isCorridor then
            t.solid = v==1--false
        end
        if v==0 and not t.keepSolid then
            t.solid = false
        end
        
        if t.edge then
            t.solid = true
        end
        
        self:storeTile(t)
        t.roomData = self
    end
    self.digC = make
    
    self.wallSource = levelDat.wallSource or levelDat.icy and {"tiles/walls/icebrick.png", "tiles/walls/icebrick2.png"} or {"tiles/walls/brick2.png","tiles/walls/brick2.png","tiles/walls/brick3.png"}
    self.floorSource = levelDat.floorSource or nil
    
    self.wallShader = levelDat.wallShader or nil
    self.floorShader = levelDat.floorShader or nil
    
    local maps = {"Brogue", "Uniform","IceyMaze","Brogue"}
    local okay
    local r
    
    log("[MAP] Digging")
    
    INFORM_PLAYER("establishing reality...")
    
    for xx = 1, PIG and 3 or 1 do
        local countm = 0
        okay = nil
    
        while not okay do--for z = 1,1 do
            countm = countm + 1
            local function nm()
                self.minSpaceX, self.minSpaceY, self.maxSpaceX, self.maxSpaceY = nil
                -- fps
                local allTiles = {}
                local function rmake(x,y,v,c,e)
            
                    if v ~= 1 then
                        self.minSpaceX = lume.min(self.minSpaceX or math.huge, x)
                        self.maxSpaceX = lume.max(self.maxSpaceX or -10, x)
            
                        self.minSpaceY = lume.min(self.minSpaceY or math.huge, y)
                        self.maxSpaceY = lume.max(self.maxSpaceY or -10, y)
                    end
                    allTiles[#allTiles+1] = {x,y,v,c,e}
                end
                
                local z = 1
                
                if z == 2 then self.caving = true end
                
                local r = PIG and toybox.rot().Map[xx>1 and "Uniform" or "Brogue"](self.digW, self.digH/(z==3 and 1 or 1), {
                    caveChance =xx==1 and 1 or 0, z==2 and 1 or 0,
                    chavePasses = math.floor(3*self.digW/20),
                    maxRooms = 10,--,12, 
                    minRooms=5,--8,
                    maxCorridorsPerRoom = 2,
                    roomWidth = {3,4,5,7},--{3,4 or 6},
                    roomWi4dth = {6,8},
                    roomtHeight = {6,10},
                    croussWidth = {0,0},
                    crossHieight = {0,0},
                    -- maxRooms = 11
     
                    corridorWidth = {1,1,1,2,2,2,4,5},--,10},
                    corridorHeight = {1,1,1,1,1,3,5,2},--10},
                    corridorChance = .3 or .9,
                }) or
            
                toybox.rot().Map[xx==2 and "IceyMaze" or maps[z]](self.digW, self.digH/(z==3 and 1 or 1), {
                caveChance =xx==2 and 1 or 0, z==2 and 1 or 0,
                chavePasses = 3,
                maxRooms = levelDat.maxRoomsToBuild or 6, 
                minRooms = levelDat.minRoomsToBuild or 4,
                roomWidth = levelDat.roomWidth or {3,4,5,5,5,5,6,6,4,4,4,5,7,8,10},--{3,4 or 6},
                roomHeight = levelDat.roomHeight or {3,4,5,5,5,5,6,6,4,4,4,7,8,10},
                croussWidth = {0,0},
                crossHieight = {0,0},
                -- maxRooms = 11
     
                 corridorWidth = {1,1,1,2,2,2,4},--,10},
                 corridorHeight = {1,1,1,1,1,3,2},--10},
                 corridorChance = .3 or .9,
            })
            
            local oldArgs = {self.digW, self.digH/(z==3 and 1 or 1), {
                    caveChance =xx==2 and 1 or 0, z==2 and 1 or 0,
                    chavePasses = 3,
                    maxRooms = 12, 
                    minRooms=8,
                    maxCorridorsPerRoom = 2,
                    roomWidth = {3,4,5,7},--{3,4 or 6},
                    roomWi4dth = {6,8},
                    roomtHeight = {6,10},
                    croussWidth = {0,0},
                    crossHieight = {0,0},
                    -- maxRooms = 11
     
                    corridorWidth = {1,1,1,2,2,2,4,5},--,10},
                    corridorHeight = {1,1,1,1,1,3,5,2},--10},
                    corridorChance = .3 or .9,
                }}
            
                if maps[z] == "Cellular" then
                    r:randomize(.6)--floorProb
                end
                
                for x = 1, z<3 and 1 or z==2 and 1 or 1 do
                    r:create(rmake)--, self.first and math.random()>.8 or math.random()>.95) -- big first room behaviour
                end
        
                if #r:getRooms() <= 5 and countm<50 and not PIG then
                    gridTmp = {}
                    -- goto skip--return nm()
                end
            
                if #r:getRooms() >= 10 and countm<50 then
                    -- goto skip
                end if 1 then--else
                    --- actually make the tiles
                    okay = true
                    for x, i in ipairs(allTiles) do
                        local xx, yy = 0, 0--self.minSpaceX-5, self.minSpaceY-5
                        make(i[1]-xx, i[2]-yy, i[3], i[4], nil, i[1], i[2])
                    end
                end
        
                local d = {}
                for _, door in ipairs(r.getDoors and r:getDoors() or {}) do
                    local t = self:getTile(door.x, door.y)
                    if t and not t.door then
                        t:makeDoor()
                        d[#d+1] = t
                    end
                end
            
                for x , room in ipairs(z==4 and {} or r.getRooms and r:getRooms() or {}) do
                    local ro = Room:new({
                        parent = self,
                        data = room,
                        real = true, math.random()>.9,--true
                    })
                    -- ro.doors = d
                    mmm.cave=null--:cave(ro)
                    local room = ro
                    -- mmm:dig({x=room._x,y=room._y,w=room.w,h=room.h,type="Brogue",caveChance=10,room=room})
                
                    -- room mutation
                    -- mmm:random(ro)
                    self.rooms[#self.rooms+1] = ro
                    if math.random(100)<(levelDat.grassifyChance or 40) then
                        self:grassify(ro, grasses[levelDat.grass or "grass"] or levelDat.grass)
                    end
                end
            
                self.digger = r
                -- self:fixCorridors()
                self.caving = false
            
                ::skip::
            end
    
            if z == 2 then
                nm()--self:after(5,nm)
            else
                nm()
            end
    
        end
    
        -- fixing blocked passages
        for i, tile in ipairs(self.allTiles) do
            if levelDat.grassifyAll then
                self:makeGrass(tile)
            end
            
            tile.temperature = getValue(levelDat.baseTemperature) or tile.temperature
            
            if levelDat.soily then
                tile.soily = true
            end
            
            if levelDat.icy then
                tile.icy = true
            end
            
            if tile.solid then
                local r = tile.roomData
                local continue = false
                for x = 1, 8 do
                    local d = dirs8[x]
                    local t = self:getTile(tile._x+d[1], tile._y+d[2])
                    if t and not t.solid then
                        continue = true
                        break
                    end
                end
            
                continue = continue and tile.roomData ~= self
            
                for ii, x in ipairs(tile.roomData.doors) do
            
                    if not continue then
                        break
                    end
            
                    -- finding which side of the door is open
                    local t2 = self:getTile(x._x+1,x._y)
                    if (t2 and t2.solid) then
                        if tile._y == x._y and tile._y ~= r.maxTileY and tile._y ~= r.minTileY then
                            tile.solid = false
                            break
                        end
                    else
                        if tile._x == x._x and tile._x ~= r.maxTileX and tile._x ~= r.minTileX then
                            tile.solid = false
                            break
                        end
                    end
                end
            
                if not tile.solid then
                    warn("[MAP GEN] Fixed blocked tile!")
                    tile.fixed = true
                end
            end
        end
 
     
        for x = 1,#gridTmp do
            local i = gridTmp[x]
            -- make(i[1],i[2],i[3],i[4],i[5])
        end
        gridTmp = {}
        
    end
    
    local function closeness(r,r2)
        return r.allTiles[1].x<r2.allTiles[1].x
    end
    
    self:fixDoors()
    
    -- if #self.rooms == 0 then self.rooms[1] = self end
    
    table.sort(self.rooms, closeness)
    local mid = self:getTile(math.floor(self.maxTileX/2), math.floor(self.maxTileY/2))
    --self.timer:every(.1,function() self.camera.scale = .1 lightAll=1 self:set_target(mid) end)

    else
        self:loadMapData(k.mapData)
    end
    
    log("[MAP] Done digging")
    
    self.levelDat = self.levelDat or {}
    
    self.nextMapKwargs = k.nextMapKwargs or self.levelDat.nextMapKwargs
    self.nextMapData = k.nextMapData or self.levelDat.nextMapData
    
    self.playerData = k.playerData
    
    self.playerClassData = k.playerClassData or {}
    
    self.playerPostMake = k.playerPostMake
    
    self.overrideInventory = k.overrideInventory
    
    self.mapGrid = {}
    --local t = self.rooms[1]:getRandomSpaceTile()--:getPosition("space",self.rooms[1])
    
    for x,c in ipairs(self.allTiles) do
        local x,y = c._x, c._y
        self.mapGrid[y] = self.mapGrid[y] or {}
        self.mapGrid[y][x] = c
    end

	function isOpen(t)
        if t.solid then
            return false
        else
            return true
        end
	end

    self._grid = JumperGrid(self.mapGrid)
    self.pathfinder = PathFinder(self._grid,"ASTAR",
        isOpen
    )

    self.pathfinder:setMode("ORTHOGONAL")
    
    self.stateMachine = StateMachine:new({
        map = self
    })
    
    self.level = k.level
    self.hasUpstairs = k.next
    self.first = not k.next and not oldMap
    
    
    self.cameraOffset = 0
    
    self.cameraMan = {x=0,y=0,scale=.5}
    self.cameraMan.scale = .5
    self:set_target(self.cameraMan)
    self._set_target = self.set_target
    self.set_target = self.Y--self.setCameraTarget--Y
    self:set_target(t)
    
    self.creatures = {}
    self.currentCreature = 0
    
    self.items = {}
    
    self.gases = {}
    self.fires = {}
    
    self.trapsToActivate = {}
    
    self.checkPuddles = {}
    
    
    self.useFunc = function()
        local self = toybox.room
        local item = self.currentItem
        
        self:removePopUp()
        
        if item.useText == "equip" then
            self.inventoryUser:equipItem(item)
        end
        
        if item.useText == "eat" then
            self.player:eat(item)
        end
        
        
        if not item:onUse(self.inventoryUser, self) then
            self:playNextCreature()
        end
    end
    
    
    self.dropFunc = function()
        local self = toybox.room
        local item = self.currentItem
        self.inventoryUser:removeItem(item, nil, 10)
        
        self:removePopUp()
        
        self:playNextCreature()
    end
    
    self.throwFunc = function()
        local self = toybox.room
        
        do
            self.selectingTarget = nil
            self.throwing = nil
            self.selectedTarget = nil
            self.wandZapping = false
        end
        
        self.throwing = self.currentItem
        self.clicked = true
        self:closeInventory()
        self:removePopUp()
        
        local m = self.throwing.utility < 1 and self.player:getEnemies(nil, true) or self.player:getAllies()
        
        if m[1] and m[1].tile then
        
            
            self:manageThrow(m[1].tile)
        end
    end
    
    
    self.chooseItemFunc = function(button)
        local self = toybox.room
        self.choosingItem.action(self.currentItem, self)
    
        self.choosingItem = false
        self:removePopUp()
    end
    
    local g = "inv"
    self:activate_gooi()
    gooi.currentGroup = g
    local iw, ih = W()/3.4, H()*.95
    local inv = 8
    if oldMap then
        log("bananananan")
        log(tostring(getOld("inventoryPanel")))
        if not (getOld("inventoryPanel")) then self.timer:after(5, function() error("no") end) end
    end
    self.inventoryPanel = getOld("inventoryPanel") or gooi.newPanel({
        group = g,
        x = W()-iw-10, y = H()/2-ih/2,
        w = iw, h = ih, paddingY=0,
        layout = string.format("grid %sx4",inv)
    }):setColspan(1,1,4):setRowspan(1,1,.6)--:debug()
    
    local invp = self.inventoryPanel
    invp.outx = W()+invp.w*1.2
    invp.ogx = invp.ogx or invp.x
    
    invp.opaque = true
    
    if not invp.img then
        invp.img = invp:addImage("ui/inventory.png")
        invp.drawOnlyImage = true
    end
    
    self.inventoryHeader = getOld("inventoryHeader") or gooi.newPanel({group=g, layout="grid 1x7",padding=3,paddingY=2})
    
    self.inventoryCancel = getOld("inventoryCancel") or gooi.newButton({
        group = g,
        fgColor = {1,0,0},
        text = "" or "[X]", -- [amount] (size)",
    }):center():onRelease(function()
        toybox.room:closeInventory()
    end)
    self.inventoryCancel.fgColor = {1, 0, 0, 1}
    local img = self.inventoryCancel:addImage("ui/invX.png")
    img.color = {1,0,0}
    
    
    self.inventoryButton = getOld("inventoryButton") or gooi.newButton({
        group = g,
        text = "" or "Inventory", -- [amount] (size)",
    }):center():onRelease(function()
      --  self:closeInventory()
    end)
    local img2 = self.inventoryButton:addImage("ui/inventoryLabel.png")
    self.inventoryButton.drawOnlyImage = true
    
    if not oldMap then
        local font = font10
        self.inventoryButton.font = font
        self.inventoryPanel:add(self.inventoryHeader)
        self.inventoryHeader:setColspan(1,2,4)
    
        -- self.inventoryButton.showBorder = false

        self.inventoryHeader:add(self.inventoryCancel)
        self.inventoryHeader:add(self.inventoryButton)
    end
    
    local function moveRight(b)
        local self = toybox.room
        local c = self.currentInvPage or 1
        local max = self.invPages
        if (c+1) <= max then
            self.lastPage = c+1
            self:reloadInventoryUI(nil, c+1)
        end
    end
    
    local function moveLeft(b)
        local self = toybox.room
        local c = self.currentInvPage or 1
        local max = self.invPages
        if (c-1) > 0 then
            self:reloadInventoryUI(nil, c-1)
        end
    end
    -- reloadinv
    self.invRight  = getOld("invRight") or gooi.newButton({text="" or ">"}):onRelease(moveRight)
    self.invLeft   = getOld("invLeft") or gooi.newButton({text="" or "<"}):onRelease(moveLeft)
    
    self.invRight:addImage("ui/invRight.png")
    self.invLeft:addImage("ui/invLeft.png")
    
    if not oldMap then
        self.inventoryHeader:add(self.invLeft)
        self.inventoryHeader:add(self.invRight)
    end
    
    self.inventoryUI = getOld("inventoryUI") or {}
    
    local function popUpItem(inv)
        log("on_mkve")
        if inv.data then
            if toybox.room.popUpItem == inv.data[1] then
                log("pop up terminated")
            else
                toybox.room:itemPopUp(inv.data[1])
            end
        end
    end
    --p:reloadinventoryuii
    for x = 1, oldMap and 0 or (inv-1)*4-1 do--inv-1 do
        local invP = gooi.newPanel({group=g,layout="grid 1x5",padding=3,paddingY=0}):debug()
        local invB = gooi.newLabel({text="", font=lg.getFont()}):left():onRelease(popUpItem)
        invB:onMoved(popUpItem)
        
        invB.opaque = true
        invB.borderRadius = 0
        invB.og_yOffset = invB.yOffset
        invB.yOffset = 0
        local invS = gooi.newButton({font=lg.getFont(),text=""})
        invS.showBorder = true
        
        invB.h = invB.w
        
        -- invB:addImage("ui/inventoryButton.png")
        
    do
        local ui = invB
        ui:addImage(false and "ui/smallStonePanel.png" or "ui/smallPanel.png")
        ui.drawImageOnly = true
    end
    
        invB.showBorder = false
        invB.noStencil = true
        invB.drawRect = false
    
        self.inventoryPanel:add(invB)
        invP:setColspan(1,1,5)
        -- invP:add(invB)
        -- invP:add(invS)
        invP.b = invB
        invP.s = invS
        invB.panel = invP
        --invB.showBorder = true--false
        if x == 1 then
            self.inventorySpace = invB
            invB.opaque = false
        else
            self.inventoryUI[x-1] = invB
        end
        invB.font = font
        --invS.font = font
    end
    
    if oldMap then
        self.inventorySpace = getOld("inventorySpace")
    end
    
    local oow, ooh = 90*1.4
    self.openInvButton = getOld("openInvButton") or gooi.newButton({
        text = "",
        w = oow, h = ooh or oow,
        x = W()-oow-10,
        y = 10, group = g
    })
    :onRelease(function(c)
    
        c.bagImage.source = "bag.png"
     
    end)
    :onSquash(function(c)
        
        if self.player then
            self.player:play_sound("zip")
        end
        
        c.bagImage.source = "bag_open.png"
        
        if not toybox.room.inventoryIsOpen then
            log("open from inventory button")
            toybox.room:openInventory()
        else
            log("inventory already open??")
        end
    end)
    
    self.openInvButton.squash = true
    self.openInvButton.drawRect = false
    self.openInvButton.onlyImage = true
    self.openInvButton.bagImage = self.openInvButton:addImage("bag.png")
    self.openInvButton.showBorder = false
    self.openInvButton.bgColor = {0,0,0,0}
    
    -- gooi.removeComponent(self.openInvButton)
    
    
    local slot
    
    local function quickedItem(item, sl)
        if NO_QUICKSLOTS then
            return
        end
        
        local self = toybox.room
        slot = slot or sl or self.freeQuickSlots[1]
        
        if not slot then
            return
        end
        
        if slot.item then
            slot.item.quickslot = nil
        end
        
        if item.quickslot then
            item.quickslot.item = nil
        end
        
        --self:toast(item.name, "skyblue")
        
        item.light_alpha = 1
        item.color = item.itemColor or {1,1,1}
        
        slot.item = item
        lume.remove(self.freeQuickSlots, slot)
        --slot.icon = item.sprite and item.sprite.source or game:getAsset(item.source)
        item.quickslot = slot
        if self.player then
            -- self.player:cry(item.name)
        end
        slot:shake(25,.5,35,"Y")
        slot = nil
        
        -- self:closeInventory()
    end
    
    self.putItemInQuickSlot = quickedItem
    
    local function displayQuickItem(n)
        if n.item then
            self:setInfo(n.item:getName())
        end
    end
    
    local function selectQuickItem(n)
        local self = toybox.room
        if n.item then
            self:toast(n.item.name, "skyblue", nil, nil, nil, -50)
        end
        
        if n.item and self.quickItem == n.item then
            
            if n.item.user ~= self.player then
                self:addLog("&colors.red Item isn't in your hands!")
                return
            end
            
            local ni = n.item
            --self.player:cry(n.item.name)
            local throw = (ni.isPotion and data.knownPotions[ni._id] or not ni.isPotion) and ni.utility<0 and not ni.isScroll and not ni.isWand
            
            n.borderColor = getColor("green")
            self:addLog(string.format("%s %s", throw and "throwing" or "using", n.item.title))
            
            local function nullc()
                n.borderColor = nil
            end
            
            self:after(.2,nullc)
            if throw then
                self.currentItem = n.item
                self.throwFunc()
            else
                if n.item.useText == "equip" then
                    self.inventoryUser:equipItem(n.item)
                end
            
                if n.item.useText == "eat" then
                   self.player:eat(n.item)
                end
                
                log(tostring(self.player.room == self)..": room stats?")
        
                if n.item then n.item:onUse(self.inventoryUser, self) end
            end
            
            self.quickItem = nil
            return
        elseif n.item then
            if not DESKTOP then
                local useText = n.item.useText or "use"
                local ni = n.item
                if (ni.isPotion and data.knownPotions[ni._id] or not ni.isPotion) and ni.utility<0 and not ni.isScroll and not ni.isWand then
                    useText = "throw"
                end
            
                self:toast(string.format("click again to %s",useText))
                self.quickItem = n.item
            else
                self.quickItem = n.item
                selectQuickItem(n)
            end
            return
        end
        
        self.quickItem = nil
        
        slot = n
    
        -- self:toast(string.format("Choose an item to add to quickslot"))
            
        self.choosingItem = {
            chooser = self.player,
            canCancel = true,
            tile = self.player.tile,
            cancelText = "Cancel quick prompt select",
            promptText = "Select an Item for Quickslot",
            noCancelPrompt = true,
            noPrompt = true,
            text = "enchant",
            action = quickedItem,
            ui = n,
            textModifiyyer = "&colors.orange ",
            color = colors.orange
        }
        
        log("choosing item")
        self:reloadInventoryUI(self.player)
        self:openInventory()
    end
    
    local qpad = 5
    
    local sc = .6
    local qw = W()*.6*sc
    local qh = 116.3*sc+20--(qw/6)--+qpad*5--H()/10
    qw = qw + (10+qh)*2
    
    local qy = H()-qh-10-35
    
    if DESKTOP then
        self.openInvButton.y = qy-(self.openInvButton.h-qh)
    end
    
    local function fixSmallPanel(ui, stone)
        ui:addImage(stone and "ui/smallStonePanel.png" or "ui/smallPanel.png")
        ui.drawImageOnly = true
    end
    
    self.quickslots = oldMap and oldMap.quickslots or gooi.newPanel({group = g,
        w = qw,
        x = W()/2-qw/2,--invp.x - qw - 10,--W()/2-qw/2,
        y = qy,
        h = qh,
        layout = "grid 1x8", padding = qpad
    })
    self.qDiff = self.quickslots.x-(invp.ogx - qw - 10)
    self.quickslots.ogx = self.quickslots.x
    self.quickslots.outx = self.quickslots.x-self.qDiff
    
    self.quickslotButtons = getOld("quickslotButtons") or {}
    self.freeQuickSlots = getOld("freeQuickSlots") or {}
    
    local b
    for x = 1, oldMap and oldMap.quickslots and 0 or 8 do
        b = gooi.newButton({text=""})
        self.quickslots:add(b)
        b:onRelease(selectQuickItem)
        b:onMove(displayQuickItem)
        self.quickslotButtons[x] = b
        self.freeQuickSlots[x] = b
        
        fixSmallPanel(b)
    end
    
    
    
    if NO_QUICKSLOTS then
        gooi.removeComponent(self.quickslots)
    end
    
    local function skipTurn()
        local self = toybox.room
        if self.player and self.player.playing then
            self:toast("Skipped Turn", nil, nil, nil, -200)
            self:playNextCreature()
        end
    end
    
    local function re_equip(r)
        local self = toybox.room
        --[[if self.player.playing then
            local n = self.player.equipped
            if n then
                self.player.oldEq = n
                self.player:unequipItem(self.player.equipped)
                r:shake(20,.2,14,"Y")
            elseif self.player.oldEq and self.player:hasItem(self.player.oldEq) then
                self.player:equipItem(self.player.oldEq)
                self.player.oldEq = nil
                r:shake(20,.2,14,"Y")
            else
                local t = self:toast("&colors.red No item ~  to re-equip", nil, nil, nil, -200, nil)
                t.x = t.x - 50
                r:shake(20,.2,20)
            end
        end]]
        self.player.fightAll = not self.player.fightAll
        self.eqImage.color = getColor(self.player.fightAll and "red" or "white")
        self:toast(self.player.fightAll and "&colors.red Fighting all creatures" or "Fighting only enemies", nil, nil, nil, -200)
    end
    
    local function re_checking(r)
        local self = toybox.room
        self.player.checking = not self.player.checking
        self.checkImage.color = getColor(self.player.checking and "lime" or "white")
        self:toast(self.player.checking and "&colors.green Displaying ~ ally tags" or "&colors.red Not displaying ~ ally tags", nil, nil, nil, -200)
    end
    
    local function re_speed(r)
        local self = toybox.room
        FAST = not FAST
        self.speedImage.color = getColor(FAST and "green" or "white")
        
        local t = self:toast(FAST and "Quick mode &colors.green enabled" or "Quick mode &colors.red disabled", nil, nil, nil, -200, nil)
        t.x = t.x - 50
    end
    
    self.infoText = getOld("infoText") or Sentence:new({
        x = self.quickslots.x or wx,
        y = b.y+b.h+10,-- or l and (l.y+5) or (10+30),
        w = self.quickslots.w, instant=true
    }):newText("a sog bone")
    
    local function scroll()
        if toybox.room.cover and not toybox.room.cover.scrolled then
            toybox.room:scroll()
        end
    end
    
    
    self.canvasMapData = {
        x0 = 10, y0 = H()/2-150,
        w0 = 1, h0 = 1,
        
        x1 = 10, y1 = H()/2-150,
        w1 = W()/3.5, h1 = H()/3.5,
        
        x2 = W()/2-W()/4, y2 = H()/2-H()/4,
        w2 = W()/2, h2 = H()/2
    }
    
    local cd = self.canvasMapData
    cd.x, cd.y, cd.w, cd.h = cd.x0, cd.y0, cd.w0, cd.h0
    
    self.drawMap = 0
    local vals = {"x", "y", "w", "h"}
    
    local function removeMap()
        self.doDrawMap = false
    end
    
    local function showMap()
        self.drawMap = self.drawMap > 1 and 0 or (self.drawMap+1)-- wcanvas
        self.doDrawMap = true
        
        if self.drawMap then
            local dM = self.drawMap
            if self.showMapTimer then
                self.timer:cancel(self.showMapTimer)
            end
            local func = self.drawMap == 0 and removeMap
            self.showMapTimer = self:tween(.5, cd, {
                x = cd[string.format("x%s",dM)],
                y = cd[string.format("y%s",dM)],
                w = cd[string.format("w%s",dM)],
                h = cd[string.format("h%s",dM)],
            }, "in-quad", func)
        end
        self:reloadCanvas(1)
    end
    
    self.showMapFunction = showMap
    
    local ws = (H()/25)*2
    local wx = ws-10+W()*.2+10
    self.scrollButton = getOld("scrollButton") or gooi.newButton({text="",group=g,w=W()-self.openInvButton.w*2,-ws-self.inventoryPanel.w,h=b.h+40,y=0,x=0}):
        onRelease(scroll)
    self.scrollButton.drawComponent = null
    self.scrollButton.draw = null
    
    self.waitButton = getOld("waitButton") or gooi.newLabel({text="",group=g,w=b.w,h=b.h,y=b.y,x = 10})
        :onRelease(skipTurn)
    self.waitButton.opaque = true
    fixSmallPanel(self.waitButton, true)
    self.waitImage = self.waitButton:addImage("rest.png")
    
    
    self.equipButton = getOld("equipButton") or gooi.newLabel({text="",group=g,w=b.w,h=b.h,y=b.y-5-b.h, x = 10})
        :onRelease(re_equip)
    
    self.checkFriendButton = getOld("checkFriendButton") or gooi.newLabel({text="",group=g,w=b.w,h=b.h,y=b.y-5-b.h-b.h-5, x = 10})
        :onRelease(re_checking)
    self.checkFriendButton.opaque = true
    
    
    self.speedButton = getOld("speedButton") or gooi.newLabel({text="",group=g,w=b.w,h=b.h,y=self.waitButton.y, iy=b.y-5-b.h, x = 10+10+b.w})
        :onRelease(re_speed)
    self.speedButton.opaque = true
    
        
    self.checkImage = getOld("checkImage") or self.checkFriendButton:addImage("question.png")
    
    self.speedImage = getOld("speedImage") or self.speedButton:addImage("speed.png")
    self.speedImage.color = getColor(FAST and "green" or "lightgrey")
    
    
    self.showMapButton = getOld("showMapButton") or gooi.newLabel({text="",group=g,w=b.w,h=b.h,y=b.y, x = 10+10+10+b.w*2})--b.y-b.h-10,x = 10+10+b.w})
        :onRelease(showMap)
    self.showMapButton.opaque = true
    self.showMapImage = self.showMapButton:addImage("items/scroll.png")
    
    if b then
        self.speedImage.w = b.w*.8
        self.speedImage.h = b.h*.8
        self.speedImage.offset_x = (b.w-b.w*.8)/2
        self.speedImage.offset_y = (b.h-b.h*.8)/2
    end
    
    stuff = {self.equipButton, self.showMapButton, self.speedButton, self.checkFriendButton, self.waitButton}
    for x, i in ipairs(stuff) do
        if x ~= #stuff then
            gooi.removeComponent(i)
        else
            -- pass
        end
    end
    
    self.equipButton.opaque = true
    
    local eq = self.equipButton
    self.eqImage = getOld("eqImage") or eq:addImage("fist.png")
    
    
    self:closeInventory(true)
    
    log("[MAP] UI done")
    
    self.noiseManager = NoiseManager:new({})
    self.nm = self.noiseManager
    self.noise = self.nm
    self:getFov()


    local function reflectivityCB(lighting, x, y)
        local t = self:getTile(x,y)--local key=x..','..y
        return t and not t.solid and .3 or .4
    end
    
    local function lightTile(x, y, light)
        local t = self:getTile(x,y)
        if t then
            t.lightColor = {light[1]/10,light[2]/10,light[3]/10} if nnt then warn(inspect(light)) end
        end
    end
    
    self.teleportRunes = {}
    
    self.lightTile = lightTile
    
    self.lighting=ROT.Lighting(reflectivityCB, {range=12, passes=1})
    self.lighting:setFOV(self.fov)


    
    self.exploding = 0
    self.currentTurn = 1
    
    self.logs = getOld("logs") or {}
    

    self.cover = getOld("cover") or {x=0, y=-H(), h=H(), w=W()*2}
    self.coverAll = {x=-10, y=-H()-10, h=H()+10, w=W()*2}
    
    self.toAddLog = getOld("toAddLog") or {}
    
    
    local r1 = self.rooms[1]
    r1.roomTypes.starting = true
    
    self.fallToStairs = k.fallToStairs
    
    self.lavaChance = (k.lavaChance or self.levelDat.lavaChance) or 10
    self.cavernChance = (k.cavernChance or self.levelDat.cavernChance) or 30
    self.lakeChance = (k.lakeChance or self.levelDat.lakeChance) or 43
    
    log("CAVERN")
    if not k.noCavern and (self.cavernChance >= math.random(100)) then
        self:getCavern()
    end
    
    
    log("LAVA")
    local ddone, oCount, tilesCount 
    INFORM_PLAYER("seeking lava")
    if not k.noLake and (self.lavaChance >= math.random(100)) and not ddone then
        ddone, oCount, tilesCount = self:getLake('lava')
        if (k.mustLake or self.levelDat.mustLake) and not ddone and not (self.levelDat.noBuild) then
            error("No lake")
        end
    end

    log("LAKE")
    local oCount, tilesCount 
    INFORM_PLAYER("seeking lakes")
    if not k.noLake and (self.lakeChance >= math.random(100)) and not ddone then
        ddone, oCount, tilesCount = self:getLake()
        if (k.mustLake or self.levelDat.mustLake) and not ddone and not (self.levelDat.noBuild) then
            error("No lake")
        end
    end
    
    
    
    
    log("[MAP] BUILDING?")
    INFORM_PLAYER("digging through the caves...")
    if not k.noBuild and self.level then
        INFORM_PLAYER("...building level "..inspect(self.level))
        self:build(dungeon[self.level or self.next and error()])
    end
    
    
    self.levelNumber = game.levelNumber + 1
    game.levelNumber = game.levelNumber + 1
    
    if game.campaignDat.postMake then
        game.campaignDat.postMake(self)
    end
    
    
    log("[MAP] Done building")
    
    if not ddone then
        warn("[LAKE GEN] "..(tilesCount or 0).." smaller than "..(oCount or 0)..", "..(didDoor and "didDoor" or "no door"))
    end
    
    self.noSpawnItems = k.noSpawnItems
    
    self.playerInventory = k.playerInventory
    
    if not k.noLoadPlayer then
        self:spawnPlayer(k.player or self.player, self.spawnTile or getValue(self.spawnTiles) or self.previousTile or self.rooms[1]:getRandomSpaceTile())
        log("spawned player for real")
    else
        self.player = k.player
    end
    
    -- if math.random()>-5.5 then log("yoh errorz") error("theres an er") end
    
    log("spawned player")
    
     --Trap.loadTrap(traps.poisonGasTrap, self.rooms[1])
    
    local v = VelocityController:new()
    v:attach(self.player)
    self.player.controller = v
    
    self.classic = false and true
    
    --self:gass()
    --Map:new({})
    --if self.room == self.player.room then
        log("STARING OFF TURN, nah, too toxic, what if an item or creature falls to a new map before oldMap is a thing")
        -- self:playNextCreature()
    --end
    
    log("next")
    
    self.player.canPickItems=1
    self.player.title = "you"
    self.player.name = "human"
    self.player.article = ""
    self.player.titlePossessive = "your"
    self.player.pronoun = "your"
    
    _G.pl = self.player
    
    --self.nm:addNoise("step",5,self.player.tile) --
    self:every({3,10},function() 
    --self:spawn("pig",nil,{self.player.team,"pig",false}) 
    end)-- error(self.nm:giveInfo()) end)
     
     
    if true then--not oldMap and not RELEASE then
        self:addDebugControls()
    end
    
    if k.postMake then
        k.postMake(self)
    end
    
    self.eventTimers = k.eventTimers or getOld("eventTimers")
    self.events = k.events or getOld("events")
    self._eventTime = 5 or getOld("_eventTime")
    
    self.spawnTable = k.spawn or getOld("spawnTable")
    
    if PIG and not INTRO then
        self.structures = k.structures or getOld("structures")
        
        assert(self.events)
        assert(self.eventTimers)
        assert(self.structures)
        
        for x = 1, 10 do
            local structName = getWeight(self.structures)
            local struct = PIG_DATA.structures[structName] or error(structName)
            local done
            count = 25
            local allTiles = lume.copy(self.allTiles)
            while not done and count > 0 do
                count = count - 1
                done = struct.action(lume.eliminate(allTiles), self)
            end
        end
        
        local maxGold = 1000*self.maxTileX/80
        local goldValues = {50, 25}
        local goldAmount = {1,1,1,2,3,2}
        local rooms = lume.shuffle(self.rooms)
        for am = 1, #self.rooms do
            local r = self--rooms[am]
            local amount = getValue(goldAmount)
            local divide = math.random()>.2
            for xx = 1, amount do
                local val = math.floor(lume.min(maxGold, getValue(goldValues)/(divide and amount or 1)))
                maxGold = maxGold - val
        
                local gold = self:spawnItem("gold", r:getRandomSpaceTile())
                if gold then
                    gold.value = val
                else
                    maxGold = maxGold + val
                end
            
                
                if maxGold <= 0 then
                    break
                end
            end
        
            
            if maxGold <= 0 then
                break
            end
        end
        
        local count = 100
        local tile
        while not tile or tile.solid do
            tile = FEATURE and getValue(FEATURE) or self:getRandomSpaceTile()
            count = count-1
            if count<= 0 then
                break
            end
        end
        
        if tile then
            self:spawnItem("madorb", tile)
            self:spawn("ogre", tile)
            orbTile = tile
        end
        
        local spawnStrengthOrb = function()
            self:addLog("&colors.red #Something is .... @ angry ?")
            for x = 1, 1 do
                self:spawnItem("strength_orb", self:getRandomUnseenSpaceTile())
                -- self:spawn("ogre", tile)
                orbTile = tile
            end
        end
        
        self:after(60*math.random(15,20)*.1, spawnStrengthOrb)
        
        for x = 1, math.random(4, 8) do
            self:spawnItem("explosive_barrel", self:getRandomSpaceTile())
        end
        
        for x = 1, math.random(1,2) do
            self:spawnItem("lore_note", self:getRandomUnseenSpaceTile())
        end
        
        self:doPigSpawn()
        
        if not self.loggedOrbs then
            self.logs = {}
            self:addLog("&colors.lime Heheheh...collect the...@ &colors.cyan three orbs of power &colors.lime !!")
            self.loggedOrbs = true
        end
    end
    
    self.isIntro = INTRO
    
    if INTRO then
        local function introPlayer()
            local ww = W()*.45
            local hh = W()*.41
            
            local function func()
                gooi.alert({
                    text = helpText2,
                    big = true,
                    w = ww,
                    h = hh,
                })
                gooi.okButton.y = gooi.okButton.y + 50
            end
            
            gooi.alert({
                text = helpTextIntro,
                big = true,
                w = ww,
                h = hh,
                ok = func
            })
        end
        
        self:after(1.5, introPlayer)
        self.player.doneLoading = true
    end
    
    
    self.OG_emptyTiles = self:getSpaceTiles()
    
    -- doMapThing(self)
    -- lighting canvas stuff
    
    local r = self--pl and pl.room or toybox.room
    r.canvasTiles = {}
    
    r.timer:after(.1, function()
        r:reloadCanvas()
        r:reloadLightCanvas()
    end)
    r.reloadLightCanvasTime = .3
    r.reloadLightCanvasTicker = 0
    
    
    
    --self:gass()
    --Map:new({})
    --if self.room == self.player.room then
        log("STARING OFF TURN FOR REAL THIS TIME?")
        self:playNextCreature()
    --end
    
    oldMap = oldMap or self
    self.player.doneLoading = true
    
    if (not gamedata.hasPlayedBefore and not INTRO) or true then
        self:openInventory()
    end
    
    if not INTRO then
        gamedata.hasPlayedBefore = true
    end
    
    game:saveData()
    
    self:reloadInventoryUI()
    log("done making map")
    
    INFORM_PLAYER("", true)
end

function Map:doPigSpawn()
    for x = 1, 5 do
        local cr = getWeight(self.spawnTable)
        if not creatures[cr] then
            error(cr)
        end
        
        local tile
        local count = 30
        while not tile or tile:canBeSeen() do
            tile = self:getRandomSpaceTile()
            count = count - 1
            if count <= 0 then
                break
            end
        end
        
        self:spawn(cr, tile)
    end
end

function Map:spawnLoreNotes()
    for x = 1, math.random(1,3) do
        local tile
        local count = 30
        while not tile or tile:canBeSeen() or tile.item do
            tile = self:getRandomSpaceTile()
            count = count - 1
            if count <= 0 then
                break
            end
        end
        
        self:spawnItem("lore_note", tile)
    end
end

function Map:toast(text, color, xx, yy, x2, y2, mx, my)
    local f = lg.getFont()
    local s= (1)*math.random(90,120)/100
    local x,y = self.camera:toWorldCoords(
        W()/2-f:getWidth(text)*s*.5+(x2 or 0),
        H()-100-f:getHeight()*s+(y2 or 0)-50
    )
    
    local t = Text:new({
        x = xx or (x+(mx or 0)),
        y = yy or (y-50+(my or 0)),
        text = text,
        color = color,
        scale = s,
        b = "",
        angle = math.random(-15,15),
        font = font18
    })
    t.vy=-50
    self:must_update(t)
    return t
end



function Map:alert(text, color, xx, yy, x2, y2)
    if true then return self:doScreenCrack(text, color) end
    
    local f = font20 or lg.getFont()
    local s= (2)*math.random(90,120)/100
    
    local tt = Sentence:new({instant=true,x=0,y=0,w=W()})
    tt:newText(text)
    
    local ttext = tt.shortText
    
    local x,y = self.camera:toWorldCoords(
        W()/2-f:getWidth(ttext)*s*.25+(x2 or 0),
        H()/2-f:getHeight()*s*.5+(y2 or 0)
    )
    
    local t = Text:new({
        x = xx or x,
        y = yy or y,
        text = text,
        color = color or "crimson",
        scale = s,
        b = "",
        background = .5,
        backgroundColor = "darkred",
        alpha = .8,
        angle = 0,--math.random(-15,15),
        -- font = f,
        life = 1.6
    })
    
    local function fadeAway()
        self:tween(.6,t,{alpha=0},"out-quad")
    end
    
    self:after(1.0, fadeAway)
    
    t.vy=0
    self:must_update(t)
end

function fixu()
    
    for x = 1, 16-1 do
        -- local invP = gooi.newPanel({group=g,layout="grid 1x5",padding=3,paddingY=0})
        local invB = self.inventoryUI[x-1] -- gooi.newLabel({text="", font=lg.getFont()}):left():onRelease(popUpItem)
        local invP = invB.panel
        --invB:onMoved(popUpItem)
        
        invB.opaque = true
        invB.borderRadius = 0
        invB.og_yOffset = invB.yOffset
        invB.yOffset = 0
        local invS = gooi.newButton({font=lg.getFont(),text=""})
        invS.showBorder = true
        
        invB:addImage("ui/inventoryButton.png")
        invB.showBorder = false
        invB.noStencil = true
        invB.drawRect = false
    
        self.inventoryPanel:add(invP)
        invP:setColspan(1,1,5)
        invP:add(invB)
        -- invP:add(invS)
        invP.b = invB
        invP.s = invS
        invB.panel = invP
        --invB.showBorder = true--false
        if x == 1 then
            self.inventorySpace = invB
            invB.opaque = false
        else
            self.inventoryUI[x-1] = invB
        end
        invB.font = font
        --invS.font = font
    end
end

function Map:getTileLight(tile)
    local c = getColor(tile.ambient or {0.1,.1,.1})
    local c = getColor(tile.color or {1,1,1})
    if tile.lightColor then
        c = t.lightColor--toybox.rot().Color.multiply(cc, t.lightColor)--.add(c, tile.lightColor)
    end
    local final= c--toybox.rot().Color.multiply(cc, c)
    
    return final
end
function Map:computeLight()
    self.lighting:compute(self.lightTile)
end

function Map:addDebugControls()
    local g = gooi.currentGroup
    local debug = gooi.newPanel({group=g,x=100,w=W()-W()/3,y=100,h=H()/12,layout="grid 1x8"}):
        setColspan(1,1,7)
    
    debug.opaque = true
    debug.alpha = .65
    
    
    local text = gooi.newText({text=""})
    self.debugText = text
    
    debug:add(text)
    
    local function doSubmit(b)
        _G["self"] = self
                
        local txt = text:getText()
        if txt == "r" then
            text:setText(oldText or "no old text")
            return
        end
                
        oldText = txt
                
        l,e = loadstring(text:getText())
        if e then
            cwlog(e,"red")
            self:addLog(string.format("&colors.orange %s", e))
            pl:cry(e,"orange")
        end
        
        if l then
            local n,e = --l()--
            pcall(l)
            if not n and type(e) == "string" then
                cwlog(e,"orange")
                self:addLog(string.format("&colors.peach %s", e))
                pl:cry(e,"peach")
            end
        end
                
        local s = self
        _G["self"] = nil
        local self = s
                
        text:setText("")
    end
    
    local submit = gooi.newButton({text="submit"}):onRelease(doSubmit)
    debug:add(submit)
    
    self.debugPanel = debug
    submit.draw = null
    -- submit.drawSpecifics = null
    text.draw = null
    text.drajwSpecifics = null
end

function Map:getCavern() 
    if 1 then return self:getLake(true) end
    
    local caveSize = {10, 10, 10, 16, 12, 20}
    local caveH = 1--{1,2,.5,1.5}
    local caveH2 = {3,1,1,1,2,.5,1.5}
    
    
    local tilesCount, oCount = "",""
    for xxx = 1,2 do
        -- lake
        local t
        local w = getValue(caveSize)--10--20
        local r = getValue(self.rooms)
        local xw = r.minTileX
        local yw = r.minTileY
        local allTiles, map = {}, {}
        local allSpacedTiles = {}
    
        local function rmake(x, y,v)
            local xs = x + xw
            local sy = y + yw
            local tt = self:getTile(t._x+x-w/2, t._y+y-w/2) assert(v==1 or v==0, v)--self:getTile(x,y)
            local x, y = tt and tt._x, tt and tt._y
            if v == 0 and tt and not tt.edge then
                if not tt.solid then
                    allSpacedTiles[#allSpacedTiles+1] = tt
                end
            
                allTiles[#allTiles+1] = tt
                map[x] = map[x] or {}
                map[x][y] = {solid=true}
                map[tt] = true
            end
        end
    
        local function make(x, y, v)
            local tt = self:getTile(t._x+x-w/2, t._y+y-w/2) assert(v==1 or v==0, v)
            if tt and v==0 and not tt.edge and not tt.keepSolid then
                tt.solid = false tt.water = 1 tt.debug = 1 tt.__draw=nil
            end
        end
        t = getValue(self.rooms)--self:getRandomSpaceTile()
        if 1 then-- not t.door do
            didDoor = math.random() > .6 
            local nm = 0
            t = didDoor and getValue(self.doors) or  t:getTile(t._x+math.floor(t.w/2)*nm, t._y+math.floor(t.h/2)*nm)--(self.doors)--self:getRandomSpaceTile()
        end
        local r = toybox.rot().Map.Brogue(w, math.floor(w*getValue(caveH2)), {
            caveChance = 1,--z==2 and 1 or 0,
            cavePasstes = 4,
            --maxRooms = 20, minRooms=12,
            roomWidth = {4,8},
           -- maxRooms = 11
           minRooms=0,maxRooms=0,
        
           -- corridorWidth = {3,6}
        })
        if maps[z] == "Cellular" then
                r:randomize(.55)--floorProb
        end
    
        for x = 1, 1 do
            r:create(rmake)
        end
        local tm = self:getRandomSpaceTile()
        local count = 100
        while map[tm] do
            log("map tm cavern while")
            tm = self:getRandomSpaceTile()
            count = count - 1
            if count < 0 then
                return
            end
        end
    
        --local tiles,q,con = floodFill(tm, map)
        if true then--#tiles >= (#spacedTiles-#allSpacedTiles) or con then
            for x = 1, #allTiles do
                local t = allTiles[x]
                local tile = t--[1]
                if nil and t[2] == 1 then
                   tile.debgug=1-- self:solidify(tile)
                else --tile.water=1
                    mmm:clear(tile) --tile.debug=1
                end
            end
    
           -- break
        end
    end
end

function Map:getLake(pit)
    local done
    local lava = pit == 'lava'
    if lava then pit = nil end
    pit = pit or false
    local spacedTiles = {}
    local storedTile = {}
    for x, i in ipairs(self.allTiles) do
        if not i.solid and not storedTile[i] then
            spacedTiles[#spacedTiles+1] = i
            storedTile[i] = true
        end
    end
    
    local tilesCount, oCount = "",""
    
    for xxx = 1,(PIG and 20 or 10) do
        -- lake
        local t
        local w = math.floor(self.digW/(math.random(19,28)/10))-- 20--getValue(caveSize)--20
        local r = getValue(self.rooms)
        local xw = r.minTileX
        local yw = r.minTileY
        local allTiles, map = {}, {}
        local allSpacedTiles = {}
        
        log("Trying lake "..xxx)
    
        local function rmake(x, y,v)
            local xs = x + xw
            local sy = y + yw
            local tt = self:getTile(xs,sy)--t._x+x-w/2, t._y+y-w/2) assert(v==1 or v==0, v)--self:getTile(x,y)
            local x, y = tt and tt._x, tt and tt._y
            log("ttyingzclz tile "..tostring(tt)..","..tostring(v)..tostring(tt and tt.edge))
            if (v == 0) and tt and not tt.edge then--and not tt.isCorridor then
    log("yah")
                --[[local tm = self:getRandomSpaceTile()
                local mmap = lume.copy(map)
                mmap[x] = mmap[x] or {}
                mmap[x][y] = {solid=true}
                mmap[tt] = true
                while mmap[tm] do
                    tm = self:getRandomSpaceTile()
                end
                local tiles,q,con = floodFill(tm, mmap)]]
                if true or #tiles >= (#spacedTiles-#allSpacedTiles) or con then
    
                if not tt.solid then
                    allSpacedTiles[#allSpacedTiles+1] = tt
                end
            
                allTiles[#allTiles+1] = tt
                tt.doWater = true
                map[x] = map[x] or {}
                map[x][y] = {solid=true}
                map[tt] = true else log("[LAKE NOT GEN] nope")
                end
            elseif tt then
                map[x] = map[x] or {}
                map[x][y] = tt
            end
        end
    
        local function make(x, y, v)
            local tt = self:getTile(t._x+x-w/2, t._y+y-w/2) assert(v==1 or v==0, v)
            if tt and v==0 and not tt.edge and not tt.keepSolid then
                tt.solid = false tt.water = 1 --tt.debug = 1
                tt.__draw=nil
            end
        end
    
        t = getValue(self.rooms)--self:getRandomSpaceTile()
        if 1 then-- not t.door do
            t = t:getTile(t._x+math.floor(t.w/2), t._y+math.floor(t.h/2))--(self.doors)--self:getRandomSpaceTile()
        end
    
        local r = toybox.rot().Map.Brogue(w, math.floor(w*getValue(1 or caveH)), {
            caveChance = 1,--z==2 and 1 or 0,
            cavePasstes = 4,
            --maxRooms = 20, minRooms=12,
            roomWidth = {4,8},
           -- maxRooms = 11
           minRooms=0,maxRooms=0,
            
           -- corridorWidth = {3,6}
        })
        if maps[z] == "Cellular" then
            r:randomize(.55)--floorProb
        end
    
        for x = 1, 1 do
            r:create(rmake)
        end
        local tm = self:getRandomSpaceTile()
        local count = 100
        while map[tm] do
            log(" Map tm yah while")
            tm = self:getRandomSpaceTile()
            count = count -1
            if count < 0 then
                return
            end
        end
    
        local tiles,q,con = floodFill(tm, map)
        
        -- if number of remaining tiles caught in floodfill is bigger(?) or equal to
        -- the tiles untouched by lake gen then continue because map still has connectivity
        
        if #allTiles>1 and (#tiles*(PIG and 2 or 1) >= (#spacedTiles-#allSpacedTiles) or  con) -- or true
        then --[[elseif true then --error(#tiles..", Tiles total: "..#spacedTiles..", Tiles used: "..#allSpacedTiles)
            for x, tile in ipairs(spacedTiles) do assert(not tile.kkj) tile.kkj = true
                tile.__draw = function(self)
                    local r, g, b, a = set_color(colors.yellow)
                    draw_rect("fill", self.x, self.y, self.w, self.h)
                    set_color(r, g, b, a)
                end
            end
            for x, tile in ipairs(tiles) do tile.rr=4
                tile.__draw = function(self)
                    local r, g, b, a = set_color(colors.pink)
                    draw_rect("fill", self.x, self.y, self.w, self.h)
                    set_color(r, g, b, a)
                end
            end
            for x, tile in ipairs(allSpacedTiles) do-- if tile.rr then error() end
                tile.__draw = function(self)
                    local r, g, b, a = set_color(colors.lime)
                    draw_rect("fill", self.x, self.y, self.w, self.h)
                    set_color(r, g, b, a)
                end
            end
            
            else]]
            log("yes lake)")
            local rooms = {}
            for x = 1, #allTiles do
                local t = allTiles[x]
                local tile = t--[1]
                if nil and t[2] == 1 then
                    tile.debgug=1-- self:solidify(tile)
                else
                    local isDeep = true
                    for xx = 1, math.random()>.6 and 3 or 2 do
                        for i = 1, 4 do
                            local d = dirs4[i]
                            local tt = self:getTile(t._x+d[1]*xx, t._y+d[2]*xx)
                            if tt and (not tt.doWater) and not tt.solid then
                                isDeep = false
                                break
                            end
                        end
                    
                        if not isDeep then
                            break
                        end
                    end
                    
                    rooms[tile.roomData] = (rooms[tile.roomData] or 0)+1
                
                    if pit then
                        tile.chasm = true
                    else
                        tile:addWater(nil, nil, true, isDeep, nil, lava)
                        tile.deepWater = isDeep
                    end
                    
                    mmm:clear(tile) -- tile.debug=1
                end
            end
            
            for room, x in pairs(rooms) do warn("Yes "..x.."/"..(#room.allTiles*.7))
                if not room.roomTypes then
                    -- error(inspect(room,1))
                end
                room.roomTypes = room.roomTypes or {}
                room.roomTypes.hasWater = true
                if x >= (#room.allTiles*.7) then
                    warn(tostring(lume.remove(self.rooms, room)).."!")
                end
            end
                
            
            done = done and 1 or true
        
            if true then break end
        
            ---- Bah Bah Black Sheep ... ----
        
            spacedTiles = {}
            
            for x, i in ipairs(self.allTiles) do
                if not i.solid and not i.water then
                    spacedTiles[#spacedTiles+1] = i
                end
            end
        end
    
        tilesCount = #tiles
        oCount = (#spacedTiles-#allSpacedTiles)
    
    end
    
    return done, oCount, tilesCount
end


function Map:setCameraTarget(t)
    self.cameraTarget = t
    self:updateCamera()
end

function Map:updateCamera()
    local t = self.cameraTarget
    if t then
        self.cameraMan.x, self.cameraMan.y = t.x, (t.ogy or t.y)
    end
    
    --self:_set_target(self.cameraMan)
    self.cameraMan.x = self.cameraMan.x - self.inventoryPanel.w
    self.camera.scale = (self.cameraMan.scale or self.camera.scale)
end

function Map:getRandomUnseenSpaceTile()

    local emptyTiles = lume.copy(self.OG_emptyTiles or self:getSpaceTiles())

    -- tile should be unseen
    local count = 4
    local tile
    
    for x = 1, #emptyTiles do
        tile = lume.eliminate(emptyTiles)
        if tile and not tile:canBeSeen() then
            break
        end
    end
    
    return tile
end
    
function Map:checkEvents(time)
    if not self.eventTimers then
        return
    end
    
    self._eventTime = self._eventTime - time
    
    if self.eventTimers and self._eventTime <= 0 then
        self._eventTime = getValue(self.eventTimers[getWeight(self.eventTimers)].timer)
        
        self:doPigSpawn()
        self:spawnLoreNotes()
        
        local event = getWeight(self.events)
        if event then
            local emptyTiles = lume.copy(self.OG_emptyTiles)
            
            -- attempts 20 times (only needs/wants one success)
            for x = 1, 20 do
                -- tile should be unseen
                local count = 4
                local tile
                -- attempts to give reward 10 times (only needs 4 success)
                for x = 1, 10 do
                    tile = lume.eliminate(emptyTiles)
                    if tile and not tile:canBeSeen() then
                        -- this tile is acceptable
                        spawnImportantItem(tile, 1)
                        if count >= 4 and math.random()>.4 then
                            break
                        end
                    
                    -- tiles are done
                    elseif not tile then
                        break
                    end
                end
                
                local ev = PIG_DATA.events[event]
                assert(ev, event)
                if ev.action(tile, self) then
                    local txt = ev.text
                    if txt then
                        -- check for exclusive texts
                        self:addLog(getValue(txt.basic))
                    end
                    
                    break
                end
            end
        end
    end
end

function Map:closeInventory(noTween)
    -- if true then return end
    log("closing inv")
    
    if not self.inventoryIsOpen then
        log("opening first, so it can be closed.")
        self:openInventory(nil, true)
    end
    
    if self.choosingItem and not self.choosingItem.noCancelPrompt then
        if self.choosingItem.canCancel then
            gooi.dialog({
                text = self.choosingItem.cancelText,
                divide = 1.5,
                ok = function()
                
                    self.enchanting = false -- if enchanting
                    
                    self.choosingItem = nil
                    -- self:closeInventory()
                end
            })
        end
        
        return
    end
    
    if not noTween then
        self:tween_in_ui(self.quickslots, .4)
    end
    
    
    if self.cameraOffsetTweener then
        self.timer:cancel(self.cameraOffsetTweener)
    end
    
    self.cameraOffsetTweener = self.timer:tween(.4, self, {cameraOffset = 0}, "in-bounce")
    
    
    self.choosingItem = nil
    
    self.inventoryIsOpen = false
    
    self:tween_out_ui(self.inventoryPanel)
    self:after(.4, function()
        gooi.removeComponent(self.inventoryPanel)
        self.inventoryIsOpen = false
    
    
         gooi.addComponent(self.openInvButton)
    
    
        -- gooi.removeComponent(self.invRight)
        -- gooi.removeComponent(self.invLeft)
    end)
end


function Map:openInventory(skip, noTween)
    if self.player and self.player.died then
        return
    end
    
    if self.inventoryisOpen then
        self:closeInventory(true)
    end
    
    if not noTween then
        self:tween_out_ui(self.quickslots, .4)
    end
    
    if self.cameraOffsetTweener then
        self.timer:cancel(self.cameraOffsetTweener)
    end
    
    self.cameraOffsetTweener = self.timer:tween(.4, self, {cameraOffset = self.inventoryPanel.w}, "in-bounce")
    
    self.inventoryIsOpen = true
    if self.player then
        log("reload from open")
        self:reloadInventoryUI(self.inventoryUser or self.player)
    end
    
    -- gooi.addComponent(self.invRight)
    -- gooi.addComponent(self.invLeft)
    
     gooi.removeComponent(self.openInvButton)
    
    --self.inventoryPanel:rebuild()
    
    gooi.addComponent(self.inventoryPanel)-- error(self.inventoryPanel.w..","..self.inventoryPanel.h)
    
    -- so left/right buttons look well
    if not skip and self.player then
        self:reloadInventoryUI(self.inventoryUser or self.player)
    end
    
    --invp.ogx 
    
    self:tween_in_ui(self.inventoryPanel, .4)
end


function Map:setInfo(txt)
    self.infoText:newText(txt)
end

local logTime = .8

function Map:newLog(color, txt, skip)
    local l = lume.copy(self.logs)
    local logLen = skip == 0 and 0 or #self.logs
    
    local reduceLog = (not skip and logLen > 0) and function()
        self.doingLog = self.doingLog - 1
    end
    
    local my = 0
    
    for x = 1, skip and 0 or logLen do
        local item = l[x]
        self.logs[x+1] = item
        
        if item.tww then
            game.timer:cancel(item.tww)
            item.y = item.ogy or item.y
            item.tww = nil
        end
        
        local y = -lg.getFont(l[x].font):getHeight()+item.y-5
        item.nh = lg.getFont(l[x].font):getHeight()
        
        -- assert(item.h==item.nh,item.h..","..item.nh)
        
        my = my + item.h - 18
        
        local func = x == #self.logs and function()
            self.doingLog = self.doingLog - 1
            return newLog(color, txt, true)
        end or reduceLog
        
        if item.tween then
            -- self.timer:cancel(item.tween)
        end
        
        
        item.tween = game.timer:tween(logTime, item, {y=y}, "out-quad", func)
        item.alpha = (7-x)/4
    end
    
    self.logs[25] = nil
    
    local l = self.logs[2]
    local ww = W()*.5
    local ws = (H()/25)*2
    local wx = ws-10+(W()*.2)+10
    ww = W() - wx - self.inventoryPanel.w - 12
    local h = H()/25
    local yy = 20+h+5+h*3/4+75+my
    local xx = (self.pljayer and self.player.lifebar and self.player.lifebar.x+self.player.lifebar.w+10) or wx
    local yyt = Sentence:new({
        x = (self.pljayer and self.player.lifebar and self.player.lifebar.x+self.player.lifebar.w+10) or wx,
        y = yy or l and (l.y+5) or (10+30),
        w = ww, instant=true
    })
    
    yyt.alpha = 0
    
    yyt.alpha=.4
    yyt.x = W()/2-yyt.w/2
    yyt.y=H()/2
    --logTime=logTime*2
    yyt.tween = game.timer:tween(logTime, yyt, {y=(yy-75), x=xx, alpha=1}, "out-quad", func)
    
    yyt.color = color or yyt.color
    
    local yyyt = yyt -- for return
    
    self.logs[1] = yyt
    
    local i = yyt
    self.doingLog = (self.doingLog or 0)+1
    i:newText(txt)
    
    ---
    local yy = H()-80+(NO_QUICKSLOTS and self.quickslots.h or 0)--20+h+5+h*3/4+75+my
    local xx = (self.pljayer and self.player.lifebar and self.player.lifebar.x+self.player.lifebar.w+10) or wx-3
    local yyt = Sentence:new({
        x = (self.pljayer and self.player.lifebar and self.player.lifebar.x+self.player.lifebar.w+10) or wx-3,
        y = H()/2 or (yy-75)-100 or l and (l.y+5) or (10+30),
        w = ww, instant=true
    })
    
    yyt.alpha = 0
    yyt.color = color or yyt.color
    
    self.specialLog = nil--yyt
    
    local i = yyt
    self.doingLog = (self.doingLog or 0)+1
    i:newText(txt)
    i:getWordClumps()
    yyt.tween = game.timer:tween(logTime, yyt, {y=(yy-75-yyt.h),x=xx, alpha=1}, "out-quad", func)
    
    
    return yyyt
end

function ppll() pl:addLog("Yes a really long &colors.yellow Very fun times but I regret it never before ~ lolololololololllloloo")
 end
 
function Map:scroll()
    if self.cover.scrolled or self.cover.notFree then
        return
    end
    
    local hh = 0
    local time = 1
    for x = 1, #self.logs do
        local l = self.logs[x]
        l.ogy = l.y
        l.oga = l.alpha
        hh = hh + (l.h>18 and l.h or 0) --assert(hh==0, hh..","..l.h)
        local il = lg.getFont(l.font):getHeight()
        
        if l.tween then
            game.timer:cancel(l.tween)
            l.tween = nil
        end
        
        l.tww = game.timer:tween(time, l, {y=H()-((il*2))*x+5*x-hh, alpha=1}, "in-quad")
    end
    
    
    
    local function canScroll()
        self.cover.notFree = false
        if #self.toAddLog > 0 then
            self:unscroll()
        end
    end
    self.cover.notFree = true
    
    game.timer:tween(time, self.cover, {y=0}, "in-quad", canScroll)
    self.cover.scrolled = true
end

function Map:unscroll(fast)
    
    if self.cover.notFree or not self.cover.scrolled then
        if not fast then
            return
        end
    end
    
    if self.cscroll then
        game.timer:cancel(self.cscroll)
        self.scroll = nil
    end
    
    local time = 1
    for x = 1, #self.logs do
        local l = self.logs[x]
        l.tww = game.timer:tween(fast and .01 or time, l, {y=l.ogy, alpha=l.oga}, "out-quad")
    end
    
    local function canScroll()
        self.cover.notFree = false
        for x = 1, #self.toAddLog do
            local t = self.toAddLog[x]
            self:addLog(t[1], t[2], t[3])
        end
        self.toAddLog = {}
    end
    self.cover.notFree = true
    
    self.cscroll = game.timer:tween(fast and .01 or time, self.cover, {y=-self.cover.h}, "out-quad", canScroll)
    self.cover.scrolled = false
end

local secondPerson = {
    was = "were",
    fails = "fail",
    is = "are",
    has = "have",
    ["now does"] = "now do"
}

function Map:fixText(txt)
    local m = txt:sub(1, 3)
    if m == "you" or m == "You" or true then
        local words = {}
        -- previous word
        local pWord = nil
        local newTxt = ""--title
        
        local count = 0
        
        for word, space in txt:gmatch("(%S+)(%s*)") do
            count = count + 1
            
            if pWord and (pWord == "you" or pWord == "You") and count <= 2 then
                local nword = secondPerson[word]
                if not nword and word:sub(-1,-1) == "s" then
                    nword = word:sub(1,-2)
                end
                
                word = nword or word
            end
            
            pWord = word
            
            newTxt = string.format("%s%s%s", newTxt, word, space)
        end
        
        txt = newTxt
            
    end
    
    return txt
end

function Map:addLog(txt, color, skip)
    if not self.player then
        return
    end
    
    if type(txt) ~= "string" then
        txt = tostring(txt)
    end
    
    local m = txt:sub(1, 3)
    if m == "you" or m == "You" or true then
        local words = {}
        -- previous word
        local pWord = nil
        local newTxt = ""--title
        
        local count = 0
        
        for word, space in txt:gmatch("(%S+)(%s*)") do
            count = count + 1
            
            if pWord and (pWord == "you" or pWord == "You") and count <= 2 then
                local nword = secondPerson[word]
                if not nword and word:sub(-1,-1) == "s" then
                    nword = word:sub(1,-2)
                end
                
                word = nword or word
            end
            
            pWord = word
            
            newTxt = string.format("%s%s%s", newTxt, word, space)
        end
        
        txt = newTxt
            
    end
    
    if self.doingLog and self.doingLog > 0 and not skip then
        local func = function()
            self:addLog(txt, color, true)
        end
        return self:after(self.doingLog*logTime*1.2, func)
    end
    
    if self.cover.scrolled then
        self:unscroll()
        self.toAddLog[#self.toAddLog+1] = {txt, color, true}
        return
    end
    
    -- self.player:speak(txt)
    
    log(string.format("[GAME LOG] %s", txt))
    local i = self:newLog(color, txt)
    -- i:newText(txt)
end

function Map:addText(...)
    return self:addLog(...)
end

function kstone()
    return toybox.room:spawn("kobold",pl.tile):addSkill("stoneThrow")
end

function Map:startCoroutine(func, ...)
    log("coroutine started")
    func()
    -- self.coroutine = coroutine.create(func)
    -- coroutine.resume(self.coroutine, ...)
end

function Map:yieldCoroutine(...)
    log("coroutine yielded!")
    -- coroutine.yield(...)
end

function Map:updateCoroutine(dt)
    if self.coroutine then
        if coroutine.status(self.coroutine) == "suspended" then
            local resumed = coroutine.resume(self.coroutine)
            if not resumed then
                self.coroutine = nil
                log("coroutine done")
            else
                log("coroutine resumed")
            end
        end
    end
end

function Map:itemPopUp(data, fake)
    if self.popUpItem == data then-- and self.popUp.data == data and not fake then
        return
    end
    
    self:removePopUp()
    log("POP UP")
    
    -- was popup caused by hovering over something?
    self.mousePopUp = false
    
    local gr = gooi.currentGroup
    self.currentItem = data
    
    self.popUpItem = data
    
    if not fake then
        self.inventoryUser:wieldItem(data)
    end
    
    local nn = 1.2
    local w, h = (W()*nn)/2.4, ((H()*nn)/3)*(data.shopkeeper and 1.5 or 1.25 or 1)
    
    local row = 6
    local v = 2
    local g = gooi.newPanel({
        x = lume.min(self.quickslots.x, self.quickslots.ogx) or self.inventoryPanel.x-w-10 or (W()/2-w/2), y = 0+((H()*nn)/3)/2,--H()/2-h/2,
        w = w, h = h,
        layout = "grid 6x10",
        padding = 7,
        paddingY = 2,
        group = gr
    }):
    setRowspan(1,1,row):-- -1
    setColspan(1,1,10):
    setColspan(row,2,v):
    setColspan(row,4,v):
    setColspan(row,6,v):
    setColspan(row,8,v)
    
    g.bgColor = {0,0,0,.7}
    
    g.opaque = true
    
    local info = gooi.newLabel({
        text = string.format("%s\n \n%s", data.getName and data:getName() or data.name, data.getInfo and data:getInfo() or data.info or "An item")
    }):left()
    info.yOffset = 2
    
    local ch = self.choosingItem
    
    if ch and ch.noPrompt then
        self.chooseItemFunc()
        gooi.removeComponent(g)
        gooi.removeComponent(info)
        return
    end
    
    local use = ch and not fake and gooi.newButton({
            text = string.format("%s", self.choosingItem.text or "choose")
        }):onRelease(self.chooseItemFunc) or
    
        not fake and gooi.newButton({
            text = data.useText or "use"
        }):onRelease(self.useFunc)
        
    if ch and use then
        use.fgColor = ch.fgColor or use.fgColor
        use.bgColor = ch.bgColor or use.bgColor
    end
        
    local drop = not ch and not fake and gooi.newButton({
        text = "drop"
    }):onRelease(self.dropFunc)
    
    local throw = not ch and not fake and gooi.newButton({
        text = "throw"
    }):onRelease(self.throwFunc)
    
    local cancelFunc = function()
        self:removePopUp()
    end
    
    local cancel = gooi.newButton({
        text = "cancel"
    }):onRelease(cancelFunc)
    
    g:add(info)
    
    if use then
        g:add(use,row,2)
    end
    
    if drop then
        g:add(drop,row,4)
    end
    
    if throw then
        g:add(throw,row,6)
    end

    g:add(cancel,row,8)
        
    if data.shopkeeper and not fake then
        local buyFunc = function()
            local cr = self.inventoryUser
            local item =self.currentItem
            
            if (cr.gold or 0) >= (item.price or 1) then
                item.shopkeeper = nil
                cr.gold = (cr.gold or 0) - (item.price or 1)
                cr:addItem(item)
                self:removePopUp()
            else
                self:addLog("You don't have enough gold!", "red")
                self.camera:shake(15,.5,15)
            end
        end
        
        local buy = gooi.newButton({
            text = "buy"
        }):onRelease(buyFunc)
        
        g:add(buy,row,5)--+1,5)
        buy.x = cancel.x
        buy.w = use.w
    end
    
    self.popUp = g
    g.aboutItems = true
    g.data = data
end

function Map:removePopUp()
    self.buying = false
    self.popUpItem = nil
    
    self.mousePopUp = false
    
    if not self.popUp then
        return
    end
    
    if self.popUp.aboutItems then
        log("reload inv from popup")
        self:reloadInventoryUI()
    end
    
    gooi.removeComponent(self.popUp)
    self.popUp = nil
end
    
local function sortItemData(a, b)
    local am = (INV_DEPTH[a.itemType] or 10)+(a.equipped and 121 or 0)+(a.count or 1)/100
    local bm = (INV_DEPTH[b.itemType] or 10)+(b.equipped and 121 or 0)+(b.count or 1)/100
    
    return am>bm
end

function rmm() for x=1,10 do pl:removeItem(getValue(pl.allItems)) end end


local invB_postDraw = function(invB)
                local item = invB.item
                local angg = item.angle
                local yoff = item.offset_y
                local sp = item.sprite
                local source = item.source
                
                if sp then
                    item.sprite = nil
                    item.source = sp:getCurrentAnimation().frames[1]
                end
                
                item.offset_y = item.og_offset_y or 0
                
                item:redraw(invB.x, invB.y, aaaa or 0, invB.w, invB.w*(item.h/item.w))
                item.angle = angg
                item.offset_y = yoff
                
                item.sprite = sp
                item.source = source
end

function Map:reloadInventoryUI(user, page)
    log("RELOADING UI")
    -- p:reloadinventoryuii
    self.inventoryUser = user or self.inventoryUser or self.player or error("No user")
    user = self.inventoryUser
    if not user then return end 
    table.sort(user.inventoryItems, sortItemData)
    
    --self.inventoryButton:setText(string.format("Inventory (room for %s more)", user.inventorySpace))
    
    self.maxItems = #user.inventoryItems
    self.invPages = math.floor(self.maxItems/14)
    if ((self.maxItems/14)-self.invPages) ~= 0 then
        self.invPages = self.invPages + 1
    end
    
    local ogp = page or "-"
    self.lastPage = page or self.lastPage
    
    local last = self.lastPage or "? "
    
    local page = page or self.lastPage or 1
    
    
    self.lastPage = page
    self.currentInvPage = page or 1
    
    self.invLeft.enabled = true
    self.invRight.enabled = true
    self.invLeft.visible = true
    self.invRight.visible = true
    
    if page == 1 then
        self.invLeft.enabled = false
        -- self.invLeft.visible = false
    end
    
    if page == self.invPages then
        self.invRight.enabled = false
        -- self.invRight.visible = false
    end
    
    local skip, old
    local nxt = 0
    local invBy = 0
    local bck = 0
    local count = 0
    
    local items = {}
    local page = 0
    local pages = {}
    
    local nxtt = 0
    
    local mCount = lume.max(#user.inventoryItems, 500)

    while count < #user.inventoryItems do
    
    mCount = mCount-1
    if mCount <= 0 then
        break
    end
    
    page = page + 1
    bck = 0
    
    local s = user.inventorySpace
    local c = s<5 and "red @" or s<=10 and "orange" or s>=30 and "lime" or "white"
    self.inventorySpace = self.inventorySpace or oldMap and oldMap.inventorySpace
    if not self.inventorySpace then
        return
    end
    self.inventorySpace:setText(self.enchanting and "&colors.cyan Pick an item to upgrade..." or s <= 0 and "&colors.red Your pack is full" or string.format("(room for &colors.%s %s ~ more item%s)", c, user.inventorySpace, user.inventorySpace == 1 and "" or "s"))
    
    local allow = self.choosingItem and self.choosingItem.allow
    
    local x, xx = 1, 1
    -- while x <= #self.inventoryUI do--
    for x = 1, #self.inventoryUI do
        local invB = self.inventoryUI[x]
        local i = not skip and user.inventoryItems[x+nxtt]--(x+nxt)+(15*(page-1))]
        
        log(" -- item .."..(i and i.name or "nil"))
       -- if skip then invBy = invBy + 10 end-- invB.h/3 end
        invB.oy = invB.oy or invB.y
        invB.fgColor = self.enchanting and colors.cyan or nil
        --invB.y = invB.oy+invBy
        
        skip = false
        
        if allow and not allow[i] and i then
            invB.enabled = false
            invB.fgColor = {.5,.5,.5,1}
        else
            invB.enabled = true
            invB.fgColor = {1,1,1,1}
        end
        
        if i then
            if old and old.itemType ~= i.itemType and not i.equipped then
               -- skip = true
                bck = bck + 1
                items[x+bck-1] = i.itemType
                
                if lume.max(bck+x,#items)>=#self.inventoryUI then
                    break
                end
                --nxt = nxt - 1
            end
            old = i
            count = count + 1
        end
        
        items[x+bck] = i and i or "?"

        if true then
            -- x = x + 1
        end
        
        if #items == #self.inventoryUI then break end
    end
    pages[page] = items
    items = {}
    nxtt = count
    end
    
    --local nn = {}
    --for x, ii in ipairs(user.inventoryItems) do nn[x]  = ii.name end
    
    --if nmm then error(inspect(nn).."\n"..inspect(pages)..#pages[1]..","..#pages[2]) end
    
    
    --inventoryui =
    
    self.invPages = page
    
    page = self.lastPage
    
    if page > (self.invPages) then page = self.invPages end
    self.currentInvPage = page
    
    local page = self.currentInvPage
    
    self.invLeft.enabled = true
    self.invRight.enabled = true
    self.invLeft.visible = true
    self.invRight.visible = true
    
    if page == 1 then
        self.invLeft.enabled = false
        -- self.invLeft.visible = false
    end
    
    if page == self.invPages then
        self.invRight.enabled = false
        -- self.invRight.visible = false
    end
    log(page.." is page out of "..self.invPages)
    local items = pages[self.currentInvPage] or {}
    local nxt = 0
    local x = 0
    local count = 0
    
    self.inventoryPanel.borderColor = self.choosingItem and self.choosingItem.color or self.enchanting and colors.cyan or nil
    
    
    while true do
    --for x = 1, #self.inventoryUI do
        x = x+1
        local invB = self.inventoryUI[x+nxt]
        if not invB or count>500 then break end
        count = count+1
        
        invB.opaque = true
        
        local i = items[x]--user.inventoryItems[(x+nxt)+(15*(page-1))]
        
        invB.oy = invB.oy or invB.y
        -- invB.y = invB.oy + invBy
        invB.borderColor = self.choosingItem and self.choosingItem.color
        
        log(tostring(i)..":"..x.."/"..(#self.inventoryUI).."-"..nxt)
        
        if type(i) == "table" then
            invB.data = user.inventory[i]
            local item = user.inventory[i][1]
            invB:setText(string.format("%s%s%s%s%s%s",
            
                self.choosingItem and self.choosingItem.textModifier
                or self.enchanting and "&colors.cyan " or "",
                    
                item:getDurabilityTitle(),
                
                self.choosingItem and self.choosingItem.textModifier
                or self.enchanting and "&colors.cyan " or "",
                
                item:getName(),
                
                item.shopkeeper and
                string.format(" &colors.gold - costs G%s ~", item.price) or "",
                
                (#(user.inventory[item.data] or {})<2 and not item.nil___differentFromStack) and ""
                or string.format("\n [x%s]", #(invB.data or user.inventory[item.data]
                or {}))
            ))
            
            invB:setText("")
            invB.item = item
            invB.postDraw = invB_postDraw
            
            if (#user.inventory[item.data]<2 and not item.nil___differentFromStack) then
                invB.yOffset = invB.og_yOffset
            else
                invB.yOffset = 0
            end
            invB.panel.s:setText(string.format("(%s)",#invB.data*item.space))
            
            if old and old.itemType ~= i.itemType then
                skip = true
                --nxt = nxt-1
            end
            
            old = i
        
        elseif type(i) == "string" and i ~= "?" then
            invB.opaque = false
            invB:setText("")
            invB.data = nil
            invBy = invBy+invB.h/1.7
            nxt = nxt - 1
        else
            invB.opaque = false
            invB:setText("")
            invB.data = nil
            
        end
    end
end

function Map:shopPopup(cr, item)

    self:removePopUp()
    
    local data = item
    
    local gr = gooi.currentGroup
    self.currentItem = data
    
    -- self.inventoryUser:wieldItem(data)
    
    local nn = 1.2
    local w, h = (W()*nn)/2.4, (H()*nn)/4*1.5
    
    local row = 5
    local v = 2
    local g = gooi.newPanel({
        x = lume.min(self.quickslots.x, self.quickslots.ogx) or self.inventoryPanel.x-w-10 or (W()/2-w/2), y = 0+((H()*nn)/4)/2,--H()/2-h/2,
        w = w, h = h,
        layout = "grid 6x10",
        padding = 7,
        paddingY = 2,
        group = gr
    }):
    setRowspan(1,1,row):-- -1
    setColspan(1,1,10):
    setColspan(row,2,v):
    setColspan(row,4,v):
    setColspan(row,6,v):
    setColspan(row,8,v)
    
    g.opaque = true
    
    local info = gooi.newLabel({
        text = string.format("%s\n \n%s\n \nThis %s is for sale at &colors.gold %s gold", data.name, data.info or "An item",data.type,data.price)
    }):left()
    info.yOffset = 2
    self.buying = true
    
    -- shopkeeper
    
    local function buyFunc()
        if (cr.gold or 0) >= (item.price or 1) then
            item.shopkeeper = nil
            cr.gold = (cr.gold or 0) - (item.price or 1)
            cr:addItem(item)
        else
            self:addLog("You don't have enough gold!", "red")
        end
        self:removePopUp()
    end
    
    local function pickupFunc()
        cr:addItem(item)
        self:removePopUp()
    end
    
    local buy = gooi.newButton({
            text = "buy"
        }):onRelease(buyFunc)
        
    local pickup = gooi.newButton({
        text = "pickup"
    }):onRelease(pickupFunc)

    local cancelFunc = function()
        self:removePopUp()
    end
    
    local cancel = gooi.newButton({
        text = "cancel"
    }):onRelease(cancelFunc)
    
    g:add(info)
    
    g:add(buy,row,2)
    g:add(pickup,row,6)
    pickup.x = pickup.x - pickup.w/2
    g:add(cancel,row,8)
    
    self.popUp = g
end


function Map:pedestalPopup(cr, item)

    self:removePopUp()
    
    local data = item
    
    local gr = gooi.currentGroup
    self.currentItem = data

    
    local nn = 1.2
    local w, h = (W()*nn)/2.4, (H()*nn)/4*1.4
    
    local row = 5
    local v = 2
    local g = gooi.newPanel({
        x = lume.min(self.quickslots.x, self.quickslots.ogx) or self.inventoryPanel.x-w-10 or (W()/2-w/2), y = 0+h/2,--H()/2-h/2,
        w = w, h = h,
        layout = "grid 6x10",
        padding = 7,
        paddingY = 2,
        group = gr
    }):
    setRowspan(1,1,row):-- -1
    setColspan(1,1,10):
    setColspan(row,2,v):
    setColspan(row,4,v):
    setColspan(row,6,v):
    setColspan(row,8,v)
    
    g.opaque = true
    
    local info = gooi.newLabel({
        text = string.format("%s\n \n%s\n \nThis %s is sitting on a pedestal.", data.name, data.getInfo and data:getInfo() or data.info or "An item",data.type)
    }):left()
    info.yOffset = 2
    self.buying = true
    
    
    local function pickupFunc()
        cr:addItem(item)
        self:removePopUp()
    end
        
    local pickup = gooi.newButton({
        text = "pickup"
    }):onRelease(pickupFunc)

    local cancelFunc = function()
        self:removePopUp()
    end
    
    local cancel = gooi.newButton({
        text = "cancel"
    }):onRelease(cancelFunc)
    
    g:add(info)

    g:add(pickup,row,2)
    pickup.x = pickup.x - pickup.w/2
    g:add(cancel,row,8)
    
    self.popUp = g
end

function Map:addItemTo(cr, item)

    if item.tile and item.tile.pedestalLocked and (not item.tile.pedestalLocked.unlocked) and item.tilePedestal == item.tile then
        if cr.isPlayer then
            self:addLog(string.format("%s is @ stuck ~ to the pedestal", item.title))
        end
        return
    end
    
    if item.tile and item.tile.pedestalLocked and cr.isPlayer and item.tilePedestal == item.tile then
        return self:pedestalPopup(cr, item)
    end
    
    if item.shopkeeper and item.shopkeeper.isAlreadyDead then
        item.shopkeeper = nil
    end
    
    if item.shopkeeper and cr.isPlayer then
        return self:shopPopup(cr, item)
    end
    
    return cr:addItem(item)
end

local checkDirs = {
    {1,0},{-1,0},{0,-1},{0,1},
    {1,-1},{1,1},{-1,-1},{-1,1}
}

function getEmptySpaceForClone(cr, source, done)
    local source = source or cr
    local done = done or {}
    local tile = cr.tile
    for x = 1, 8 do
        local c = checkDirs[x]
        local t = cr.room:getTile(tile._x+c[1],tile._y+c[2])
        
        if t and t:isFree() then
            return t
        end
        
        local unit = t and ((t.unit and t.unit.cloneID == source.cloneID and t.unit) or (t.unit == source.attacker and t.unit) or (t.unit and t.unit.team == source.team))
        if unit and not done[unit] then
            done[unit] = true
            local t2 = getEmptySpaceForClone(unit, source, done)
            if t2 then
                return t2
            end
        end
    end
end

function Map:getFreeTileAround(tile, check, check2)
    local check = check or "unit"
    local check2 = check2 or "gibberishGo goonsndksjsjsje"
    
    if true then
        local newTile
        for x = 1, 8 do
            local c = checkDirs[x]
            local t = self:getTile(tile._x+c[1],tile._y+c[2])
            if t and (not t[check] or t[check].noPickup) and not t:isSolid() and not t[check2] then
                newTile = t
                break
            end
        end
        if not newTile then
            for x = 1, 8 do
                local c = checkDirs[x]
                local t = self:getTile(tile._x+c[1],tile._y+c[2])
                if t then
                    for y = 1, 8 do
                        local cc = checkDirs[y]
                        local tt = self:getTile(t._x+cc[1], t._y+cc[2])
                        if tt and (not tt[check] or tt[check].noPickup) and not tt:isSolid() and not tt[check2] then
                            newTile = tt
                            break
                        end
                    end
                    if newTile then
                        break
                    end
                end
            end
        end
        
        if not newTile then
            return
        end
        
        return newTile
    end
end

function Map:spawnItem(item, tile, dropped, forcePosition, teleported)
    
    tile = tile or getValue(self.rooms):getRandomSpaceTile()
    local fresh
    
    if not tile then
        warn(string.format("[%s? DROPPED:%s IS REAL:%s] No tile!!!!!!!!!!!!!!", item.name or item.title or item._id, dropped, item.isEntity))
        return
    end

    if not item.isItem then
        fresh = true
        if not (items[item] or item) then
            error(inspect(item,2))
        end
        item = _G[(items[item] or item).class or "Item"]:new(items[item] or item)
    end
    
    if tile.item and (tile.item.isAnvil and #tile.item.mixes<2 or (tile.item.anvil and not tile.item.isFixing)) then
    
        if item.tile then
            item.tile = nil--.item = nil
        end
        return tile.item:onRecieve(item, dropped)
    end
    
    local dItem
    local user = item.user
    
    if dropped then
        item:onDrop(self.inventoryUser or user, self)
    end
        
    if tile.item and (tile.item.data == item.data and not item.data.noStack) and tile.item ~= item and not item.noPickup then
        log("[ITEM] ".. (item.name or "?") .. " item stacked!")
        tile.item.stack = (tile.item.stack or 1)+1
        self:destroy_instance(item)
        item.x, item.y = tile.x, tile.y
        return tile.item
    end
    
    
    if dropped == 10 and user and (tile.item and not tile.item.noPickup) and (true or user.inventorySpace>=tile.item.space) then
        user:addItem(tile.item)
    end
    
    if tile.takenPedestalItem == item then
        local pLock = tile.pLock
        self:addLog("You hear a clicking sound.")
        
        pLock.taken = nil
        pLock.unlocked = true
        tile.takenPedestalItem = nil
    elseif tile.takenPedestalItem then --stuck
        self:addLog("That Item doesn't belong there...")
    end
    
    if ((tile.item and tile.item ~= item and not tile.item.noPickup and not item.noPickup) or (tile.unit and item.unitBlocks) or tile.noItemsAllowed) and not forcePosition then
        
        local newTile = self:getFreeTileAround(tile, "item", item.unitBlocks and "unit")
        --assert(not item.isWall)
        if not newTile then
            if dropped then
                self:addLog(string.format("%s got forgotten by the world", item.name))
            end
            local problem = (tile.item and not tile.item.noPickup and tile.item) or 
              (tile.unit and item.unitBlocks and tile.unit)
            log("No space for item "..item.name.." due to "..(problem and problem.title or "?"))
            item:destroy()
            
            return problem
        end
        
        tile = newTile
    end
    
    if item.tile then
        item.tile.item = nil
    end
    
    
    item.onceOnGround = true
    
    if true then--not self.world:hasItem(item) then
        self:store_instance(item)
    end
    
    local x = tile.x - (item.w/2-tile.w/2)
    local y = tile.y - (item.h/2-tile.h/2)
    
    item:set_box(x,y,item.w, item.h)
    item.x, item.y = x,y
    item.debug = nil
    item.depth = (item.isPuff and DEPTHS.EFFECTS) or DEPTHS.ITEMS+love.timer.getTime()/100000
    tile.item = item
    item.tile = tile -- if item.remm then error(item.name) end
    
    if item.isWall then
        tile.hasWall = item
    end
    
    if true then -- not item.isFloor and not item.isWall then
        self.items[item] = item
    end
    
            
    if tile.pressurePlate and tile.pressurePlate.parent and self.currentTurn > 0 and not tile.unit then
        if not tile.pressurePlate.parent.silent then
            tile:addLog(string.format("A pressure plate clicks underneath %s...", item.title))
        end
        self.trapsToActivate[#self.trapsToActivate+1] = tile.pressurePlate.parent
        tile.toActivateTrap = true log("capa")
    end
    
    log(item.name.." spawned")
    
    local newTile = tile:getTileToTeleportTo(true)
    if newTile and not teleported then
        self:teleport(item, newTile)
    end
    
    if item.isCharm then
        self.charms = (self.charms or 0)+1
    end
    
    return item
end

function Map:destroyItem(item)
        
    if item.tile and item.tile.item == item then
        item.tile.item = nil
    end
    
    if item.tile and item.isWall then
        item.tile.hasWall = nil
    end
    
    item.isDestroyed = true
    
    if item.user and item.isCarried then
        item.user:removeItem(item, true)
        item.rrro = true
    end
    
    self:destroy_instance(item)
end

function listall(mmm) error(inspect(lume.keys(mmm or items))) end

function checkgooi()
    for x, i in pairs(gooi.components) do
        if i.x == 0 and i.y == 0 then
            return i
        end
    end
end

function Map:gameover()
    self:closeInventory()
    
    if true then
        loadSong(TUTORIAL and "quickjazz" or "game_over")
    end
    
    self.gameLost = true
    
    local g = gooi.currentGroup
    
    local pw = W()*.5
    local ph = H()*.4
    
    local p = gooi.newPanel({
        group = g,
        w = pw, h = ph,
        x = W()/2-pw/2, y = H()/2-ph/2,
        padding = 12,
        layout = "grid 4x3"
    })
    
    p.opaque = true
    
    -- p:debug()
    
    p:setColspan(1,1,3)
    p:setRowspan(2,1,2)
    p:setColspan(2,1,3)
    
    local mess = ""
    
    if self.player.tooScaredToMove then
        local secrets = game.secrets
        mess = string.format("\nThanks for playing the &colors.orange #demo @tutorial thingy ~ I made.\n%s",secrets < 1 and "(But you didn't find any secrets :P)" or secrets < 2 and "(There are still a few more secrets though)" or "Madness awaits...")
    else
        mess = math.random() >.5 and "\nWatch out for cracked walls..." or "\nStill a long way #@ to go..."
    end
    
    local orbsCollected = self.player.orbsCollected or 0
    
    local highestKills = gamedata.highestKills or 0
    local kills = #self.player.kills
    local highestGold = gamedata.highestGold or 0
    local gold = self.player.gold
    local longestTurns = gamedata.longestTurns or 0
    local turn = self.currentTurn
    
    game.goldTween = game.timer:tween(1.5, game:getData(), {gold=game:getData().gold+self.player.gold}, "in-quad")
    game.finalGold = game:getData().gold+self.player.gold
    
    game.goldPlus = 0
    game.goldPlusTween = game.timer:tween(1.5, game, {goldPlus=self.player.gold}, "in-quad")
    game.finalGoldPlus = self.player.gold
    
    local label = gooi.newLabel({text=self.isIntro and "The orbs ... got to ... get...@ &colors.cyan the orbs" or
string.format([[@&colors.crimson %s]],self:fixText(string.format("%s", self.player.deathText or "killed by a fall")))}):left()
    local label2 = gooi.newLabel({text=string.format([[&colors.gold @gold: %s %s~
kills: %s %s
turns: %s %s~
&colors.cyan orbs obtained: ~ %s/3
]], self.player.gold or "?", gold>highestGold and " &colors.gold (New Best!?) ~" or "", #self.player.kills, kills>highestKills and "  &colors.crimson (New Best!?) ~" or "", self.currentTurn, turn>longestTurns and "  &colors.lime (New Best!?) ~" or "", self.isIntro and 3 or orbsCollected)}):left() -- getQuote

    local function menuFunction(b)
        if not self.doneRestart then
            self.doneRestart = true
            -- self.player = nil
            game:set_room(TitleMenu:new({}))
        end
    end
    
    table.insert(gamedata.deaths, {
        gold = self.player.gold,
        kils = self.player.kills,
        deathText = self.player.deathText,
        turnsSurvived = self.currentTurn,
        timePlayed = self.timePlayed or 0,
        orbsCollected = orbsCollected
    })
    
    if self.isIntro then
        gamedata.hasDoneIntro = true
    end 
    
    if gold>highestGold then
        gamedata.highestGold = gold
    end
    
    if kills>highestKills then
        gamedata.highestKills = kills
    end
    
    if turn>longestTurns then
        gamedata.longestTurns = turn
    end
    
    
    local randT
    local vrandT
    
    local function retryFunction(b)
        local retryButton = b
        if not self.doneRestart then
        
            game.timer:cancel(game.goldTween)
            game.timer:cancel(game.goldPlusTween)
            game:getData().gold = game.finalGold
            game.goldPlus = game.finalGoldPlus
                
            local function func()
                retryButton.fgColor = colors.gold
                retryButton:setText(randT)
                retryButton:shake(25, .5, 20)
            end
            
            local function func3()
                -- self.player = nil--nextfloor
                self:getNewMap()--game:startGame()
                self.doneRestart = true
                
            end
            
            local function func2()
                game:getData().gold = game:getData().gold + (vrandT or 0)
                game.goldPlus = game.finalGoldPlus + (vrandT or 0)
            end
            
            if randT then
                func()
                game.timer:after(.3, func2)
                game.timer:after(.5, func3)
            else
                func3()
            end
        end
    end
    
    
    if math.random() <= 1.3 then
        vrandT = math.random()<.1 and math.random(210,76) or math.random(5,30)
        randT = string.format("Retry (+%s g)", vrandT)
    end
    
    local menuButton = gooi.newButton({
        text = "Menu"
    }):onRelease(menuFunction)
    
    local retryButton = gooi.newButton({
        text = "Retry"
    }):onRelease(retryFunction)
    
    if randT and nil then
        local function func()
            retryButton.fgColor = colors.gold
            retryButton:setText(randT)
            retryButton:shake(25, .5, 20)
        end
        game.timer:after(.4, func)
    end
    
    -- p:debug()
    p:add(label)
    p:add(label2)
    
    p:add(menuButton)
    if not self.isIntro then
        p:add(retryButton, 4, 3)
    end
    
    local hh = menuButton.h*(mnh or 1.3)
    menuButton.h = hh
    retryButton.h = hh
    
    label2.w = label.w - menuButton.w
    
    self.gooiGameover = p
    
    -- local player = self.player or self
    self:play_sound(string.format("sad_trombone_%s", math.random(1,2)), 1.0, .3)
    
    self:closeInventory()
    
    game:saveData()
end

function Map:getNewMap()
    if 1 then
        local m = ChooseMenu()
        game:set_room(m)
        m.begin:setText("start")--()
        gooi.components={}
        m.doStart()
        return
    end
    
            if self.done then
                -- return
            end
                
            self.done = true
        
            local next = function()
                if not self.canStart then
                    -- return
                end
                
                Creature.play_sound(self, "warhorn", nil, .12)--media.sfx.warhorn:play()
                local new = game:startGame()
                
                --new.camera:fade(.01,{0,0,0,1})
                --new.camera:update(1)
                
                local w = W()*.7
                local h = H()/12
                
                --:oldMap = self
            
                new.nexting = self.nexting
                new.nexting2 = gooi.newLabel({text="@Tap any key to continue", x=W()/2-w/2, w=w, h=h, y=H()/2-h/2+(self.nexting.texty and self.nexting.texty.h or font13:getHeight()*4),font=font8}):center() -- getQuote
                
                local n = new.nexting2
                n.fgColor = {1,1,1,0}
                new.timer:tween(1.4, n.fgColor,  {1,1,1,1}, "in-quad")
                
                new.noPopUp = true
                local function allowPopUp()
                    new.noPopUp = false
                end
                
                self.camera:fade(.1,{0,0,0,0})
                new:after(.1, allowPopUp)
            end
            
            local text = self:getQuote(firstQuotes)
            local w = W()*.7
            local h = H()/12
            self.nexting = gooi.newButton({text=text, x=W()/2-w/2, w=w, h=h, y=H()/2-h/2}):
                right()
            
            self.nexting.ySpacing = 5
            self.nexting.opaque = false
            self.nextAlpha2 = 0
            self.drawNextingAgain = true
            
            self:tween(1, self, {nextAlpha2=1}, "out-quad")
            self.camera:fade(1.1,{0,0,0,1}, function() game:startCoroutine(next) end)
end

function jk() return toybox.room:gameover() end

local oldDrawInstances = Map.__draw_instances or error()
function Map:__draw_instances(...)
    set_color(1, 1, 1, 1)
    self.drawnPlayer = false
    self.redrawPlayer = false
    
    local re = oldDrawInstances(self, ...)
    
    if self.redrawPlayer then
        do
            local pl = self.player
            local old_alpha = pl.image_alpha
            pl.image_alpha = .3
            pl:__draw()
            pl.image_alpha = old_alpha
        end
    end
    
    return re
end

function Map:draw_instance(obj) -- obj.light_alpha, obj.image_alpha=1,1
    if obj.isCreature and (not obj.tile or obj.tile.unit ~= obj) then
        return
    end
            local r,g,b,a = lg.getColor()
            
    --!log("drawing instance "..tostring(obj.name)..","..tostring(obj.class and obj.class.name or obj.class_name or obj._id).."("..r..","..g..","..b..","..a..")")
    
    local sh
    if obj.shader then
        sh = love.graphics.getShader() or true
        love.graphics.setShader(obj.shader)
    end
    
    local olda
    if obj == self.player and obj:isInvisible() then
        olda = obj.image_alpha
        obj.image_alpha = olda/2
        
    elseif obj  == self.player then
        obj.image_alpha = lume.max(obj.image_alpha, .4)
        obj.light_alpha = lume.max(obj.light_alpha, .4)
        
    elseif obj.isCreature and obj:isInvisible() and not obj:isAlly(self.player) then
        olda = false
    end
    
    if obj.isCreature and not obj:isInvisible() then
        local l = obj.color
        if l and l[1] and l[2] and l[3] and (l[1]+l[2]+l[3]) <= .2 then
            obj.color = {lume.max(.2,l[1]),lume.max(.2,l[2]),lume.max(.2,l[3])}
        end
    end
    
    if olda ~= false and not obj.isFloor then
        if obj.isItem then
            -- so potions and the like don't actually change color, even in different lighting?
            obj.color = obj.itemColor or obj.color
        end
        
        obj:__draw()
        
        if self.drawnPlayer and (not self.redrawPlayer) and (obj.isCreature or obj.isItem) and obj.w>tw*1.6 then
            local pl = self.player
            if 
                -- creature is taller than player
                (pl.y+pl.offset_y+10) >= (obj.y+obj.offset_y) and
                
                (obj.x-obj.offset_x-obj.w/2) <= (pl.x-pl.offset_x-pl.w/2) and
                (pl.x-pl.offset_x-pl.w/2) <= (obj.x-obj.offset_x+obj.w-obj.w/2) then
                    -- obj.debug=1 pl.debug=1
                    self.redrawPlayer = true
                
            end
        end
        
        
        if obj.isPlayer then
            self.drawnPlayer = true
        end
    end
    
    if olda then
        obj.image_alpha = olda
    end
    
    if sh then
        love.graphics.setShader(sh~=true and sh or nil)
    end
end

function slime() return self:spawn("slime", pl.tile) end

function Map:spawnPlayer(pl) -- spawnit
    local new = not pl
    local kwargs
    
    INFORM_PLAYER("molding the chosen one...")
    
    if new then
        -- add stats/items that aren't in playerClassData
        
        data.scrolls = data.ogScrolls or scrolls
        scrolls = data.scrolls
        
        data.potions = data.ogPotions or potions
        potions = data.potions
        
        kwargs = PIG and self.playerData or lume.update(self.playerClassData, 
            lume.copy(self.playerData or jobs.adventurer)
        )
        
        kwargs.inventory = kwargs.inventory or self.playerData and self.playerData.inventory or {}
        local newInventory = self.playerInventory or PIG and {} or {}
        
        for x, i in ipairs(newInventory) do
            kwargs.inventory[#kwargs.inventory+1] = i
        end
        
        if self.overrideInventory then
            kwargs.inventory = self.overrideInventory
        end
        
        if SHUFFLE_POTIONS then
            shufflePotions()
        end
        
        if kwargs.cantRead then
            shuffleScrolls()
        end
    end
    
    -- so wands will be added to quickslots if intrinsically added
    MAKING_PLAYER = true
    pl = pl or Creature:new(kwargs)
    pl.isPig = kwargs and kwargs.isPig
    MAKING_PLAYER = nil
    
    local w = pl.equipped
    if w then
        w.durability = 10
    end
    
    self.inventoryUser = pl or error()
    
    local team = self.player and self.player.team or "player"
    self.player = self.player or pl
    
    pl.team = team
    local tile
    
    if not pl.notMoved or TUTORIAL then
        tile = self.spawnTile and self.spawnTile.isTile and self.spawnTile or getValue(self.spawnTile or self.spawnTiles) or self.rooms[1]:getRandomSpaceTile()
        self:spawn(pl, tile, "player")
        pl.isPlayer = true
        pl.ogPlayer = true
        -- pl:applyBuff("paralyse",4)
        pl.name = "player"
        pl.title = "You"
        pl.article = ""
        
        pl._id = "player"
    elseif not tile then
        error("NO TILE? WIERD SPAWN?")
    end
    
    assert(tile, "NO LEGITIMATE SPAWN/SPACE TILE FOR PLAYER SPAWNING")
    
    local c = not PIG and pl:getItem("scroll_of_collection")
    if c and not pl.cantRead then
        revealScroll(pl, c, true)
    end
    
    -- pl:forceAddItem("potion_of_polymorphing",5)
    -- pl:forceAddItem("potion_of_invisibility",5)
    pl:forceAddItem("wand_of_electric_blast")
    
    if self.first and not self.noSpawnItems then
        for x = 1, getValue(kwargs.startingItems or math.random(4,7)) do
            self:spawnItemFromPool(kwargs.randomDrops, tile.roomData:getRandomSpaceTile())
        end
        self:addLog("You dropped some of your @ &colors.gold items.")
    
        -- pl.tile:addWater(1)-- = {}
    end
    
    --[[for i = 1,2 do
    local a = self:spawnItem("spear",pl.tile)--doatt
    a:enchant("knockback",3)
    self:spawnItem("shotgun",pl.tile)--2)--anvil
    end
    --self:spawn("skeleton",self:getTile(pl.tile._x+2, pl.tile._y)).stats.hehalth = 3
    --self.spawn = function () return {} end
    --local p = self:spawn("pig",self:getTile(pl.tile._x+2, pl.tile._y))
    --p.stats.health=100
    --self.spawn = null
    self:spawnItem("scroll",pl.tile)
    for x = 1, 2 do self:spawnItem("potion_of_confusion",pl.tile) end
    for x = 1, 2 do self:spawnItem("potion_of_incineration",pl.tile) end
    for x = 1, 3 do self:spawnItem("stone",pl.tile) end
   -- for x = 1, 3 do 
   self:spawnItem("angel_statue",pl.tile.roomData:getRandomSpaceTile())
   ]]
    --[[self:spawn(
        "goblin",--Creature:new(creatures.ruat or {anim="creatures/goblin", frameDelay=.3,sight=2}),
        self.player.tile.roomData:getRandomSpaceTile()
    ):addClass("warrior")
    self:spawn(
        "skeleton",--Creature:new(creatures.ruat or {anim="creatures/goblin", frameDelay=.3,sight=2}),
        self.player.tile.roomData:getRandomSpaceTile()
    )--:die()--.stats.health=2
    
    ]]
    
    if self.playerPostMake then
        self.playerPostMake(self.player, self)
    end
    
    nn = lume.max(pl:getSight(), 5) --sight 2, nn=7
    maxdis = lume.distance(0,0,nn*tw2,nn*th2)
    
    
    self:set_target(pl)
    self:reloadFov()
    
    pl._cry = pl.cry
    pl.cry = null
    
    if new and kwargs and kwargs.postPlayerMake then
        kwargs.postPlayerMake(pl, self)
    end
end

local spawnTexts = {
    ["%s falls into the cave..."] = 50,
    ["%s gets lost and loses its way..."] = 10,
    ["Fate leads %s down to the chaos..."] = 10,
    ["%s seems to have made itself at home..."] = 20
}

function Map:spawn(cr, tile, team, force)
    if not cr.isCreature then
        if type(cr) ~= "table" and not creatures[cr] then
            error(string.format("No creature %s!", cr))
        end
        
        cr = Creature:new(creatures[cr] or cr)
    end
    
    force = force or TUTORIAL
    
    local team = getValue(team or cr.team or false)
    
    if tile and tile.unit then
        log("SPACE TAKEN, LOOKING FOR FREE TILE")
        tile = tile.unit.team == team and getEmptySpaceForClone(tile.unit) or self:getFreeTileAround(tile,"unit")
        if tile and tile.unit then
            log("SPAWN_ERROR No SPACE!")
        end
    end
    
    local t = tile or getValue(self.rooms or self)
    t = tile or (t and t:getRandomSpaceTile())

    if not t then
        log("[SPAWNING] SPAWN_ERROR NO TILE AVAILABLE! "..inspect(type(cr)=="string" and cr or cr._id))
        warn("[SPAWNING] SPAWN_ERROR NO TILE AVAILABLE! "..inspect(type(cr)=="string" and cr or cr._id))
        return
    end
    
    if (t.unit or
        (t.roomData.startingRoom and (self.first or tryyue) and (not self.player or cr.team~=self.player.team) and not self.hasPlayed and team~="player")) and not force then
        log("SPAWN_ERROR RETURNING FROM SPAWING")
        return--assert(not t.unit)
    end
    
    if not t.x then error(inspect(t,2)) end
    
    if self.player and not self.player.doneLoading and self.player.tile and not TUTORIAL and (cr.team~=self.player.team) and (team~=self.player.team) then
        local t1 = self.player.tile
        local count = 50
        if math.random() > .89 then
            INFORM_PLAYER(string.format(lume.weightedchoice(spawnTexts), cr.unspecific))
        end
        while true do
            count = count-1
            local dis = lume.distance(t._x, t._y, t1._x, t1._y)
            if dis > 5 then
                break
            elseif count <= 0 then
                break
            else log("wow"..tostring(self.player.doneLoading))
                t = getValue(self.rooms):getRandomSpaceTile() or t
            end
        end
    end
    
    cr:move_to(t.x,t.y)
    cr.x, cr.y = t.x, t.y
    cr.solid = false
    cr.team = team
    
    if cr.died then
        cr.play = cr.__beforeDeathPlayFunction
        cr.updateTurn = cr.__beforeDeathUpdateTurn
    end
    
    cr.died = false
    cr.dying = false
    cr.playing = false
    cr.done = false
    
    t.color=getValue(colors)
    
    cr._added = cr._added or {}
    local s = tostring(self)
    local added
    
    if not cr._added[s] and self.creatures then --??
        self.creatures[#self.creatures+1] = cr
        cr._added[s] = true
        added = true
        --nextfloor(
    end
    
    -- if cr.name == "pig" and team~="player" then error() end
    
    self:setTile(cr, t, true)
    return cr, added
end

function Map:drarw_instance(obj) if not obj.x then return end
if obj.isCreature and  obj.tile and not obj.tile:canBeSeen() and not obj.isPlayer then return end
    local r,g,b,a = set_color(getColor(obj.isCreature and getValue("orange","green") or obj.isItem and (obj.pcolor or obj.itemColor or obj.color or "cyan") or obj.chasm and "darkblue" or obj.water and "blue" or obj.solid and "darkgrey" or obj.isTile and "black" or "grey", obj.isTile and not obj:canBeSeen() and .3))
    draw_rect("fill",obj.x+obj.offset_x,obj.y+obj.offset_y,obj.w or tw,obj.h or th)
    set_color(r,g,b,a)
    draw_rect("line",obj.x+obj.offset_x,obj.y+obj.offset_y,obj.w or tw,obj.h or th)
    if obj.name then
        lg.print(obj.name, obj.x+obj.offset_x, obj.y)
    end
end

function Map:unsetTile(cr, tile)
    if cr.tile == tile then
        cr.tile = nil
    end
    
    if cr.multiTiles then
        for x, i in ipairs(cr.multiTiles) do
            if i.unit == cr then
                i.unit = nil
            end
        end
    end
    
    if tile.unit == cr then
        tile.unit = nil
    end
    
    
    local n =  tile.pressurePlate and tile.pressurePlate.parent
    if n and n.activated and not tile.item then
        n:deactivate()
    end
end

function Map:setTile(cr, tile, teleported, time)
    local ot = cr.tile
    local oldOpen = tile.hasDoor and tile:doorIsOpen()
    
    if cr.tile then
        self:unsetTile(cr, cr.tile)
    end
    
    if cr.isPlayer and tile.fixed then
        -- self:addLog("&colors.pink This tile was fixed!!!")
        cwarn("[TILE] This tile was once fixed!", "pink")
        -- self.camera:shake(50,.3,24)
    end
    
    if cr.multiTile then
        cr.multiTiles = {}
        local t = tile
        for x = -(cr.multiTile-1), (cr.multiTile-1) do
            local tt = t.room:getTile(t._x+x, t._y)
            if tt then
                tt.unit = cr
                cr.multiTiles[#cr.multiTiles+1] = tt
            end
        end
    end
    
    cr.tile = tile
    tile.unit = cr
    
    if cr.onSetTile then
        cr:onSetTile(tile)
    end
    
    cr:playMove(tile)
    
    if cr ~= self.player then
        if (tile.nextFloor and nil) or (tile:isChasm() and not cr:isFlying() and not tile.web) then
            if self.currentTurn > 2 then
                self:moveToNextFloor(cr, tile.nextFloor, tile)
            end
        end
    end
    
    if cr == self.player then
        -- local ll = (tile.dis or "none").." "..(tile.lightp or "?").."p"..(tile.lights).." lights and "..(tile.light or "??").."is light, color:"..inspect(tile.colorp)
        -- self:addLog(ll) cr:cry(ll)
        self.submergedAlpha = self.submergedAlpha or 0
        if tile.water and tile.water.isDeep then
            if not cr.submerged then
                self:tween(.5, self, {submergedAlpha=.5}, "in-quad")
            end
        elseif cr.submerged then
            self:tween(.3, self, {submergedAlpha=0}, "out-quad")
        end
    end
    
    if cr.tile == cr.goalTile then
        -- cr.goalTile = nil
        cr:playReachGoal()
    end
    
    log(string.format("set tile to %s", tostring(tile)))
    
    if cr.isCreature and tile.lava and not cr:isProtectedFromLava() then
        cr:getAttacked({name="lava", title="lava", attack="100"})
        Fire:new({source=tile, range=1})
    end
    
    if cr.isCreature and ((cr.isPlayer and not cr.teleported) or cr:canClimb()) and not cr.stayPut then
        
        local stairsSound = string.format("wooden_stairs_%s", math.random(1,2))
        
        if ((tile.nextFloor and not cr.cantChangeFloor) or (tile:isChasm() and not cr:isFlying()) and not tile.web) and (not cr.isPlayer or not tile.item or tile.item.noPickup) then
            log("NEXT FLOOR")
            if tile.nextFloor then
                cr:play_sound(stairsSound)
            end
            self:moveToNextFloor(cr, tile.nextFloor, tile)
            if not cr.isPlayer then
                self:playNextCreature()
            end
            return
        end
        
        if tile.previousFloor and not cr.cantChangeFloor and (not cr.isPlayer or not tile.item or tile.item.noPickup) then
            log("PREVIOUS FLOOR")
            if tile.previousFloor then
                cr:play_sound(stairsSound)
            end
            
            self:moveToPreviousFloor(cr, tile)
            if not cr.isPlayer then
                self:playNextCreature()
            end
            return
        end
    end
    
    
    if not tile:isChasm() then
        cr._kayoteTime = cr.kayoteTime+(cr.armour and cr.armour.kayoteTime or 0)+(cr.helmet and cr.helmet.kayoteTime or 0)
    end

    
    if ot and ot.roomData ~= tile.roomData then
        if ot.roomData.onLeave then
            ot.roomData:onLeave(cr, ot)
        end
        
        if tile.roomData.onEnter then
            tile.roomData:onEnter(cr, tile)
        end
    end
    --if not jk then jk=1 self:after(.1,function() pl.tile.nextFloor=1 end) end
    
    if not (tile.isTile) then error( inspect(tile,2)) end
    local f = tile:isAntiFire()
    if f then
        if cr:removeBuff("burn") then
            cr:addLog(string.format("%s is no longer on fire.", cr.title))
        end
    end
    
    if (ot and ot.isDoor) or (tile and tile.isDoor) then
        self:reloadFov()
    end
    
    if not oldOpen and tile.hasDoor then
        cr:play_sound("door",nil,0.05)
    end
    
    if ot and ot.hasDoor and not (ot.item) then-- and ot.isDoor and not ot.item then--ot:doorIsOpen() then
        cr:play_sound("door",nil,0.05)
    end
    
    if cr.isPlayer then
        self:setInfo(self:getTileInfo(tile))
    end
    
    local newTile = tile:getTileToTeleportTo()
    if newTile and not teleported then
        local function thing()
            self:teleport(cr, newTile)
        end
        self:after(time+.05, thing)
    end
    log("done")
end

function Map:getTileName(tile)
    local name = tile.chasm and "a chasm" or tile.grass and tile.grass.name or tile.name or tile.solid and "a wall" or "the ground"
    
    if tile.grass then
        name = tile.grass.name
    end
    
    if tile.item then
        tile.item:getName()
        name = tile.item.unspecific
    end
    
    
    return string.format("%s%s", name, tile.web and " covered in webs" or "")
end

function Map:getTileInfo(tile)
    local txt = tile.unit == self.player and "" or "You see "
    
    
    if tile and tile.unit and tile.unit.isSeen and not tile.unit:isInvisible(self.player) then
        local u = tile.unit
        
        local l = {}
        for x, i in pairs(tile.unit.liking) do
            if type(x) == "table" and x.isCreature then
                l[x.name..","..x.id] = i
            end
        end
        local targ = tile.unit.target or tile.unit.foodTarget
        local states = string.format("[STATE] %s, [TARGET] %s", u.currentState, targ and targ.title or "--")
        local unit = tile.unit
        local peaceful = unit == self.player and "" or targ and "hunting " or "peaceful "
        local buffs = " "
        for x, i in ipairs(unit.buffs) do
            buffs = string.format("%s, %s", buffs, i._id and (i._id.continue or i._id.name) or "?")
        end
        local holding = ""
        if unit.wieldedItem and not unit.isPlayer then
            holding = string.format(" holding %s", unit.wieldedItem.unspecific)
        end
        local position = unit:isFlying() and "flying over" or "on"
        position = string.format(" %s %s", position, self:getTileName(tile) or "the ground")
        
        txt = (txt or "") ..string.format("%s %s%s %s%s%s", unit.isPlayer and "You are" or unit.article or "", peaceful, buffs, unit.isPlayer and "" or unit.name, holding, position)
    
    elseif tile then --  tile.item then
        txt = txt..self:getTileName(tile)
    end
    
    
    local canMoveThere = self.player and self.player.tile and tile and not tile.solid and not self.throwing and self.player.playing and not self.player.moving
    canMoveThere = canMoveThere and lume.distance(self.player.tile._x, self.player.tile._y,tile._x, tile._y)<2
    if canMoveThere then
        txt = string.format("%s &colors.green (click to move here)", txt)
    end
    
    return txt
end

function Map:moveToPreviousFloor(cr, tile)
    tile = tile or cr.tile
    assert(not cr.cantChangeFloor)
    
    if not self.previous then
        return
    end
    
    if cr.isPlayer then
        -- prevents changing floor when transition is still happening
        cr.cantChangeFloor = true
    end
    
    if cr.isPlayer then
            cr.moving = false
            local next = function()
                oldMap = self
                local oc = self.player.controller
                log("MAP: old Map")
                local new = self.previous or error() or Map:new({player = self.player, level = tile.nextLevel, next = true, noLoadPlayer = false})
                log("new Map done")
                
                new.player = self.player
                
                local nc = self.player.controller
                
                --self.player.controller = oc
                
                game:set_room(new)
                
                local op = self.player
                local tt = new.nextFloorTile
                
                assert(op == cr)
                
                self.player:change_room(new, tt.x, tt.y)
                self:removeCreature(cr, true)
                
                
                new:spawn(self.player, tt)
                
                assert(cr.room == new)
                
                for x, item in ipairs(self.player.inventory) do
                    item.room = new
                    item.world = item.room.world
                end
                
                --new:add_controller(self.player.controller)
                
                -- self.player.debug = 1
                self.player.controller.room = new
                
                --new:remove_controller(nc)
                
                new:set_target(self.player)
                new:reloadFov()
                new:playNextCreature()
                
                --new.camera:fade(.01,{0,0,0,1})
                --new.camera:update(1)
                
                local w = W()*.7
                local h = H()/12
            
                --new.nexting = self.nexting
                --new.nexting2 = gooi.newLabel({text="@Tap any key to continue", x=W()/2-w/2, w=w, h=h, y=H()/2-h/2+font13:getHeight()*2,font=font8}):center()
                
                --local n = new.nexting2
                --n.fgColor = {1,1,1,0}
                --new.timer:tween(1.4, n.fgColor,  {1,1,1,1}, "in-quad")
                --new.creatures[#new.creatures+1] = new.player
                --new:setTile(cr, op.tile) warn()
                --moveobj
                
                
                local toMove = new.creaturesToEnterBack or {}
                for x = 1, 0 or #self.creatures do
                    local c = self.creatures[x]
                    if c:canClimb(new) then
                        c.wantsToClimb = true
                        local time
                        local tile = self.previousFloorTile 
                        time = lume.distance(c.tile._x, c.tile._y, tile._x, tile._y)
                        toMove[#toMove+1] = {c, time, tile}
                    end
                end
                
                new.creaturesToEnterBack = toMove
                
                self.camera:fade(.1,{0,0,0,0})
                cr.cantChangeFloor = false
            end
            
            -- local text = self:getQuote()
            local w = W()*.7
            local h = H()/12
            --self.nexting = gooi.newLabel({text=text, x=W()/2-w/2, w=w, h=h, y=H()/2-h/2}):center()
            
            self.camera:fade(1,{0,0,0,1},function()
                self:after(.2, next)
            end)
            
            
            return
    
    elseif cr.isCreature then
        cr.moving = false
        
        self:removeCreature(cr, true)
        cr.light_alpha = 0
    
        if true then
                -- prevents changing the player's location on this map
                self.player.notMoved = true
                oldMap = self
                
                log("going back pMap")
                
                local new = self.previous or error()
                log("new pmap done")
                
                self.player.notMoved = nil
                
                local op = self.player
                local tt = tile and tile.nextFloor and new.previousFloorTile or self:getEquivalentTile(new, tile or cr.tile)
                cr:change_room(new, op.x, op.y)
                cr.room = new
                
                -- self:removeCreature(cr, true)
                new:spawn(cr, tt)
                
                for x, item in ipairs(cr.inventory) do
                    item.room = new
                    item.world = item.room.world
                end
                
                self.next = new
        
        end
        
    end
end

function Map:inviteToMap(creature, tile)
    local cr = creature
    if creature.room ~= self.room then
        cr.room:removeCreature(cr, true)
        
        if cr.sprite and cr.sprite.animation.destroyed then
            log("WARNING: CREATURE already destroyed?? Sprite stuff.")
            cr:destroy()
            return
        end
        
        cr.light_alpha = 0
        
        local op = self.player
        local tt = tile or self:getEquivalentTile(self, cr.tile)
            
        cr:change_room(self, op.x, op.y)
        cr.room = self
                
        -- self:removeCreature(cr, true)
        self:spawn(cr, tt)
                
        for x, item in ipairs(cr.inventory) do
            item.room = self
            item.world = item.room.world
        end
    end
end

function Map:getEquivalentTile(new, tile)
    local x, y = tile._x, tile._y -- storet
    local nxt = self.nextFloorTile or tile-- error()
    
    local diffx = (x-nxt._x)*-1
    local diffy = (y-nxt._y)*-1
    
    local xx, yy = 0,0
    
    local t-- = new:getTile(x,y)
    
    local nxtn = new.previousFloorTile or tile
    local nx, ny = nxtn._x, nxtn._y
    log("diff :"..diffx..","..diffy.." for "..nxt._x..","..nxt._y)
    
    
    local count = 100
    
    while not t or t:isSolid() or t:isChasm() or t.lava do
        for xx = 0,-100,-1 do
            for yy = 0, -100, -1 do
                for tries = 1, 4 do
                    local xxt = tries == 1 and xx or tries == 2 and math.abs(xx) or tries == 3 and math.abs(xx) or tries == 4 and xx
                    local yyt = tries == 1 and yy or tries == 2 and math.abs(yy) or tries == 3 and yy or tries == 4 and math.abs(yy)
                    
                    t = new:getTile(nx+diffx+xxt, ny+diffy+yyt)
        
                    if not t or t:isSolid() or t:isChasm() or t.lava or not t.hasPath then
                        t = nil--new:getTile(x-xx, y-yy)
                    end
                    
                    if t then
                        break
                    end
                end
                
                if t then
                    break
                end
            end
            
            if t then
                break
            end
        end
        
        
        if not t then-- yy < -100 and yy2 > 100 and xx < -100 and xx2 > 100 then
            error("BAD EQUAL TILE")
        end
        
        count = count - 1
        if count <= 0 then
            break
        end
    end
    
    if t and t.lava then
        local c = 0
        while t.lava do
            t = new:getRandomSpaceTile()
            c = c+1
            if c > 10 then
                break
            end
        end
    end
    
    warn("got t at "..t._x..","..t._y.." for "..x..","..y.."(previous)"..nx..","..ny)
    -- coroutine
    
    return t
end

function Map:getNewFloor(notNext)
    local next = not notNext
    local function func2()
        if self.nextMapKwargs then
            self.nextMapKwargs.noLoadPlayer = true
        end
        log("NEW map from get next floor")
        local map = Map:new(self.nextMapKwargs or {player = self.player, level = self.dungeon and (next and self.dungeon.nextLevel), next = next, mapData = self.nextMapData, noLoadPlayer = true})
        self:moveObjectsToNextFloor(map)
        
        return map
    end
    
    if not SMART_LOADING then
        return func2()
    end
    
    log("getting new map game floor")
    
    local startGame = function()
        local attempts = 0
        while true do--for x = 1, 100 do
            attempts = attempts + 1
            local value, result = pcall(func2)
            if not value then
                game.logText = (inspect(result,1) or "Working on it")..": reloading at "..attempts
                warn(game.logText)
                log("ERROR "..tostring(game.logText))
                -- self:yieldCoroutine()
            else
                return result
            end
        end
    end
    
    return startGame()
end

function Map:moveObjectsToNextFloor(next)
    for x = 1, #self.toMoveToNext do
        local cr = self.toMoveToNext[x]
        self:moveObjectToNextFloor(cr, next)
    end
    
    self.toMoveToNext = {}
end

function Map:moveObjectToNextFloor(cr, next)
    if cr.isItem then
    
        log(string.format("[ITEM] %s is falling", cr.name))
        -- prevents changning the players location on this map
        self.player.notMoved = true
        log("making new nmap")
        oldMap = self
        local new = next
        log("done making nmap")
        
        self.player.notMoved = nil
            
        cr:addLog(string.format("%s fell to the floor below!", cr.title))
        
        -- self:removeCreature(cr, true)
    
        local op = self.player
        
        local tt = new.previousFloorTile
        
        cr:change_room(new, op.x, op.y)
                
        new:spawnItem(cr, tt)
        
    else
                -- prevents changing the player's location on this map
                self.player.notMoved = true
                oldMap = self
                
                if self.nextMapKwargs then
                    self.nextMapKwargs.player = self.player
                    self.nextMapKwargs.level = self.nextMapKwargs.level or self.dungeon and self.dungeon.nextLevel
                end
                
                local new = next
                self.player.notMoved = nil
                
                local op = self.player
                local tt = ((tile and tile.nextFloor) or new.fallToStairs) and new.previousFloorTile or self:getEquivalentTile(new, tile or cr.tile)
                cr:change_room(new, tt.x, tt.y)
                new:after(.4, function()
                    local tt = cr.tile
                    cr.x, cr.y = tt.x, tt.y
                    cr:move_to(tt.x, tt.y)
                    -- new:spawnItem("bomb", tt)
                end)
                cr.light_alpha = 0
                -- new:addLight(tt,3,"green")
                cr.room = new
                
                -- self:removeCreature(cr, true)
                
                -- prevents creature from immediately moving back up if spawned on up staircase?
                cr.stayPut = true
                new:spawn(cr, tt)
                cr.stayPut = false
                
                for x, item in ipairs(cr.inventory) do
                    item.room = new
                    item.world = room.world
                end
                
                
                new.playNextCreatyure = null
                if not cr.playTurn then log(inspect(cr.data, 2)) end
                cr:playTurn()
                new.playNextCreature = nil
    
    
                
    end
end
                
function Map:moveToNextFloor(cr, tookStairs, tile)
    tile = tile or cr.tile
    
    if cr.isPlayer then
        -- prevents changing floor when transition is still happening
        cr.cantChangeFloor = true
    end
    
    if cr.isItem then
        if not self.next then
            self:removeItem(cr, true)
            self.toMoveToNext[#self.toMoveToNext] = cr
            return
        end
        
        log(string.format("[ITEM] %s is falling", cr.name))
        -- prevents changning the players location on this map
        self.player.notMoved = true
        log("making new nmap")
        oldMap = self
        local new = self.next or self:getNewFloor()
        log("done making nmap")
        
        self.player.notMoved = nil
            
        cr:addLog(string.format("%s fell to the floor below!", cr.title))
        
        -- self:removeCreature(cr, true)
    
        local op = self.player
        
        local tt = new.previousFloorTile
        
        cr:change_room(new, op.x, op.y)
                
        self:removeItem(cr, true)
        new:spawnItem(cr, tt)
        self.next = new
        
        return
    
    end
    
    cr.moving = false
    
    local doneCharm = false
    
    for x, i in ipairs(cr.allItems) do
        if i.isCharm then
            i.timeToRecharge = 0
            doneCharm = true
        end
    end
    
    if cr.isPlayer then
            local hasDone = self.next
            
            local next = function()
                oldMap = self
                
                -- todo: killed in midair??
                
                if cr.destroyed then return end
                
                local oc = self.player.controller
                
                if self.nextMapKwargs then
                    self.nextMapKwargs.player = self.player
                    self.nextMapKwargs.level = self.nextMapKwargs.level or self.dungeon and self.dungeon.nextLevel
                end
                
                local new = self.next or self:getNewFloor()
                new.previous = self
                self.next = new
                local nc = self.player.controller
                
                --self.player.controller = oc
                
                game:set_room(new)
                
                local op = self.player
                
                local tt = ((tile and tile.nextFloor) or new.fallToStairs) and new.previousFloorTile or self:getEquivalentTile(new, tile or cr.tile)
                
                if not cr.destroyed then
                    log("Dead...?"..(tostring(cr.isDead)))
                    cr:change_room(new, op.x, op.y)
                else
                    warn("Dead anti?")
                end
                
                self:removeCreature(cr, true)
                
                local c, d = new:spawn(self.player, tt)
                if not d then
                    for x = 1, #new.creatures do
                        local c = new.creatures[x]
                        if c.isPlayer then
                            d = 1
                        end
                    end
                end
                
                assert(d)
                
                for x, item in ipairs(self.player.inventory) do
                    item.room = new
                    item.world = room.world
                end
                
                --new:add_controller(self.player.controller)
                
                self.player.controller.room = new
                
                --new:remove_controller(nc)
                
                new:set_target(self.player)
                new:reloadFov()
                --lume.remove(new.creatures, new.player)
                --new.creatures[#new.creatures+1] = new.player
                
                local function n()
                    if doneCharm then
                        cr:addLog("The &colors.gold charms ~ take in the energy of the @new environment.")
                    end
                    
                    new:playNextCreature()
                end
                
                new.timer:after(.5, n)
                
                --new.camera:fade(.01,{0,0,0,1})
                --new.camera:update(1)
                
                local w = W()*.7
                local h = H()/12
                
                if not hasDone then
                    --[[if not self.nexting and nil then
                        -- this doesn't work
                        assert(self.clickedItN)
                        warn("NEXT DONE?")
                    else]]
                    new.nexting = self.nexting
                    new.nexting2 = gooi.newLabel({text="@Tap any key to continue", x=W()/2-w/2, w=w, h=h, y=H()/2-h/2+(self.nexting.texty and self.nexting.texty.h or font13:getHeight()*4),font=font8}):center() -- getQuote
                
                    local n = new.nexting2
                    n.fgColor = {1,1,1,0}
                    new.timer:tween(1.4, n.fgColor,  {1,1,1,1}, "in-quad")
                    
                end
                
                --new:setTile(cr, op.tile) warn()
                --moveobj
                if not tile.nextFloor then
                    cr:addLog(string.format("%s is damaged from the fall.",cr.title))
                    cr:getAttacked({name="fall",attack=2})
                end
                
                local toMove = new.creaturesToEnter or {}
                for x = 1, #self.creatures do
                    local c = self.creatures[x]
                    if c:canClimb(new) then
                        c.wantsToClimb = true
                        local time
                        local tile = c.stats.health > 3 and tile or self.nextFloorTile or tile
                        time = lume.distance(c.tile._x, c.tile._y, tile._x, tile._y)
                        
                        toMove[#toMove+1] = {c, time, tile}
                    end
                end
                
                new.creaturesToEnter = toMove
                
                self.player.__draw = nil
                
                self.camera:fade(.1,{0,0,0,0})
                cr.cantChangeFloor = false
            end
            
            if not hasDone then
                local text = self:getQuote()
                local w = W()*.7
                local h = H()/12
                self.nexting = gooi.newButton({text=text, x=W()/2-w/2, w=w, h=h, y=H()/2-h/2}):
                    right()
            
            
                self.nexting.ySpacing = 5
                self.nexting.opaque = false
            end
            
            self.player.__draw = null
            
            self.camera:fade(1,{0,0,0,1},function()
                self:startCoroutine(next)--self:after(.1, next)
            end)
            
            return
    end
    
    -- if 1 then return end
    
    if not tile.nextFloor and not cr.isFlying then
        cr.tile:addLog(string.format("%s fell to the floor below!", cr.title))
        cr:getAttacked({name="fall",attack=2})
    else
        cr.tile:addLog(string.format("%s %s to the floor below!", cr.title, tookStairs and "moved" or cr:isFlying() and "drifted" or "fell"))
        if not tookStairs then
            cr:getAttacked({name="fall",attack=2})
        end
    end
    
    self:removeCreature(cr, true)
    cr.light_alpha = 0
    
    if true then
        if not self.next then
                self.toMoveToNext[#self.toMoveToNext+1] = cr
        else
                -- prevents changing the player's location on this map
                self.player.notMoved = true
                oldMap = self
                
                if self.nextMapKwargs then
                    self.nextMapKwargs.player = self.player
                    self.nextMapKwargs.level = self.nextMapKwargs.level or self.dungeon and self.dungeon.nextLevel
                end
                
                local new = self.next or self:getNewFloor()
                self.player.notMoved = nil
                
                local op = self.player
                local tt = ((tile and tile.nextFloor) or new.fallToStairs) and new.previousFloorTile or self:getEquivalentTile(new, tile or cr.tile)
                cr:change_room(new, tt.x, tt.y)
                new:after(.4, function()
                    local tt = cr.tile
                    cr.x, cr.y = tt.x, tt.y
                    cr:move_to(tt.x, tt.y)
                    -- new:spawnItem("bomb", tt)
                end)
                cr.light_alpha = 0
                -- new:addLight(tt,3,"green")
                cr.room = new
                
                -- self:removeCreature(cr, true)
                
                -- prevents creature from immediately moving back up if spawned on up staircase?
                cr.stayPut = true
                new:spawn(cr, tt)
                cr.stayPut = false
                
                for x, item in ipairs(cr.inventory) do
                    item.room = new
                    item.world = room.world
                end
                
                
                new.playNextCreatyure = null
                if not cr.playTurn then log(inspect(cr.data, 2)) end
                cr:playTurn()
                new.playNextCreature = nil
                
                self.next = new
        end
    end
end

local qtext =not  '"%s"\n \n \n        - %s' or 
[[
"%s"
  
        - %s
]]

function Map:getQuote(quotesD)
    local quote
    
    local count = 50
    while not quote or quote[1] == game.lastQuote do
        quote = getValue(quotesD or quotes)
        count = count - 1
        if count <= 0 then
            quote = quote or "Erm..."
            break
        end
    end
    
    game.lastQuote = quote[1]
    local txt = string.format(quote[2] and qtext or '"%s%s"', lume.wordwrap(quote[1], 50), quote[2] or "")
    
    return txt
end

function Map:removeCreature(cr, noDestroy)
    if cr ~= self.player or not cr.died then
        lume.remove(self.creatures, cr)
    end
    
    cr._added = cr._added or {}
    cr._added[tostring(self)] = nil
    
    cr.isRemoved = true
    
    if cr.tile then
        local ot = cr.tile
        self:unsetTile(cr, ot)
        cr.tile = ot -- just to allow it to wrap up AI related to tile, no harm ... right?
    end
    
    if cr.lightData then
        self:removeLight(cr.lightData)
        cr.lightData = nil
    end
    
    if not noDestroy then
        cr:destroy()
    end
    
    cr.done = true
    if cr.isPlayer then
        self:playNextCreature()
    end
    
end

function Map:err()
    local c = {}
    for x, i in pairs(self.creatures) do
        c[tostring(i)..(i.isCreature and " is creature" or "?")..(i.class.name or "?")] = i.title or i.name
    end
    
    error(inspect(c))
end

function Map:teleport(cr, tile, doMessage)
    log("teleporting")
    local ot = cr.tile or self:getTileP(cr.x, cr.y)
    local ti = tile and tile.getRandomSpaceTile and tile:getRandomSpaceTile() or tile or self:getRandomSpaceTile()
    local max = 10
    
    if not tile then
        local count = 100
        while (ti == ot) or ((ot and ot.roomData and ot.roomData == ti.roomData) and max>0) do
            ti = self:getRandomSpaceTile()
            max = max - 1
            count = count - 1
            if count <= 0 then
                break
            end
        end
    end
    
    local new = ti and ti.tile or ti
    
    if doMessage then
        cr:addLog(string.format("%s was teleported!", cr.title))
    end
    
    do
        cr.teleported = true
        
        if cr.isPlayer then
            cr:play_sound("long_teleport")
        else
            cr:play_sound("teleport_out")
        end
        
        if cr.isCreature then
            
            
            cr.teleportedRecently = true
            
            self:setTile(cr, new, true)
            
            cr:move_to(new.x,new.y)
            if new.item then
                self:addItemTo(cr, new.item)
            end
            
            cr.x, cr.y = new.x, new.y
            if cr == self.player then
                self:reloadFov()
                self.cameraMan.x = cr.x
                self.cameraMan.y = cr.ogy or cr.y
            end
            
            if cr.lightData then
                self:removeLight(cr.lightData)
                cr.lightData = nil
            end
            
            if cr.light then
                local l = cr.light
                cr.lightData = self:addLight(cr.tile, l[1], l[2])
            end
        else
            self:removeItem(cr)
            self:spawnItem(cr, ti, nil, nil, true)
        end
        
        if not cr.isPlayer then
            cr:play_sound("teleport_in")
        end
        cr.teleported = nil
        cr.moving = false
        
        if cr.playTeleport then
            cr:playTeleport(ot, cr.tile)
        end
        
    end
end

function Map:switchPlaces(obj1, obj2, ...)
    if obj2 == obj2.tile.unit then
        obj2.tile.unit = nil
    end
    
    local t1 = obj1.tile
    local t2 = obj2.tile
    
    if math.abs(t1._x-t2._x)>1 or math.abs(t1._y-t2._y)>1 then
        self:teleport(obj1, t2)
        self:teleport(obj2, t1)
    else
        obj1.switching = true
        obj2.tile.unit = nil
        log("switching")
        self:moveObject(obj1, t2._x-t1._x, t2._y-t1._y, ...)
        self:moveObject(obj2, t1._x-t2._x, t1._y-t2._y, ...)
        obj1.switching = false
    end
    
    
    obj1:addLog(string.format("%s switched places with %s!", obj1.title, obj2.title))
end

function mvv() pl:forceAddItem("wand_of_blinking") pl:forceAddItem("potion_of_confusion") end

function Map:moveObject(cr, vx, vy, speed, tile, getAttacked, attacker, byForce, noAffectAngle, prompt)

   -- setCameraTarget
    if cr.moving and not speed then warn("cr already moving!") return end
    
    log("trying to move")
    if cr.tooScaredToMove then
        if cr.isPlayer then
            cr:addLog("Your body fails to move!!???")
            self:toast("Your body fails to move...?")
            
            local function pll()
                self:playNextCreature()
            end
            self:after(.1, pll)
            cr.playing = false
        else
            cr:addLog(string.format("%s is too scared to move!"))
            cr.done = true
        end
        
        return
    end
    
    if cr.tile and cr.tile.ice then
        cr:addLog(string.format("%s struggles in the ice!",cr.title))
        warn("Cr has iced tile!")
        --assert(not cr.tile.ice.diedd)
        --;assert(not cr.tile.ice.ddone)
        self:playNextCreature()
        return
    end
    -- probably caused by "switching places"
    -- if not cr.playing and not speed then cwarn("yoh, cr not playinf","pink") return end
    
   
    if math.random(1,100) < (cr.clumsiness*10) then
        cr:addLog(string.format("%s fails to move!", cr.title))
        self:playNextCreature()
        return
    end
    
    if cr:isParalyzed() and not speed then
        self:playNextCreature() -- no need
        return
    end
    
    local unsteady = false
  
    
    if cr:isConfused() and not speed then
        local d = getValue(math.random()>.4 and dirs4 or dirs8)
        vx, vy = d[1], d[2]
    elseif cr.unsteady and math.random() > (cr.isPlayer and .8 or .6) then
        if cr.isPlayer then
            cr:addLog(string.format("%s flutter about.", cr.title))
        end
        
        local d = getValue(math.random()>.4 and dirs4 or dirs8)
        vx, vy = d[1], d[2]
        unsteady = true
    end
    
    local t = cr.tile
    local new = tile or self:getTile(t._x+vx, t._y+vy)
      
    if not vx and tile then
        vx = getDir(tile._x-cr.tile._x)
        vy = getDir(tile._y-cr.tile._y)
    end
    
     if cr.tile.web and (cr.tile.web.strength >= 0 or 1) and not cr.nimble and 
     ( (new and new:isFree()) or (new and new.solid) or (not new) )
     then
        cr:addLog(string.format("%s struggles against the web!", cr.title))
        cr:shake(25,.3,25)
        
        cr.tile.web.strength = cr.tile.web.strength - math.random(40,110)*.01--.5--lume.max(.5, cr.stats.strength)
        if cr.tile.web.strength <= 0 then
            cr.tile.web = nil
            cr:addLog(string.format("%s broke free from the webbing!", cr.title))
        else
            self:playNextCreature()
            return
        end
    end
    
    local freeTile = new and new:isFree(cr)
    local rune = freeTile
    
    if new and new.rune and freeTile then
        freeTile = new.rune.excluded[cr]
    end
    
    
        if freeTile and cr and prompt == 1 and cr.isPlayer and cr:isConfused() and not cr:isProtectedFromLava() then
           for x = 1, #dirs8 do
                local t = dirs8[x]
                local tile = self:getTile(cr.tile._x+t[1], cr.tile._y+t[2])
                if tile and tile.lava then
                
                    local func = function()
                        self:moveObject(cr, vx, vy, speed, tile, getAttacked, attacker, byForce, noAffectAngle, false)
                    end
            
            
                    gooi.dialog({
                        text = "You are confused.\nReally risk falling into &colors.red lava?",
                        ok = func
                    })
                    
                    return
            
                end
            end
        end
        
    local range = cr:getMeleeRange()
    if range and range > 1 and freeTile and not byForce then
        for i = 2, range do
            local t = self:getTile(t._x+vx*i, t._y+vy*i)
            local u = t and (t.unit or (t.item and t.item.isObstacle and t.item))
            if u then
            
                if not cr.isPlayer and u ~= cr.target then
                    cr:addLog(string.format("%s bumped into %s", cr.title, u.title))
                end
                
                return cr:doAttack(u)
            end
        end
    end
    
        --[[ cr and prompt == 1 and cr.isPlayer and not cr:isProtectedFromLava() then
           self:addLog("he..inspecry"..inspect(dirs8)) for x = 1, #dirs8 do
                local t = dirs8[x] self:addLog("?")
                local tile = self:getTile(cr.tile._y+t[1], cr.tile._y+t[2])
                if tile and tile.lava then
                
                    local func = function()
                        self:moveObject(cr, vx, vy, speed, tile, getAttacked, attacker, byForce, noAffectAngle, false)
                    end
            
            
                    gooi.dialog({
                        text = "You are confused.\nReally risk falling into &colors.red lava?",
                        ok = func
                    })
                    
                    return
            elseif not tile then error()
                end
            end
        end
    ]]
        
    
    if freeTile then
        if new:isChasm() and prompt == 1 and cr.isPlayer and not cr:isConfused() and not cr:isFlying() and not new.web then
            local func = function()
                self:moveObject(cr, vx, vy, speed, tile, getAttacked, attacker, byForce, noAffectAngle, false)
            end
            
            
            gooi.dialog({
                text = "Really jump into that chasm?",
                ok = func
            })
            
            return
        end
        
        
        
        
        if new.lava and prompt == 1 and cr.isPlayer and not cr:isConfused() and not cr:isProtectedFromLava() then
            self:addLog("@That would be &colors.red instant death.")
            return
        end
        
        if new:isChasm() or new.nextFloor or new.previousFloor then
            FAST = false
        end
        
        if cr.tt then
            local timer = cr.timer or self.timer
            timer:cancel(cr.tt)
            cr.tt = nil
            cr.angle = cr:getMovementType() == "slide" and cr.angle or cr.flipX == 1 and 1 or 1
            
           -- cr.y = new.y
        end
        
        cr.hasMovedThisTurn = true
        cr.moving = true
        log("moving "..tostring(cr==self.player and "player" or ""))
        
        
        if cr==self.player  or ((self.player:getSpeed()-(FASuT and 1 or 0))>=cr:getSpeed() and cr.isSeen) or speed then---or cr.isSeen then
            cr.tweening = true
            local pSpeed = cr.isPlayer and lume.max(lume.min(cr:getSpeed(),1),.5) or self.player:getSpeed()>1 and (lume.max(self.player:getSpeed(),.8)/1.5) or speed and 1 or .01
            local twSpeed = speed and (speed*pSpeed) or cr==self.player and (.3 or .4)*pSpeed or (self.player:getSpeed()>1 and .05*pSpeed or pSpeed)
            cr.twSpeed = twSpeed
        else
            cr.twSpeed = 0
        end
        
        log("setting")
        self:setTile(cr,new,nil,cr.twSpeed)
        log("set")
        cr.mooved = true
        local d = -15
        local oa = cr.angle
        cr.flipX = unsteady and cr.flipX or (vx ~= 0 and getDir(vx) or cr.flipX)
        cr.angle = cr:getMovementType() == "slide" and cr.angle or cr.flipX == 1 and 1 or 1
        cr.oangle = cr:getMovementType() == "slide" and cr.angle or cr.angle+d*(vx == 0 and 1 or vx)+(cr.flipX==-1 and 0 or 0)
        local function finish(nl,noTt)
            log("________[FINISHING TURN MOVEMENT] "..cr.title)
            cr.hasMovedOnce = true
            cr.tweening = false
            cr.moving = false
            -- setCameraTarget
            if not noTt then
                cr.stayStill = true
                --cr.playing = false
                local fc = function()
                    --if not cr.stayStill then error() end
                    cr.stayStill = false
                   -- cr.y = cr.oggy
                    
                    if cr.isPlayer then
                        -- assert(cr == self.currentPlaying)
                        -- assert(cr.playing)
                        self:playNextCreature()
                        
                        -- assert(not cr.playing or cr == self.currentPlaying or self.oldPlayer==cr or not self.oldPlayer,("Played was "..cr.name..", to "..(self.oldPlayer and self.oldPlayer.name or "?").." now "..(self.currentPlaying and self.currentPlaying.name)))
                        
                        --p:playNextCreature()
                    else
                        cr.done = true
                    end
                end
                
                local doFast = not cr.isPlayer
                
                cr.tt = cr.timer:tween(cr.isPlayner and .1 or FAST and .1 or cr.twSpeed or .1,cr,{angle = cr.flipX == 1 and 1 or 1,
                offset_y=cr.ogoffset_y},
                "out-quad", not (doFast or (FAST and not cr.isPlayer)) and fc)
                
                if (doFast or (FAST and not cr.isPlayer)) then--doFast or FAST then
                    fc()
                end
            end
            
            if not cr.teleportedRecently then
                cr:move_to(new.x,new.y)
            end
            
            if new.pressurePlate and new.pressurePlate.parent and (not new.item or not cr.canPickItems) then
                if not new.pressurePlate.parent.silent then
                    new:addLog(string.format("A pressure plate clicks underneath %s...",cr. title))
                end
                self.trapsToActivate[#self.trapsToActivate+1] = new.pressurePlate.parent
                new.toActivateTrap = true
            end
            
            local item = new.item
            
            if new.item then
                self:addItemTo(cr, new.item)
            end
            
            if not cr:isFlying() and new:splashPuddles() then
            
            end
            
            if not cr.teleportedRecently then
                cr.x, cr.y = new.x, new.y
            log("stuff")
            
            if cr == self.player then
                self:reloadFov()
            end
            
            if cr.lightData then
                self:removeLight(cr.lightData)
                cr.lightData = nil
            end
            log("light m")
            
            if cr.light then
                local l = cr.light
                cr.lightData = self:addLight(cr.tile, l[1], l[2])
                cr.lightData.source = cr
            end
            
            if getAttacked then
                cr:getAttacked(cr.thrower or attacker, getAttacked)
            end
            
            end
            
            if item then
                if item.onSteppedOn then
                    item:onSteppedOn(cr)
                end
            end
            
            cr.teleportedRecently = nil
            log("here")
            if ((cr.equipped and cr.equipped.lungeAttack) or cr.lungeAttack) and not byForce then
                local tile = self:getTile(new._x+vx, new._y+vy)
                local u = tile and (tile.unit or (tile.item and tile.item.isObstacle and tile.item))
                if u then
                    local ac = cr.stats.accuracy
                    cr.stats.accuracy = ac + 100
                    cr:doAttack(u)
                    cr.stats.accuracy = cr.stats.accuracy - 100
                    return
                end
            end
            
            if cr == self.player then
               -- self:after(1, function()
               -- self:playNextCreature() --end)
            elseif noTt then
                cr.done = true
            end
        end
        local ox, ow = t.x,t.w
        t.w = t.w*1.2
        t.x = t.x - (t.w-ow)/2
        t.y = t.y+th/2
        if cr.isSeen or cr.isPlayer then
            --cr.spawnDebris(t,cr.color,1/5)
        end
        t.y = t.y-th/2
        t.w = ow
        t.x = ox
        
        -- step sound to 8 bit-y
        cr:play_sound("grass" or string.format("step_%s", 2 or math.random(1)), math.random(7,11)/10)
        
        if cr==self.player  or ((self.player:getSpeed()-(FASTf and 1 or 0))>=cr:getSpeed() and cr.isSeen) or speed then---or cr.isSeen then
            cr.tweening = true
            --[[local pSpeed = cr.isPlayer and lume.max(lume.min(cr:getSpeed(),1),.5) or (lume.max(self.player:getSpeed(),.8)/1.5)
            local twSpeed = speed and (speed*pSpeed) or cr==self.player and .4*pSpeed or .05*pSpeed
            cr.twSpeed = twSpeed]]
            log("tween")
            cr.ogoffset_y = cr.offset_y
            cr.oggy = cr.y--cr.ogy or cr.y
           if mmtt ~= 1 then self.timer:tween(cr.twSpeed, cr,{x=new.x,
            offset_y=cr.offset_y-tw*(new.y==t.y and .4 or 0.2),
             y=new.y, angle=new.y~=t.y and not noAnffectAngle and cr:getMovementType() == "walk" and cr.oangle or nil},"in-quad",finish)
            
             end
            if cr.isPlayer then
                -- self.timer:tween(rSpeed, cr, {x=
            end
        else
            finish(nil,true)
        end
        
    elseif new and new.ice then--new.item and new.item.isObstacle then
        log("[ICE] "..tostring(new.ice).." | "..new.ice.life)
        cr:doAttack(new.ice)
        log("[ICE] "..tostring(new.ice).." | "..new.ice.life)
        
        if cr == self.player then
            cr.playing = false log("ahhhhhhh noooo")
        end
        -- self:addLog("ice")
        self.stall = true
        self:playNextCreature()
        
    elseif new and new.item and new.item.isObstacle then
        cr:doAttack(new.item)
        if cr == self.player then
            cr.playing = false
        end
        self.stall = true
        self:playNextCreature()
        
    elseif cr and new and new.unit and (cr:isEnemy(new.unit) or cr.fightAll) then
        --cr.attack = cr:getDamage()
        
        
        log("att mov")
        if not cr.doneMoveAttack then
            -- prevents attack from being repeated if moving to this direction is part of creature's attack
            log("att mov yes")
            cr.doneMoveAttack = true
            cr:doAttack(new.unit)--new.unit:getAttacked(cr)
            log("att mov done")
        else
            log("att move no!!")
        end
        
        if cr == self.player then
            cr.playing = false
        end
        
    elseif rune and new and not new.teleportRune then
        self:addEnchantLight(new, 3, new.rune.color, 3)
        cr:addLog(string.format("A rune refused to let %s pass!", cr.title))
        return self:playNextCreature()
        
    elseif cr and new and new.unit and (new.unit.lastSwitched <= cr.lastSwitched and not new.unit.isPlayer or cr.isPlayer) and not new.ice and not new.web and not cr.switching and not new.unit.switching then
        -- prevents creatures from keeping on swithing
       
        if cr.cantSwitch or new.unit.cantBeSwitched or new.unit.immobile or (new.unit.multiTile  and not cr:isAlly(new.unit)) then
            cr:addLog(string.format("%s is blocked by %s!", cr.title, new.unit.title))
            return self:playNextCreature()
        else
            if new.unit ~= cr.leader then
                cr.lastSwitched = cr.lastSwitched + 2
                self:switchPlaces(cr, new.unit, speed, getAttacked, attacker, byForce, noAffectAngle, prompt)
            else
                cr.done = true
            end
        end
        
    elseif cr ~= self.player then
        cr.done = true
    elseif new and new.isLocked and (not new.key or not cr:hasItem(new.key)) then
        if cr == self.player and cr.tile.roomData.key then
            self:addLog("&colors.orange The door opened ~ for you!")
            new:unlock()
        else
            self:addLog("&colors.orange This door is &colors.red locked, &colors.orange and You don't have a matching key!")
            return self:playNextCreature()
            -- tile is solid
        end
    end
    
    if new and not new:isFree(cr) and cr.isPlayer then
        log("[Space occupied] "..(new.solid and "tile is solid" or "..."))
        log(string.format("unit: %s, item:%s ", new.unit and tostring(new.unit._id) or "none",
            new.item and new.item._id or "none")
        )
        if self.specialLog and new.solid then
            self.specialLog:newText("You bumped into a wall...")
        end
    end
    
    if new and not new:isFree(cr) and new.isLocked and new.key and cr:hasItem(new.key) and (cr.isPlayer or cr.isSeen) then
        new:unlock()
        local k = new.key
        cr:removeItem(new.key, true)
        new.key:destroy()
        new.key = nil
        
        assert(not cr:hasItem(k))
        -- assert(cr.isPlayer, cr.title..","..tostring(cr._id))
        
        cr:addLog(string.format("%s unlocked %s door.",cr.title,cr.isPlayer and "the" or "a"))
    end
    
    if not new and cr.isPlayer then
        log("[Space is not existing]")
    end
    log("done m")
    return freeTile
end

function Map:lightCallback(fov, x, y)
    local t = self.tiles[x] and self.tiles[x][y]
    
    if not t then return end
    if t:isSolid() then return end
    if t.hasDoor and not t:doorIsOpen() then return end
    
    return true
end

function Map:getFov()
    local rot = toybox.rot()
    local fov = function(fov,x,y) return self:lightCallback(fov,x,y) end
    self.fov = rot.FOV.Precise:new(fov, {topology=4})
    
    local tfov = function(fov,x,y) return self:lightCallback(fov,x,y) end
    self.terrainFov = rot.FOV.Precise:new(tfov)

end

local seenTiles

local function seeFunc(x,y)
    local room = toybox.room
    local t = toybox.room:getTile(x,y)
    if t then
        t.drawID = room.drawID
        seenTiles[#seenTiles+1] = t
    end
end


function nilExplode(x,y,scale,color,old)
    if type(x) == 'number' then
        local nt = getValue(scale or 1.2)
        local exp = toybox.NewBaseObject({room=toybox.room, solid=true, static=true, w=tw*nt,h=tw*nt, x =x,y=y})
        exp.depth = DEPTHS.EFFECTS+100
        local badcol = color == nil or color == "orange" or color == colors.orange or color == "red"
            or color == colors.red
        
        exp.room.exploding = (exp.room.exploding or 0)+1
        exp.light = exp.room:addLight(exp.room:getTileP(x,y),3,color or "yellow")
        exp.sprite = toybox.new_sprite(exp, {
            source = "effects/explosion",--badcol and "explosion2" or not oyld and "explosion" or "effects/explosion",
            delay = .1,
            mode = "once",
            onAnimEnd = function()--draw_in
                exp:destroy()
                exp.room.exploding = exp.room.exploding - 1
                exp.room:removeLight(exp.light)
                exp.deadd = true
            end
        })
        
        exp.source = "effects/explosion/0.png"
        exp.isExplosion = true
        exp.debug = 1
        exp.draw_before = function()
        exp.light_alpha = 1
        exp.image_alpha = 1
            lg.draw(game:getAsset(exp.source),pl.x,pl.y-100,0,5,5)--exp.sprite:draw()
        end
        exp.__draw = function(self, ...) if enrr then error() end
            local r,g,b,a = lg.getColor()
            
            --set_color(1,1,1,1)
            self.sprite:draw()
        end
        exp.name_tag =  "explosion is an art!!"
        
        exp.color = not badcol and (color or dcolors.fire)
        local t = exp.room:getTileP(x, y) or exp
        exp:play_sound("bomb_explosion")--shot2")--explosion")
        
        local room = pl and pl.room or toybox.room
         room:store_instance(exp)
        exp.light_alpha = 1
        exp.image_alpha = 1
        --exp:play_sound(getRetroDie(),
        --getValue(toybox.room and toybox.room.player and toybox.room.player.pitches))
    else
        local function ex()
            local xx = math.random(x.x, x.x+x.w)
            local xy = math.random(x.y, x.y+x.h)
            Explode(xx, xy,scale,color,old)
        end
        
        local timer = (toybox.room.player or toybox.room).timer
        local t = timer:every(.2,ex)
        
        local can = function()
            timer:cancel(t)
        end
        
        timer:after(y or math.max(x.w,x.h)/tw, can)
    end
end
function Map:reloadFov()
    self.drawID = lume.uuid()
    local pl = self.player
    local t = pl.tile
    local l = pl.tile.light or 0
    local added = (l>=.1 and 3 or l>=.5 and 8 or l>=.8 and 12 or 0)*2
    self.addedSight = 0--added and 1
    seenTiles = {}
    
    nn = lume.max(pl:getSight(), 1) --sight 2, nn=7
    maxdis = lume.distance(0,0,nn*tw2,nn*th2)
    --.dis 
    self.fov:compute(t._x, t._y, lume.max(pl:getSight() or 10,10)+added+1, seeFunc)
    pl.seenTiles = seenTiles
    seenTiles = nil
    self:computeLight()
end

local oobj

function Map:isWalkable(x,y)
    if self.walkableFunction then
        return self:walkableFunction(x, y)
    end
    
    local t = self:getTile(x,y)
    local flight = oobj and oobj.isFlying and oobj:isFlying()
    
    if oobj and oobj.tilesToAvoid and oobj.tilesToAvoid[t] then
        return false
    end
    
    if oobj and t and t.lava and not oobj:isProtectedFromLava() then
        return false
    end
    
    if t and t.lava and not oobj then
        return false
    end
    
    if t and oobj and t == oobj.tile then -- moving creature is stuck in a wall or immovable object
        return true -- so they can find a path out of there
    end
    
    if oobj and oobj.multiTile and t then
        local bad
        for x = -(oobj.multiTile-1), (oobj.multiTile-1) do
            local tt = t.room:getTile(t._x+x, t._y)
            if tt and tt:isFree(self.except, oobj) and (flight or not tt:isChasm() or tt.web) then
            else
                bad = true
                break
            end
        end
        if not bad then
            return true
        else
            return false
        end
    end
    
    return t and t:isFree(self.except, oobj) and (flight or not t:isChasm() or t.web)
end

function Map.pathHeuristic(pather, x, y)
    local self = toybox.room
    
    local t = self:getTile(x,y)
    local flight = oobj and oobj.isFlying and oobj:isFlying()
    
    if oobj and oobj.tilesToAvoid and oobj.tilesToAvoid[t] then
        return 0
    end
    
    if oobj and oobj:isProtectedFromLava() and t and t.lava then
        return 10
    end
    
    if not t then return 0 end
    if t.fires > 0 then return -10 end
    if t.web and (not oobj or not oobj.nimble) then return -4 end
    
    if t then
        return 0
    end
    
    return t and t:isFree(self.except, oobj) and (flight or not t:isChasm() or t.web)
end

function Map:findPathTo(obj,x,y,topology,check,buildFunc,heuristic)
    log(string.format("%s is trying to get path...", obj.name or obj._id or obj.class_name or "?"))
    
    local obj = obj
    local x = x
    local y = y
    if type(obj) ~= "table" then
        x = obj
        y = x
        obj = y
    end
    
    oobj = obj
    
    obj = obj.tile or obj
    
    local floor = math.floor
    local _x,_y = (obj.getPos and obj:getPos()) or obj._x, obj._y
    
    --start = {x=floor(_x),y=floor(_y)}
    
    if not self.grid[floor(x)] then log("no tile,returning") return end
    if not self.grid[floor(x)][floor(y)] then log("no tile, returning") return end
    if self.grid[floor(x)][floor(y)].collidable == true then
        log("collidable")
        return
    end
    obj._goto = self.grid[floor(x)][floor(y)]
    self.c_unit = obj


    if not check then
        function check(x,y)
            return self:isWalkable(x,y)
        end
    end
    
    local path = {}
    local function buildPath(x,y)
        local pp = _Path:new(x,y)
        pp.tile = self:getTile(x,y)
        table.insert(path,pp)
        if buildFunc then buildFunc(pp.tile) end
    end
    
    obj.unitBlockedPath = nil
    
    goal = {x=x,y=y}
    start = {x=_x,y=_y}
    local pth = rot.Path.AStar(goal.x,goal.y,check,{topology=topology or 8})
    pth.heuristic = heuristic or self.pathHeuristic or pth.heuristic
    pth:compute(start.x,start.y,buildPath)
    
    
    -- if no path and a unit (creature) as involved in blocking a path then retry ignoring all units
    if #path == 0 and G_unitBlockedPath then
        G_allowUnitPath = true
        local pth = rot.Path.AStar(goal.x,goal.y,check)
        pth:compute(start.x,start.y,buildPath)
        
        if #path > 0 then
            log("[PATHING] Refreshing helped!")
        end
    end
    
    G_unitBlockedPath = nil
    G_allowUnitPath = nil
    
    return path
end

function Map:playNextCreature()
    -- game:yieldCoroutine()
    
    self.playNext = (self.playNext or 0)+1
    if self.playNext < 5 then--10 or true then
        return self:_playNextCreature()
    end
    self.playNext = 0
    
    local f = function()
        while true do
            log("trying play creature coroutine")
            local isSuccess, result = pcall(self:_playNextCreature())
            if not isSuccess then
                log(result)
                INFORM_PLAYER(result)
            end
        end
    end
    
    game.coroutine = nil --?
    game:startCoroutine(f)
end

function Map:_playNextCreature()
    FAST = true
    
    log("=== starting playNextCreature function turn ===")
    
    self.currentSpeedCheck = (self.currentSpeedCheck or 1)
    self.maxSpeedCheck = self.maxSpeedCheck or 5
    
    
    if self.coroutine and coroutine.status(self.coroutine) == "suspended" then
        log("Routine not done to play next turn!")
    end
    
    self.oldPlayer = self.currentPlaying or self.oldPlayer
    
    if self.player and self.player.room ~= self then
        log("returning because player not in the same room "..(self.player.data._id or "?"))
        return
    end
    
    -- do
    if self.doingPlay and self.doingPlay > 20 then
        self.stall = true
        self.doingPlay = nil
    end
    
    if self.stall then
        log("stalling")
        return
    end
    
    log("============ new turn =============")
    
    if self.currentPlaying and not self.currentPlaying.noPlayWell then
        -- if self.currentPlaying.isPlayer and rr then error() end
        
        self.currentPlaying:playEndTurn()
        
    
        if self.currentPlaying.isPlayer then
            -- check poison at end of turn for player
            self.currentPlaying:checkPoisonDamage()
        end
        
        self.currentPlaying.playing = false
        self.currentPlaying:updateStatusEffects()
    elseif self.currentPlaying then
        self.currentPlaying.noPlayWell = nil
        self.currentPlaying.playing = false
    end
    
    self.playing = (self.playing or 0)--1
    if self.player and self.player.died then
        self.doingPlay = (self.doingPlay or 0)+1
    end
    
    local c = self.creatures[self.currentCreature+1]
    if c == self.currentPlaying and c then
        -- means creature is in list twice?
        -- though could also mean creature left to another level then came back on their turn so...
        -- yeah
        --for xx = 1,#self.creatures do self.creatures[xx] = self.creatures[xx].name..", ".. self.creatures[xx].id end error(inspect(self.creatures))
    end

    if not self.gasked and (self.currentPlaying == self.player or (self.player:isReallyDead() and not self.creatures[self.currentCreature+1])) then
        self.hasPlayed = true
        
        -- self:setInfo("")
        
        self.currentSpeedCheck = (self.currentSpeedCheck or 0)+1
        self.maxSpeedCheck = self.maxSpeedCheck or 5
    
        if self.currentSpeedCheck > self.maxSpeedCheck then
            self.currentSpeedCheck = 1
        
            log("UPDATING GASES")
            self:updateGases()
            log("gases done")
            self.noiseManager:update(1)
            self:updateItems()
            log("items done")
        
            self:updatePuddles()
            
            self:checkEvents(1)
        end
        
        
        log("[GAME LOOP] Restarted SPEED AT currentSpeedCheck"..self.currentSpeedCheck)
    
        
        -- traps to activate on next turn?
        for x = 1, #self.trapsToActivate do
            self.trapsToActivate[x]:activate()
            self.trapsToActivate[x].tile.toActivateTrap = nil
        end
        
        self.trapsToActivate = {}
       -- self.currentCreature = self.currentCreature + 1
        local pl = self.currentPlaying-- = nil
        log(string.format("PLAYING NUM: %s", self.playing))
        --self.currentPlaying.name  = self.playing pl:cry("gass")
        self.playing = 0
        
        if self.creaturesToEnter then
            for i = 1, #self.creaturesToEnter do
                local dat = self.creaturesToEnter[i]
                if not dat then
                    -- loop done
                    break
                end
                
                local c = dat[1]
                local time = dat[2]
                dat[2] = time - 1
                log("fmoving "..c.title.." at "..time)
                if time <= 0 and c.room ~= self and c:canClimb(self) then
                
                    if dat[3] and dat[3].nextFloor then
                        local stairsSound = string.format("wooden_stairs_in_%s", math.random(1,2))
                        c:play_sound(stairsSound)
                    end
                    
                    c.room:moveToNextFloor(c, nil, dat[3])
                    table.remove(self.creaturesToEnter, i)
                    log("Creature fmoving down: "..c.title)
                end
            end
        end
        
        
        if self.creaturesToEnterBack then
            for i = 1, #self.creaturesToEnterBack do
                local dat = self.creaturesToEnterBack[i]
                if not dat then
                    -- loop done
                    break
                end
                
                local c = dat[1]
                local time = dat[2]
                dat[2] = time - 1
                log("fmoving "..c.title.." at "..time)
                if time <= 0 and c.room ~= self and c:canClimb(self) then
                
                    if dat[3] and dat[3].previousFloor then
                        local stairsSound = string.format("wooden_stairs_in_%s", math.random(1,2))
                        c:play_sound(stairsSound)
                    end
                    
                    c.room:moveToPreviousFloor(c, nil, dat[3])
                    table.remove(self.creaturesToEnterBack, i)
                    log("Creature fmoving up: "..c.title)
                end
            end
        end
        
        if self.exploding > 0 or trukke then
            log("PAUSE G")
          --  self.gased = true
            self.toPlay = true pl:cry("rr")
            return
        end
        
    
    end
    --player play
    
    self.gased = nil
    local cr = self.currentPlaying
    
    
    
    if cr then
        log("CURRENTLY PLAYING IS "..(cr._id or cr.name).." at didTurn: "..tostring(cr.didTurn))
        log(tostring(cr.room).." is the same room as ? "..tostring(self))
        
        if cr.room ~= self then
            log("BAD ROOM. TILE THO? "..tostring(cr.tile and cr.tile.room))
            local map = cr.room
            cr.room = self
            local tile = cr.tile.room == map and cr.tile
            map:inviteToMap(cr, tile)
            
            return self:playNextCreature()
        end
        
        self.currentPlaying.turnSpeed = lume.max(0,(cr.turnSpeed)-(not cr.didTurn and 0 or cr.attackedThisTurn and 2 or 1))
        self.currentPlaying.currentTurn = self.currentTurn
    end
    
    -- if loop has been reached or current playing speed is up
    if not cr or self.currentPlaying.turnSpeed < 1 or itrue then
        log("step up!! \n    "..(not cr and "no cr!" or "there is a cr! But too slow, doesn't really matter, checking next?\n    speed:")..(cr and cr.turnSpeed or "?"))
        self.currentCreature = self.currentCreature+1
        cr = self.creatures[self.currentCreature]-- or self.creatures[1]
        
        if cr and self.currentSpeedCheck == 1 then
            log("Next will be TESTING SPEED OF "..(cr._id or cr.name or "??"))
            local l = cr.turnSpeed
            cr.turnSpeed = cr.turnSpeed + (self.currentSpeedCheck == 1 and cr:getSpeed() or 0)
            cr.attackedThisTurn = false
            cr.didTurn = false
            log("set didTurn as false, cr turn speed ("..l..") added as "..(self.currentSpeedCheck == 1 and cr:getSpeed() or 0).." now "..cr.turnSpeed)
        elseif not cr then
            log("no cr!?")
        else
            log("currentSpeedCheck not 1? "..self.currentSpeedCheck)
        end
    else
        log("no step up: tooFast?: "..(cr and cr.turnSpeed or "false ")..tostring(cr and cr.didTurn)..tostring(cr.title or cr.name or cr.class).." died: "..tostring(cr.died))
        
        do
            local c = cr
            log((self.currentCreature).." to [Main SPEEDY?] "..c.title..","..c:getSpeed()..","..(c.turnSpeed or "?")..(cr.didTurn and " didTurn" or " yet to play"))
        end
        
        local stamp = nil
        if cr and cr.turnSpeed > 1 then
            for x = 1,0 or #self.creatures do
                local c = self.creatures[self.currentCreature+x]
                local num = self.currentCreature+x
                
                if not c then
                    stamp = stamp or (x-1)
                    
                    c = self.creatures[x-stamp]
                    num = x - stamp
                end
                
                if c and c ~= cr then
                    log((self.currentCreature).." to "..x.." ("..num..") [SPEEDY?] "..c.title..","..c:getSpeed()..","..(c.turnSpeed or "?")..(c.didTurn and " didTurn" or " yet to play"))
                    
                    c.turnSpeed = c.turnSpeed or 0
                    if c == cr.faster and c and c.turnSpeed > 0 then
                        log("NEXTy2")
                        c.faster = cr
                        
                        self.currentCreature = num
                        cr = c
                    
                        cr.attackedThisTurn = false
                        cr.didTurn = false
                        
                        break
                    
                    elseif c:getSpeed() >= cr.turnSpeed and not c.didTkkourn then
                        log("NEXTy")
                        c.turnSpeed = c.turnSpeed + (c.faster and 0 or c:getSpeed())
                        c.faster = cr
                        
                        self.currentCreature = num
                        cr = c
                        
                        
                        --if cr.

                        cr.attackedThisTurn = false
                        cr.didTurn = false
                    
                        break
                    end
                elseif c then
                    log("[SPEEDY] SKIPPED OG")

                end
            end
        end
    end
    
    cr = self.creatures[self.currentCreature]
    
    self.oldPlayer = self.currentPlaying or self.oldPlayer
    self.currentPlaying = cr
    
    if cr then
        -- cr.didTurn = true
    end
    
    
    
    
    if not cr then
        local o = self.currentCreature
        self.currentCreature = 0
        
        self.currentTurn = (self.currentTurn or 0)+(self.currentSpeedCheck == 1 and 1 or 0)
        log("[TURN] !! restart turn order at max "..o.." of total "..#self.creatures)
        
        if self.player.died then
            self.stall = true
            --self:after(.15,function() self.stall = false end)
        end
        
        return self:playNextCreature()
    end
    
    self.logText = "Playing "..cr.title
    
    if (self.pausedPlay or 0)>3 and not cr.isPlayer and nil then
        self.pausedPlay = 0
        self.toPlay = true
        self.currentCreature = self.currentCreature - 1
        self.currentPlaying = nil
        log("pause!! "..self.pausedPlay)
        return
    elseif not cr.isPlayer then
        self.pausedPlay = (self.pausedPlay or 0)+1
        --log("not pause "..self.pausedPlay)
    end
    
    cr.playing = true
    cr.done = false
    
    
    if cr == self.player then if ppol then error() end
        log("[TURN] PLAYER IS THE ONE CURRENTLY playing "..tostring(self).." speed: "..self.player:getSpeed(), "lightgreen")
    end
    
    
    
    if cr.turnSpeed >= self.currentSpeedCheck then
        cr.mooved = false
        cr.doneOnce = true
        -- if cr~=pl and pl.doneOnce then assert(pl.mooved) end
        -- if pl==cr then  newb=newb==2 and 1 or newb and 1 or true log("Newb "..tostring(newb)) end
        
        cr.hasMovedThisTurn = nil
        cr.doneMoveAttack = nil
        cr:updateTurn()
        log("IS PLAYING!!: updateturn")
    
        if cr then-- ~= self.player then
            cr:play()
            if cr.isPlayer and self.moveToTile and not self.moveToTile.throwing then
                cr:moveTo(self.moveToTile)
                if cr.tile == self.moveToTile then
                    self.moveToTile = nil
                end --isseen =
            end
        elseif cr.died then
            log("dead lol")
            return self:playNextCreature()
        end
    
    else
        cr.noPlayWell = true
        log("cr speed is too slow "..cr.turnSpeed.."/"..self.currentSpeedCheck)
        return self:playNextCreature()
    end
end

function Map:see(obj)
    if not obj.isSeen and not obj.hasBeenSeen and obj.isCreature and not (obj.isInvisible and obj:isInvisible()) then
        self.moveToTile = nil
        self.player:addLog(string.format("You spot %s", obj.unspecific))
    end
    
    obj.seenVal = obj.multiTile and (obj.seenVal or 0)+1 or nil
    
    obj.hasBeenSeen = true
    obj.isSeen = true
end

function Map:unsee(obj)
    obj.isSeen = false
    
    obj.seenVal = obj.multiTile and (obj.seenVal or 1)-1 or nil
    if obj.seenVal and obj.seenVal > 0 then
        obj.isSeen = true
    end
end

function Map:er() local i = {} for x, m in ipairs(self.creatures) do i[tostring(m)] = (i[tostring(m)] or 1)+1 end error(inspect(i)) end

function Map:updateItems()
    for _, item in pairs(self.items) do
        item:playStartTurn()
        item:updateTurn()
        
        if item.tile and not item.tile.isChasm then
            -- a normal tile should have "isChasm" function
            error("Item "..item.name..", has a bad tile: "..inspect(item.tile,2))
        end
        
        if item.tile and item.tile:isChasm() and not item.tile.web then
            self:moveToNextFloor(item, false, tile)
        end
        
        if item.tile and item.tile.lava then
            if not item:isProtectedFromLava() then
                item:die()
                Fire:new({source=item.tile, range=1})
            end
        end
    end
end

function Map:updatePuddles()
    for tile, _ in pairs(self.checkPuddles) do
        tile:checkPuddles()
    end
end

local d_i = Map.destroy_instance
function Map:destroy_instance(i, ...)
    if i.isItem and not i.isCarried and i.shopkeeper and not i.shopkeeper.died then
        local item = i
        item.shopkeeper:playMerchandiseDestroyed(item)
        item.shopkeeper = nil
    end
    
    if i.tile and i.isItem then
        log("removing tile item")
        i.tile.item = nil
        
        if i.tile.floor == i then
            i.tile.floor = nil
        end
    
        local n =  i.tile.pressurePlate and i.tile.pressurePlate.parent
        if n and n.activated and not i.tile.unit then
            n:deactivate()
        end
    elseif not i.tile then
        log("no item tile?")
    end
    
    if i.lightData then
        self:removeLight(i.lightData)
        i.lightData = nil
    end
    
    
    if i.isItem and pl and ccr and nil then
        if not self.items[i] then
            local ii = {}
            for x,pi in pairs(self.items) do
                ii[pi.name..","..pi.id] = true
            end
            error(inspect(i.remm)..","..inspect(ii)..","..i.data.name..","..i.id)
        end
    end
    
    
    i.remm = true
    
    if self.items then
        self.items[i] = nil
    end
    
    if i.user then
        lume.remove(i.user.toUpdateItems, i)
    end
    
    return d_i(self, i, ...)
end

function Map:removeItem(item)
    return self:destroy_instance(item)
end

function Map:addGas(gas)
    if gas.isFire then
        return self:addFire(gas)
    end
    self.gases = self.gases or {}
    self.gases[#self.gases+1] = gas
end

function Map:removeGas(gas)
    if gas.isFire then
        return self:removeFire(gas)
    end
    
    local removed = lume.remove(self.gases, gas)
    self:destroy_instance(gas)
    
    return removed
end

function Map:addFire(fire)
    self.fires = self.fires or {}
    self.fires[#self.fires+1] = fire
end

function Map:removeFire(fire)
    local removed = lume.remove(self.fires, fire)
    self:destroy_instance(fire)
    
    return removed
end

--Map.addFire = Map.addGas
--Map.removeFire = Map.removeGas

function Map:gass()
    local t = self.player.tile
    Gas:new({
        source = self:getTile(t._x+3,t._y+3),--room:getRandomSpaceTile(),
        map = self,
        flammability = 1
    })
  --  Fire:new({source=self.player.tile})
end

local ldirs = {"/","\\"}
local lColors = {"grey"}--,"cyan","purple","maroon"}
function Map:update(dt)
    -- INFORM_PLAYER("")
    
    _currentFireFrame = _currentFireFrame + dt*(1/.15)
    currentFireFrame = math.floor(_currentFireFrame)

    
    self.reloadLightCanvasTicker = self.reloadLightCanvasTicker + dt
    if self.reloadLightCanvasTicker >= self.reloadLightCanvasTime then
        self.reloadLightCanvasTicker = 0
        if self.updateCanvas then
            self.updateCanvas = nil
            -- self:reloadCanvas()
            self:reloadLightCanvas()
        end
    end
    
    if not self.player then
        return
    end
    
    gamedata.timePlayed = gamedata.timePlayed + dt
    
    self.timePlayed = (self.timePlayed or 0)+dt

    self.waitAngle = (self.waitAngle or 0) - 250*dt
    self.waitAlpha = (self.waitAlpha or 0) + dt*2
    self.antiWaitAlpha = (self.antiWaitAlpha or 1) - dt*5
    
    self:updateCamera()
    self.creatureDt = dt/(self.player and self.player:getSpeed())
    self.doingPlay = nil
    
    if self.stall then
        self.stallTime = (self.stallTime or .15)
        if self.stallTime <= 0 then
            log("stall cleared")
            self.stallTime, self.stall = nil
        else
            self.stallTime = self.stallTime - dt
        end
    end
    
    if not self:playerCanMove() then
        self.changeLoadingDir = (self.changeLoadingDir or 0)+dt
        self.loadingDirs = self.loadingDirs or 1
        if self.changeLoadingDir > .2 then
            self.loadingDir = self.loadingDir == #ldirs and 1 or (self.loadingDirs + 1)
            self.waitButton:setText("...")
            self.waitImage.source = "none.png"
            self.changeLoadingDir = 0
        end
    else
        --self.waitButton:setText("...")
        self.waitImage.source = "rest.png"
    end
    
    
    if self.player.equipped then
        self.eqImage.source = self.player.equipped.source
    else
        self.eqImage.source = "fist.png"
    end
        
    if self.currentPlaying and self.currentPlaying.isPlayer and self.currentPlaying.died and self.exploding<=0 then
        log("player play next")
        self:playNextCreature()
    elseif self.currentPlaying and self.currentPlaying.died and not self.world:hasItem(self.currentPlaying) and self.exploding <=0 then
        log("[Complication] Dead, next")
        self:playNextCreature()
    elseif self.exploding<=0 and self.toPlay then
        self.toPlay = nil
        self:playNextCreature()
    elseif self.currentPlaying and self.currentPlaying.room ~= self then
        log("next, current on another floor, setting moving to false")
        self.currentPlaying.moving = false
        --self:playNextCreature()
    end
    
    if self.oldStall and not self.stall then
        log("play from stall")
        self.oldStall = self.stall
        self:playNextCreature()
    end
    
    self.oldStall = self.stall
    
    self.dt = dt
    
    self.__update_viewport = null
    if self.viewport_target then
        -- Viewport target
        
      self.viewport:update(dt)
    
      local xTarget = self.viewport_target.x
      local yTarget = self.viewport_target.ogy or self.viewport_target.y

      local roomWidth = self:get_width()
      local roomHeight = self:get_height()

      local halfScreenWidth = love.graphics.getWidth() / 2
      local halfScreenHeight = love.graphics.getHeight() / 2

      if xTarget < halfScreenWidth then
        xTarget = halfScreenWidth
      end

      if yTarget < halfScreenHeight then
        yTarget = halfScreenHeight
      end

      if xTarget > roomWidth - halfScreenWidth then
        xTarget = roomWidth - halfScreenWidth
      end

      if yTarget > roomHeight - halfScreenHeight then
        yTarget = roomHeight - halfScreenHeight
      end

      xTarget = math.round(xTarget)
      yTarget = math.round(yTarget)
        -- Viewport target
      local xTarget = self.viewport_target.x + self.cameraOffset
      local yTarget = self.viewport_target.y

      self.viewport:follow(xTarget, yTarget)
      if self.cameraman then
        local vw = self.viewport
        local cm = self.cameraman
        vw.scale = cm.scale or vw.scale
        vw.angle = cm.angle or vw.angle
      end
    end
    self:updateCoroutine()
end

function Map:updateGases()
    for g = 1, #self.fires do
        local gas = self.fires[g]
        if gas then
            gas:updateTurn()
        end
    end
    for g = 1, #self.gases do
        local gas = self.gases[g]
        if gas then
            gas:updateTurn()
        end
    end
end

allLights = {}
lightCount = 0

local map, lighted, tmpItem, enchantingLight
local lightTile = function(x,y)
        local tile = map:getTile(x,y)
        
        if not tile then
            return
        end
        
        local dis = lume.distance(tile.x,tile.y,tmpItem.x,tmpItem.y)/tw
        local newLight = lume.max(0,1-(dis/tmpItem.maxDis))

        tmpItem.newLight[tile] = newLight
        local light = {
            nilenchantringLight and lume.max(0,(tmpItem.maxDis-dis)) or newLight,
            tmpItem.color,
            tmpItem,
            1-newLight,
            tmpItem.range/(dis+1),
            (dis)/(tmpItem.range*(mcn or 3))  -- lightth
        }
        --.dis 
        -- log("light :"..tmpItem.range..":"..dis..": "..(tmpItem.range/(dis+1))..","..((dis)/tmpItem.range))
        
        if enchantringLight then
        
            tile.enchantingLights[#tile.enchantingLights+1] = light
        else
        
            tile:addLight(light)
        
            --tile.light = (tile.light or 0) + newLight
        
            tile.lights = tile.lights + 1
        end
         
        --tile.color = tmpItem.color
        lighted[#lighted+1] = tile
end

function Map:addEnchantLight(tile, range, color, life, ...)

    -- first remove an old enchanting light if it hasn't faded away yet.
    -- enchant lights aren't too important so whatevs, even if it's far
    if self.enchantLight then
        --self:removeLight(self.enchantLight)
    end
    
    enchantingLight = true
    local light = self:addLight(tile, range, color or "lime", life or 1.2, ...)
    light.enchanting = true
    --self.enchantLight = light
    enchantingLight = false
    
    return light
    
end --mcc

function Map:addLight(tile,range,color,lifeTime,alpha)
    if not tile then
        return
    end
    
    map = self
    range = range*2
    local light = {
        source = tile,
        x = tile.x,
        y = tile.y,
        color = getColor(color or "orange"),--getColor(color or "white"),
        newLight = {},
        maxDis = lume.distance(tile.x-range*tw, tile.y-range*th, tile.x, tile.y),
        isLight = true,
        lifeTime = lifeTime,
        alpha = alpha,
        range = range
    }
    lighted = {}
    tmpItem = light
    tmpItem.range = range*.5
    self.fov:compute(tile._x, tile._y, range, lightTile)
    
    --[[local ll = self.lighting
    local c = light.color 
    ll:setLight(tile._x, tile._y, {c[1]*255,c[2]*255,c[3]*255})--light.color)
     self:computeLight()--gettilel
    ]]
    
    light.lighted = lighted
    light.enchanted = enchantingLight
    
    lightCount = lightCount+1
    allLights[light] = 1
    
    if lifeTime then
        local function removeLight()
            if not light.remove and not light.enfchanted then
                self:removeLight(light)
            end
        end
        
        light.alpha = light.alpha or 1
        
        self:tween(lifeTime, light, {alpha = 0}, "out-quad", removeLight)
    end
    
    map = nil
    lighted = nil
    tmpItem = nil
    
    return light
end

 lo = function()
 self:addEnchantLight(pl.tile,3,"cyan") --debugp
end
function Map:removeLight(light) 
    if not light then return end
    if light.removed then return end
    
    light.alpha = light.alpha or 1
    if light.alpha > 0 and not light.ddone then
        local func = function()
            light.ddone = true
            self:removeLight(light)
        end
        light.dying = true
        self:tween(.7, light, {alpha=0}, "out-quad", func)
        return
    end
    
    light.removed = true
    lightCount = lightCount-1
    allLights[light] = nil
    
    local lighted = light.lighted or {}
    do
        for x = 1,#lighted do
            local tile = lighted[x]
            
            --[[if tile.light or tile.color then--nil then
                tile.light = tile.light - light.newLight[tile]
                tile.lights = tile.lights - 1 --tile.color = nil
                if tile.light<=0.01 then
                    tile.light = nil
                    tile.newLight = nil
                    tile.color = nil
                end
            end]]
            
            tile:removeLight(light)
        end
    end
    
    light.removed = true
end

function Map:playerCanMove()
    local obj = self.player
    if not obj then
        return
    end
    
    obj.lastMoved = obj.lastMoved or 0
    
    return (not obj.moving or obj.lastMoved <= 0) and obj.tile and (not obj.stayStill) and (obj.playing or obj.lastMoved <= 0) and (obj == self.currentPlaying or obj.lastMoved <= 0) and (not self.stall)
end


function Map:doScreenCrack(text, color, pauseTime)
    self.crackedScreenColor = color or {1,.3,.3}
    self.crackedScreenText = text or "You broke your weapon"
    
    local ww = W()*.7
    self.crackedTexty = Sentence:new({
        x = W()/2-ww/2, y = H()/2-font18:getHeight()/2, w = ww, h = H(),
        color = self.crackedScreenColor,
        font = font18,
        instant = true
    })
    self.crackedTexty.centered = true
    self.crackedTexty:newText(text)
    
    self.cracking = 0
    if self.crTw then self.timer:cancel(self.crTw) end
    
    local function kill()
        self.cracking = nil
        self.crTw = nil
    end
    
    local function out2()
        -- self.camera:shake(25, .3, 25)
        self.crTw = self:tween(1.4, self, {cracking=0}, "out-quad", kill)
    end
    
    local function out()
        self.crTw = self.timer:after(pauseTime or lume.min(.8, .5*(#self.crackedScreenText/10)), out2)
    end
    
    self.camera:shake(25, .3, 25)
    self.crTw = self:tween(.5, self, {cracking=1}, "in-quad", out)
end

function Map:addEffect(obj)
    self.effectObjects[obj] = true
end

function Map:removeEffect(obj)
    self.effectObjects[obj] = nil
end

function Map:draw_before()
    --lg.setShader(reverseShader)
    shh = lg.setShader
    --self.player.shader = reverseShader
    --lg.setShader = null
end


function Map:after_draw(dt)
    self.waitAngle = (self.waitAngle or 0)
    
    if self.submergedAlpha and self.submergedAlpha~=0 and self.player and self.player.submerged then
        local c = colors.royalblue
        local r,g,b,a = set_color(c[1],c[2],c[3],self.submergedAlpha or .5)
        draw_rect("fill",0,0,W(),H())
        set_color(r,g,b,a)
    end
    
    --lg.print(love.timer.getFPS(),0,0)
    --lg.print("turn: "..self.currentTurn, 0, lg.getFont():getHeight()+3)
    
    self:drawLightCanvas(dt)
    
    self.camera:attach()
    
    for x, i in pairs(self.sounds or {}) do
        x:draw()
        x.b:__step(dt)
    end
    
    for x, i in pairs(self.effectObjects) do
        x:__draw(dt)
    end
    
    self.camera:detach()
    
    if self.throwing then
        local r,g,b,a = set_color(colors.orange)
        local quickslots = self.quickslotButtons
        local sc = 1.5
        local tc = self.selectedTarget or {}
        tc = tc.unit and not tc.unit:isInvisible() and tc.unit or tc or {} --managethrow
        lg.print(string.format("[TARGETING] %s", texty:new():newText(tc == self.player and "self" or tc.isTile and self:getTileName(tc) or tc.name or "...", true).shortText), quickslots[1].x, quickslots[1].y - lg.getFont():getHeight()*1.1*sc - 3, 0, sc, sc)
        set_color(r,g,b,a)
    end
    
    if self.choosingItem and self.choosingItem.promptText then
        local r,g,b,a = set_color(colors.cyan)
        local quickslot = self.choosingItem.ui_nilllll or self.quickslotButtons[1]
            
        local sc = 1.5
        lg.print(string.format("[%s]",self.choosingItem.promptText), quickslot.x, quickslot.y - lg.getFont():getHeight()*1.1*sc - 3, 0, sc, sc)
        set_color(r,g,b,a)
    end
    
    if self.player then
        local rr,gg,bb,aa = set_color(1,1,1,1)
        
        local hp = lume.min(self.player:healthPercentage()/100,1)
        
        self.playHeart = (self.playHeart or (3)*lume.max(hp,.2))-dt
    
        local maxFrames = 3
    
        self.heartFrame = (self.heartFrame or 0) + (dt/(hp>=.7 and .25 or hp>.4 and .15 or hp>.2 and .1 or .05))
    
        local maxFrames = 3
        local currentFrame = math.floor(self.heartFrame%maxFrames)
        local cr = currentFrame
    
        while cr > (maxFrames-1) do
            cr = 0+(cr-(maxFrames))
        end
        
        if cr < 0 then
            cr = 0
        end
        
        if self.playHeart <= 0 then--cr == 0 and not self.playedHeartbeat then
            Creature.play_sound(self, "heartbeat", 1.2, .12)--.sfx.heartbeat:play()
            self.playHeart = nil
            self.playedHeartbeat = true
        elseif c ~= 0 then
            self.playedHeartbeat = nil
        end
    
        local h = game:getAsset(string.format("hearts/%s/%s.png",self.player.poisoned>0 and "purple_heart" or "blood_heart", cr))
        
        local ws = (H()/25)*2
        
        local wh, hh = resizeImage(h, ws, ws)
        love.graphics.draw(h, 10, 2, 0, wh, hh)
        
        self.hx, self.hy = 10+ws/2, 2+ws/2
        
        local l = self.player.lifebar
        l.angle = 0
        l.w, l.h = (W()*.2)*(1 or self.player.maxHealth/15), H()/25
        l.x, l.y = ws-10,20
        l.healthColor = self.player.poisoned>0 and "purple" or "red"
        l:draw()
        
        love.graphics.draw(h, 10, 2, 0, wh, hh)
        
        local strength = string.format("x%s", self.player.stats.strength or "?")
        local gg = self.player.gold
        
        local i = game:getAsset("setpieces/strength_bigger.png")
        local w = l.h*2
        local ww, hh = resizeImage(i, ws, ws)
        love.graphics.draw(i, 10+ws, 2+ws+10, 0, ww*-1, hh)--, i:getWidth()/2, i:getHeight()/2)
        do
            local r,g,b,a = set_color(colors.darkred)
            love.graphics.print(strength, 10+ws+20, l.y+l.h+5+l.h*3/4+lg.getFont():getHeight()/2, 0, 2, 2)--1.3, 1.3)
            set_color(r,g,b,a)
        end
        
        
        local extraX = lg.getFont():getWidth(strength)*2+ws+10+10
        local i = game:getAsset("items/gold.png")
        local w = l.h*2
        local ww, hh = resizeImage(i, l.h*3, l.h*3)
        love.graphics.draw(i, 0 or extraX+l.x, ws+20+l.y+10, 0, ww, hh)
        local r,g,b,a = set_color(colors.gold)
        love.graphics.print(gg, (ws+10+20) or extraX+l.x+l.h*3+10, ws+20+l.y+l.h+5+l.h*3/4+lg.getFont():getHeight()/2, 0, 2, 2)--1.3, 1.3)
        set_color(r,g,b,a)
        
        --[[local i = game:getAsset("items/gold.png")
        local w = l.h*2
        local ww, hh = resizeImage(i, l.h*3, l.h*3)
        love.graphics.draw(i, l.x, l.y+l.h*3+10, 0, ww, hh)
        local r,g,b,a = set_color(colors.gold)
        love.graphics.print(gg, l.x+l.h*3+10, l.y+l.h+5+l.h*3/4+ws+10, 0, 1.3, 1.3)
        set_color(r,g,b,a)]]
        
        --[[
        local gg = self.player.gold
        local i = game:getAsset("items/gold.png")
        local w = l.h*2
        local ww, hh = resizeImage(i, l.h*3, l.h*3)
        love.graphics.draw(i, l.x, l.y, 0, ww, hh)
        local r,g,b,a = set_color(colors.gold)
        love.graphics.print(gg, l.x+l.h*3+10, l.y+l.h+5+l.h*3/4, 0, 1.3, 1.3)
        set_color(r,g,b,a)
        
        
        local strength = string.format("x%s", self.player.stats.strength or "?")
        local i = game:getAsset("setpieces/strength_bigger.png")
        local w = l.h*2
        local ww, hh = resizeImage(i, l.h*3, l.h*3)
        love.graphics.draw(i, l.x, l.y+l.h*3+10, 0, ww, hh)
        local r,g,b,a = set_color(colors.darkred)
        love.graphics.print(strength, l.x+l.h*3+10, l.y+l.h+5+l.h*3/4+l.h*3+10, 0, 1.3, 1.3)
        set_color(r,g,b,a)]]
        
        
        if not self:playerCanMove() then--or (self.antiWaitAlpha or 0) > 0 then
            local cantMove = not self:playerCanMove()
            
            local wx = l.x+10
            local wh = ws*1.5*.65
            local wy = l.y+l.h+5+l.h*3/4 + wh + l.h*3+20
            
            local w  = game: getAsset("wait.png")
            
            local www, wwh = resizeImage(w, wh, wh)
            local ang = math.rad(self.waitAngle)
            
            if cantMove then
                self.antiWaitAlpha = 1
            end
            
            set_color(r, g, b, not cantMove and self.antiWaitAlpha or self.waitAlpha or 0)
            lg.draw(w, wx, wy, ang, www, wwh, w:getWidth()/2, w:getHeight()/2)
            set_color(r,g,b,a)
        else
            self.waitAlpha = 0
        end
        
        set_color(rr,gg,bb,aa)
        
    end
    
    gooi.draw(gooi.currentGroup)
    
    for x = 1, #self.quickslotButtons do
        local b = self.quickslotButtons[x]
        b.angle = b.angle or math.random(-45,45)
        if b.item then
            local i = b.item
            i:redraw(b.x+b.shake_x, b.y+b.shake_y, b.angle, b.w, b.w*(i.h/i.w))
        end
    end
    
    if self.choosingItem and self.choosingItem.ui then
            local uii = self.choosingItem.ui.images[1]
            if uii then
                local onc = uii.color
                uii.color = self.choosingItem.color
                gooi.drawComponent(self.choosingItem.ui, true)
                uii.color = onc
            end
    end
    
    self:drawCanvas(dt)
    
    self:__draw_controllers()
    --lg.setShader=shh
    --lg.setShader()
    
    if not gooi.showingDialog then
        local r,g,b,a = set_color(0,0,0)
        draw_rect("fill",self.cover.x,self.cover.y,self.cover.w,self.cover.h)
        set_color(r,g,b,a)
        
        local ddt = love.timer.getDelta()
        
        if self.specialLog and not self.throwing and not self.cover.scrolled then
            self.specialLog:update(ddt)
            self.specialLog:draw()
        end
        
        -- draw_rect("fill",yyt.x,yyt.y,yyt.w,10)
        for i = 1, #self.logs do
            local yyt = self.logs[i]
            yyt:update(ddt)
            yyt:draw()
        end
        
        self.infoText:update(ddt)
        
        if not self.cover.scrolled then
            self.infoText:draw()
        end
        
        local r,g,b,a = set_color(0,0,0)
        draw_rect("fill",self.coverAll.x,self.coverAll.y,self.coverAll.w,self.coverAll.h)
        set_color(r,g,b,a)
    
    end
    
    if self.cracking then
        do
            local r,g,b,a = set_color(0,0,0,self.cracking*.7)
            draw_rect("fill",-W(),-H(), W()*3, H()*3)--cant
        end
        
        local col = self.crackedScreenColor or {}
        local r,g,b,a = set_color(col[1] or 1,col[2] or .3,col[3] or .3,self.cracking)
        lg.draw(game:getAsset("screencrack.png"))
        
        local text = self.crackedScreenText or "Your weapon broke!"
        local sc = 1
        local f = font18
        local of = lg.getFont()
        lg.setFont(f)
        local w = f:getWidth(text)
        local h = f:getHeight()
        --lg.print(text, W()/2-w/2, H()/2-h/2)
        lg.setFont(of)
        self.crackedTexty.alpha = self.cracking
        self.crackedTexty:update(dt)
        self.crackedTexty:draw()
        
        set_color(r,g,b,a)
    end
    
    if self.nexting then
        self.camera:draw()

        if self.nexting2 then
            local r,g,b,a = set_color(0,0,0,1)
            draw_rect("fill",-W(),-H(), W()*3, H()*3)
            set_color(r,g,b,a)
        end
        
        gooi.drawComponent(self.nexting)
        
        if self.nexting2 then
            gooi.drawComponent(self.nexting2)
        end
    end
    
    if self.nextAlpha and self.nextAlpha > 0 then
    
            local r,g,b,a = set_color(0,0,0,self.nextAlpha)
            draw_rect("fill",-W(),-H(), W()*3, H()*3)--cant
            set_color(r,g,b,a)
    end
  
    
    if self.gooiGameover then
        
        gooi.drawComponent(self.gooiGameover, true)
        local p = self.gooiGameover
        -- draw_rect("line",p.x,p.y,p.w,p.h)
    end
      
    if self.playerBones then
        self.camera:attach()
        for x = 1, #self.playerBones do
            local b = self.playerBones[x]
            b:__draw()
        end
        self.camera:detach()
    end
    
    
    if self.nextAlpha2 and self.nextAlpha2 > 0 then
            local r,g,b,a = set_color(0,0,0,self.nextAlpha2)
            draw_rect("fill",-W(),-H(), W()*3, H()*3)--cant
            set_color(r,g,b,a)
            
            if self.playerBones and nil then
                self.camera:attach()
                for x = 1, #self.playerBones do
                    local b = self.playerBones[x]
                    b:__draw()
                end
                self.camera:detach()
            end
    end
    
    
    
    if self.nexting and self.drawNextingAgain then
        self.camera:draw()

        if self.nexting2 then
            local r,g,b,a = set_color(0,0,0,1)
            draw_rect("fill",-W(),-H(), W()*3, H()*3)
            set_color(r,g,b,a)
        end
        
        gooi.drawComponent(self.nexting)
        
        if self.nexting2 then
            gooi.drawComponent(self.nexting2)
        end
    end
  
    local h = lg.getFont():getHeight()+3
    lg.print(string.format("FPS: %s", love.timer.getFPS()),150,200)
    love.graphics.print(string.format("garbage count: %smb",collectgarbage("count")/1024),0,200+10+h)
    
    --[[local h = lg.getFont():getHeight()+3
    lg.print(string.format("FPS: %s", love.timer.getFPS()),0,0)
    lg.print(string.format("turn: %s", self.currentTurn), 0, lg.getFont():getHeight()+3)
    lg.print(string.format("[MAP] : %s", self.logText or ""), 0, (lg.getFont():getHeight()+3)*2)
    
    love.graphics.print(string.format("garbage count: %smb",collectgarbage("count")/1024),0,h*3)
    love.graphics.print(string.format("Texture mem: %smb",love.graphics.getStats().texturememory/(1024*1024)),0,h*4)
    old_print(inspect(love.graphics.getStats()),0,h*6)]]
end

local function sortThrow(tile)
    return tile.isTile--not tile.solid
end

function Map:mousemoved(x,y)
    
    x,y = self.camera:toWorldCoords(x,y)
    local tile = self:getTileP(x,y)
    
    local txt
    
    if tile then
        txt = self:getTileInfo(tile)
    end
    
    if txt and not gooi.oldCompMove then
        self:setInfo(txt)
    end
      
    if self.buttonPressed or self.clicked then
        -- self.buttonPressed = nil
        return
    end
    
    if self.mousePopUp and not (tile and tile.item) then
        self:removePopUp()
    end
    
    if tile and tile.item and tile:canBeSeen() and (self.popUpItem ~= tile.item or not self.popUp) and (not self.popUp or true) and not self.throwing and not tile.item.isWall and not tile.item.isFloor then self:addLog("mousy")
        self.mousePopUp = self:itemPopUp(tile.item, true) or true
    end
end

function Map:mousereleased(x,y)
    if not self.player then
        return
    end
    
    if self.nexting2 then
        self:play_sound("descend")
        
        self.nexting = nil
        self.clickedItN = true
        self.nexting2 = nil
        self.nextAlpha = 1
        self:tween(.7,self,{nextAlpha=-.01},"out-quad")
        if oldMap then
            gooi.removeComponent(oldMap.nexting)
            oldMap.nexting = nil
        end
        return
    end
    
    self.player.name = ""--#self.creatures.." creatures on map"
    
    if self.cover.scrolled then
        self:unscroll()
        return
    end
    
    x,y = self.camera:toWorldCoords(x,y)
    local tile = self:getTileP(x,y)
    
    -- Debris.spawn(x,y,"purple")
    if self.clicked then
        self.clicked = false
        return
    end
    
    
    if self.buttonPressed then
        self.buttonPressed = nil
        return
    end
    
    --spawnitem is called
    
    local txt
    
    if tile then
        txt = self:getTileInfo(tile)
    end
    
    if txt and not gooi.oldCompMove then
        self:setInfo(txt)
    end
    
    if tile and tile.item and tile.item.name == "ice" and tile.ice~=tile.item then error() end -- e:isSo
    if tile then
        local colorr, lenm
        lenm = #tile.myLights
        do
            local self = tile
            
            local player = self.room.player
            local dis = lume.distance(self.x, self.y, player.x, player.y)
    
            local aa = dis/(maxdis+(self.room.addedSight or 0))
            local light = 1
            local light2 = 0
            light = myLight or light or lightAll and 1 or 0--self.myLight or light or 1
            light2 = lightAll and 1 or 0--1
            local donec= {}
            local col = self.color
            for i = 1, lenm do
                --i = math.random(1,lenm)
                local addc = addc
                local l = self.myLights[i]
                local ii =(((1-aa)*light)+(self.light or 0))/((self.light or 0) + 1)-- l[4]
                local iii = 1
                ii = lume.min(ii, .9)
                local color = l[2] or colors.green--getColor(l[2] or "black")--, l[3].alpha)
                if l[3].alpha then
                    color = lume.copy(getColor(color))
                    for x = 1, 3 do
                        color[x] = color[x]--*l[3].alpha assert(color[x]>=0) assert(ii<=1,ii)
                    end
                    ii=.5--self.color = color
                    color[4]=lume.max(.4,l[3].alpha)
                    addc = addc2
                    --break
                end
                
                --local color = donec[l[2]] and {0,0,0} or color--{color[1]*iii,color[2]*iii,color[3]*iii}
                colorr = lenm == 1 and color or addc(getColor(self.color or "black"),color or
                color,ii)
            end
        end
        
        txt = (txt or "")..string.format("[TEMP] %s (from %s)",tile:getTemperature(),tile.temperature).."\n"..string.format("[lights] : %s ( %s ) { %s }", lenm, inspect(colorr), inspect(self.color)) -- debugp
    end
    
    if txt then
        -- self:addLog(txt)
    end
    
    local pl = self.player
    local canMoveThere = pl and pl.tile and tile and not tile.solid and not self.throwing and  pl.playing and not pl.moving
    canMoveThere = canMoveThere and lume.distance(pl.tile._x, pl.tile._y,tile._x, tile._y)<2
    if canMoveThere then
        -- self:moveObject(pl, getDir(tile._x-pl.tile._x), getDir(tile._y-pl.tile._y))
    end
    
    self:manageThrow(tile)
end

function Map:manageThrow(tile)
    
    self.oldThrows = self.oldThrows or {}
    log("m throw"..tostring(self.throwing and tile and self.throwTile == tile and not self.throwTooFar))
    
    local m = self.moveToTile
    local no
    if m and tile~=m and not m.throwing then
        self.moveToTile = nil
        no = true
    end
    
    if not no and tile and not self.throwing and self.player.playing and not self.player.moving and nil then
        if not tile:isSolid() and tile.seen then
            if tile == self.moveToTile then
                self.player:moveTo(tile)
                tile.throwing = false
            else
                tile.throwing = true
                --if self.moveToTile then
                self.moveToTile = tile
            end
        end
    end
    
    if self.throwing and tile and tile~=self.throwTile then
        log("thr")
        self.throwTile = tile
        local i = self.throwing
        local user = self.inventoryUser
        local tt = user.tile
        local tiles, len = self.world:querySegment(tt.x+tw/2, tt.y+th/2, tile.x+tw/2, tile.y+th/2, sortThrow)
        local lastTile = tt
        for x = 2,#self.oldThrows do
            self.oldThrows[x].throwing = nil
            -- self.selectingTarget = nil
        end
        local bad
        self.oldThrows = {}-- assert(len>0)
        for ii = 1, len do -- #add max throw range
            local t = tiles[ii]
            self.oldThrows[ii] = t
            t.throwing = true
            t.throwingDest = false
            t.throwingBad = false
            if t:isSolid() then
                bad = true
            end
            
            if bad then
                t.throwingBad = true
            else
               lastTile = t.item and t.item.isThrowObstacle and lastTile or (t.unit and not t.unit:isInvisible() and i.unitBlocks and lastTile) or t
                if t.item and t.item.isThrowObstacle or (t.unit and t.unit~=user) then
                    bad = true--break
                end
            end
        end
        lastTile.throwingDest = true
        self.throwTooFar = lume.distance(tt._x, tt._y, lastTile._x, lastTile._y) > (self.wandZapping and 20 or user:getThrowDistance(i))
        self.selectedTarget = lastTile
        
    elseif self.throwing and tile and self.throwTile == tile and not self.throwTooFar then
        log("throwing")
        self.throwTile = nil
        local i = self.throwing
        local user = self.inventoryUser
        local tt = user.tile
        local tiles, len = self.world:querySegment(tt.x+tw/2, tt.y+th/2, tile.x+tw/2, tile.y+th/2, sortThrow)
        local lastTile = tt
        for ii = 1, len do -- #add max throw range
            local t = tiles[ii]
            t.throwing = false
            if t:isSolid() then
                break
            end
            
            lastTile = t.item and t.item.isAnvil and t or t.item and t.item.isThrowObstacle and lastTile or (t.unit and i.unitBlocks and lastTile) or t
            if t.item and t.item.isThrowObstacle or (t.unit and t.unit~=user) then
                break
            end
        end
        
        if self.selectingTarget then
            self.throwing = nil
            user.target = lastTile.unit or lastTile
            self.selectingTarget = nil
            
            self.onTarget(i, user, user.target)
            self.onTarget = nil
            return
        end
        
        if lastTile and not lastTile.isChasm then
            error("Not proper last tile "..inspect(lastTile,1))
        end
        
        user:removeItem(i)
        if i.tile then
            i.tile.item = nil
        end
        
        i.throwing = true
        i.tile = lastTile
        --tile.item = nil
        i.throwing = true
        self.throwing = nil
        
        user:play_sound("throw")
        
        local firstTile = lastTile.teleportRuneID
        local lastTeleportTile = firstTile and firtTile == #self.teleportRunes and (firstTile>1 and firstTile-1) or #self.teleportRunes
        
        local function thrown()
            local newTile = lastTile.teleportRuneID and lastTile.teleportRuneID ~= lastTeleportTile and lastTile:getTileToTeleportTo(true)
            
            if newTile and not self.unit then
                i.x, i.y = newTile.x, newTile.y
                lastTile = newTile
                self:after(.1, thrown)
                return
            end
            
            i.throwing = false
            --i.tile = lastTile
            
            if not lastTile.isChasm then error() end
            
            if not (lastTile.item and (lastTile.item.isAnvil or lastTile.item.anvil)) then
                log("thrown")
                i:onThrown(lastTile, user)--onrec
            else
                log("spawned")
                self:spawnItem(i,lastTile)
            end
            
            if i.tile and not i.tile.isChasm then error("tile is wierd "..inspect(i.tile,1)) end
            i.va = 0
            self:playNextCreature()
        end
        
        local time = .1*(lume.distance(tt._x, tt._y, lastTile._x, lastTile._y))
        i.va = 360*4--local spin = (time/.3)/3
        
        self:tween(time, i, {x=lastTile.x, y=lastTile.y}, "in-quad", thrown)
    end
end

function Map:dzoom()
        --pl:polymorph("goblin")
    
    
    --error(lightCount..","..inspect(allLights,3))
    if true then--not lightAll then
    lightAll = not lightAll--true
    osse = osse or self.camera.scale
    self:tween(.7,self.cameraMan,{scale=self.cameraMan.scale>.1 and .1 or osse})
    olt = olt or Tile.draw
    --self:set_target(self.allTiles[math.floor(#self.allTiles/2)])
    --Tile.draw = function(self) if self.solid then draw_rect("line",self.x,self.y,self.w,self.h) end end
    else
    Fire:new({source=self.player.tile})
        lightAll = false
        self:tween(.7,self.cameraMan,{scale=osse})
        self:set_target(self.player)
        Tile.draw = olt
    end
end

function Map:keypressed(k) ---- ppol=1
    
    
    if self.nexting2 then
        self.nexting = nil
        self.clickedItN = true
        self.nexting2 = nil
        self.nextAlpha = 1
        self:tween(.7,self,{nextAlpha=-.01},"out-quad")
        gooi.removeComponent(oldMap.nexting)
        oldMap.nexting = nil
        return
    end
    
    if self.cover.scrolled then
        return self:unscroll()
    end
    
    
    
    if k == "escape" and false then
        --pl:polymorph("goblin")
    
    
    --error(lightCount..","..inspect(allLights,3))
    if true then--not lightAll then
    lightAll = not lightAll--true
    osse = osse or self.camera.scale
    self:tween(.7,self.cameraMan,{scale=self.cameraMan.scale>.1 and .1 or osse})
    olt = olt or Tile.draw
    --self:set_target(self.allTiles[math.floor(#self.allTiles/2)])
    --Tile.draw = function(self) if self.solid then draw_rect("line",self.x,self.y,self.w,self.h) end end
    else
    Fire:new({source=self.player.tile})
        lightAll = false
        self:tween(.7,self.cameraMan,{scale=osse})
        self:set_target(self.player)
        Tile.draw = olt
    end
    
    end
    
    --self.player:knocback(1,0,10)--self.reportDrawPerformance = true if 1 then return end
    if k == "escape" then
        if self.popUp then
            self:removePopUp()
            return
        end
    
        if self.inventoryIsOpen then
            self:closeInventory()
            return
        end
    
        if self.throwing or self.selectingTarget or self.moveToTile then
            self.selectingTarget = nil
            self.throwing = nil
            self.selectedTarget = nil
            self.wandZapping = false
        
            for x = 1,#self.oldThrows do
                self.oldThrows[x].throwing = nil
            end
        
            self:addLog("selecting canceled")
        
            if self.moveToTile then
                self.moveToTile.throwing = false
            end
        
            self.moveToTile = nil
            return
        end
        
        local function func()
            game:set_room(TitleMenu:new({}))
        end
        
        local function fcancel()
            self.gooiGameover = nil
        end
        
        if gooi.dialog({
            text = "Exit the &colors.red @madness?",
            ok = func,
            okText = "yes",
            cancelText = "NEVER",
            group = gooi.currentGroup,
            cancel = fcancel
        }) then
        
        local panelDialog = gooi.panelDialog
        
        local function func2()
            gooi.panelDialog = panelDialog
            self.gooiGameover = gooi.panelDialog
            gooi.addComponent(gooi.panelDialog)
            gooi.panelDialog.opaque = true
        end
        
        self:after(.05, func2)
        end
        
        return
    end
    
    -- only called by baton/controller
    if k == "okay" then
    
        if self.throwTile then
            self:manageThrow(self.throwTile)
        end
        
    end
    
end

return Map
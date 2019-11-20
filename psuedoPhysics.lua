local API = {};
local currentLines = {}
local psuedoDebug = require("psuedoDebug")

--USE VECTORS OR TABLES TO STORE POINT DATA???

--debug
--change it to use variables already in render function
local d_printCollL = psuedoDebug.PRINT_COLLISION_LINES
local d_printCollP = psuedoDebug.PRINT_COLLISION_POINTS
local d_showCollP = psuedoDebug.VISUALISE_COLLISION_POINTS = false

API.update = function(self, dt)
    local CurrentStack = psuedoWorkspace:getStack();
    local collisionList
    currentLines = {}
    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') or actualObject.ClassName == "Polygon" then
            velocityUpdate(actualObject, dt)
            defineLines(actualObject)
            --collision list is all the collisions ONLY for the current actualObject
            collisionList = checkCollisions(actualObject.Name)
            if PRINT_COLLISION_POINTS then printCollisions(actualObject, collisionList) end
            if VISUALISE_COLLISION_POINTS then visualiseCollisions(collisionList) end
        end

    end
end

function visualiseCollisions(collisionList)
    for i = 1, #collisionList do
        local x = collisionList[i][2][1]
        local y = collisionList[i][2][2]

        function love.draw()
            love.graphics.points(x, y)
        end
    end
end


function getPoints(object)
    local type = object.ClassName
    local points
    if type == "Block" then
        points = {
        object.Position,
        Vector.new(object.Position.x + object.Size.x, object.Position.y),
        Vector.new(object.Position.x + object.Size.x, object.Position.y + object.Size.y),
        Vector.new(object.Position.x, object.Position.y + object.Size.y),
        }

    elseif type == "Polygon" then
        points = {object.Position}
        local originX = object.Position.x
        local originY = object.Position.y
        local scale = object.Scale

        local v = object.Verticies
        for i = 1, #v do
           points[i + 1] = Vector.new((v[i][1] + originX) * scale, (v[i][2] + originY) * scale) 
        end
    end
    return points
end

function defineLines(object)
    local points = getPoints(object)
    if not points then print(object.Name, object.ClassName) end
    --replace object.name with objectid (still need implement)
    pointsToLines(points, object.Name)
end

function checkCollisions(name)
    local collisionList = {}
    for selectedLine, sObjectName in pairs(currentLines) do
        --makes sure we're only checking collisions for the specified object
        if sObjectName == name then
            for comparingLine, cObjectName in pairs(currentLines) do
                --makes sure we're not checking collisions for lines of the same object
                if sObjectName ~= cObjectName then
                    local result = solveEquation(selectedLine, comparingLine)
                    local sLType = selectedLine[1]
                    local cLType = comparingLine[1]

                    
                    if result then
                        if PRINT_COLLISION_EQUATIONS then
                            print("______________________________")
                            if sLType == "y" then
                                print(selectedLine[1] .." = ".. selectedLine[2].."x + "..selectedLine[3].. ", for " .. selectedLine[4][1] .. "<".. "x".."<"..selectedLine[4][2], sObjectName)
                            else 
                                print(selectedLine[1] .." = ".. selectedLine[2] .. ", for " .. selectedLine[3][1] .. "<".. "y".."<"..selectedLine[3][2], sObjectName)
                            end
                            if cLType == "y" then
                                print(comparingLine[1] .." = ".. comparingLine[2].."x + "..comparingLine[3].. ", for " .. comparingLine[4][1] .. "<".. "x".."<"..comparingLine[4][2], cObjectName)
                            else 
                                print(comparingLine[1] .." = ".. comparingLine[2] .. ", for " .. comparingLine[3][1] .. "<".. "y".."<"..comparingLine[3][2], cObjectName)
                            end
                            print("______________________________")
                        end
                        --in practice, we would rather have this be an event fired that can be connected in the psuedophysics class
                        table.insert(collisionList, {cObjectName, result})
                        --returns the name of the colliding objects and the location of the collision
                        --in practice, we would want to return a reference to the actual object and not the name
                    end
                    
                end
            end
        end
    end
    return collisionList
end

function inBounds(bound1, bound2, answer)
    local b1a = bound1[1]
    local b1b = bound1[2]

    if not bound2 then
        if (answer >= b1a and answer <= b1b) then
            return true
        else
            return false
        end
    end

    local b2a = bound2[1]
    local b2b = bound2[2]

    if answer == "l" then -- ONLY FOR WHEN YOU ARE COMPARING TWO LINES ON TOP OF EACH OTHER
        --[[b2a]]---[b1a]---[[b2b]]
        --b1b can be less than or greater then b2b, it doesnt matter
        if b1a >= b2a and b1a <= b2b then
            return (b1a + b2b)/2
        end

        --[[b2a]]---[b1b]---[[b2b]]
        --b1a can be less than or greater than b2a, it doesnt matter
        if b1b >= b2a and b1b <= b2b then
            return (b1b + b2a)/2
        end
    
        --[[b1a]]---[b2a]---[[b1b]]
        ---b2b can be less than or greater than b1b, it doesnt matter
        if b2a >= b1a and b2a <= b1b then
            return (b2a + b1b)/2
        end

        --[[b1a]]---[b2b]---[[b1b]]
        --b2a can be less than or greater than b1a, it doesnt matter
        if b2b >= b1a and b2b <= b1b then
            return (b1a + b2b)/2
        end
    elseif answer then
        --[[b1a]]---[answer]---[[b1b]]
        if (answer >= b1a and answer <= b1b) then
            --[[b2a]]---[answer]---[[b2b]]
            if (answer >= b2a and answer <= b2b) then
                return true
            end
        end
    end

    return false
end


function solveEquation(line1, line2)

    local line1Type = line1[1]
    local line2Type = line2[1]

    local result
    local answer = {}
    if line1Type== "x" then
        if line2Type == "x" then
            if line1[2] == line2[2] then
                result = inBounds(line1[3], line2[3], "l")
                if result then 
                    answer[1] = line1[2]
                    answer[2] = result
                end
            end
        elseif line2Type == "y" then
            if inBounds(line2[4], nil, line1[2]) then
                local y = line1[2] * line2[2] + line2[3]
                result = inBounds(line1[3], nil, y)
                if result then 
                    answer[1] = line1[2]
                    answer[2] = y
                end
            end
        end
    elseif line1Type == "y" then
        if line2Type == "x" then
            if inBounds(line1[4], nil, line2[2]) then
                local y = line2[2] * line1[2] + line1[3]
                result = inBounds(line2[3], nil, y)
                if result then
                    answer[1] = line2[2]
                    answer[2] = y
                end
            end
        elseif line2Type == "y" then
            local x = (line2[3] - line1[3]) / (line1[2] - line2[2])
            local y = x * line2[2] + line2[3]
            if math.abs(line1[2]) == 0 and math.abs(line2[2]) == 0 then
                if line1[3] == line2[3] then
                    result = inBounds(line1[4], line2[4], "l")
                    if result then
                        answer[1] = result
                        answer[2] = line1[3]
                    end
                end
            end
            if x then
                result = inBounds(line1[4], line2[4], x)
                if result then
                    answer[1] = x
                    answer[2] = y
                end
            end
        end
    end
    if result then return answer else return nil end
end
--[[
if  math.abs(slope) == math.huge then
    var = "x"
    bounds = order(points[i].y, points[i2].y)
    line = {var, points[i].x, bounds(y)}
else
    var = "y"
    bounds = order(points[i].x, points[i2].x)
    line = {var, slope, yIntercept, bounds(x)})
end
--]]

function getPoints(object)
    local type = object.ClassName
    local points
    if type == "Block" then
        points = {
        object.Position,
        Vector.new(object.Position.x + object.Size.x, object.Position.y),
        Vector.new(object.Position.x + object.Size.x, object.Position.y + object.Size.y),
        Vector.new(object.Position.x, object.Position.y + object.Size.y),
        }

    elseif type == "Polygon" then
        points = {object.Position}
        local originX = object.Position.x
        local originY = object.Position.y
        local scale = object.Scale

        local v = object.Verticies
        for i = 1, #v do
           points[i + 1] = Vector.new((v[i][1] + originX) * scale, (v[i][2] + originY) * scale) 
        end
    end
    return points
end

function pointsToLines(points, name)
    local line
    local i2
    local slope
    local yIntercept
    local var
    local bounds
    local lines = {}

    function findSlope(p1, p2)
        return ((p1.y - p2.y) / (p1.x - p2.x))
    end

    function findYIntercept(slope, p1)
        return (p1.y - slope * p1.x)
    end

    function order(a, b)
        if a > b then
            return {b, a}
        else
            return {a, b}
        end
    end
    
    for i = 1, #points do
        if i+1 <= #points then
            i2 = i+1
        else
            i2 = 1
        end

        slope = findSlope(points[i], points[i2])
        yIntercept = findYIntercept(slope, points[i])

        if  math.abs(slope) == math.huge then
            var = "x"
            bounds = order(points[i].y, points[i2].y)
            line = {var, points[i].x, bounds}
            --print(i..": ".. line[1] .." = ".. line[2] .. ", for " .. line[3][1] .. "<".. "y".."<"..line[3][2])
        else
            var = "y"
            bounds = order(points[i].x, points[i2].x)
            line = {var, slope, yIntercept, bounds}
           --print(i..": ".. line[1] .." = ".. line[2].."x + "..line[3].. ", for " .. line[4][1] .. "<".. "x".."<"..line[4][2])
        end

        currentLines[line] = name
    end
end


function printCollisions(object, collisionList)
    local oName = object.Name
    for i = 1, #collisionList do
        print(oName .. " collided with " .. collisionList[i][1] .. " at (" .. collisionList[i][2][1] .. ", " .. collisionList[i][2][2] .. ")")
    end
end

function velocityUpdate(object, dt)
    if object.Velocity.x == 0 and object.Velocity.x == 0 then return end
    local direction = getUnit(object.Velocity)
    local xScalar = object.Velocity.x
    local yScalar = object.Velocity.y
    local realVelocity = {direction[1] * xScalar, direction[2] * yScalar}
    object.Position.x = object.Position.x + realVelocity[1] * dt
    object.Position.y = object.Position.y + realVelocity[2] * dt
end

function getUnit(vector)
    local mag = math.sqrt((vector.x)^2 + (vector.y)^2)
    local newX = vector.x / mag
    local newY = vector.y / mag
    return {newX, newY}
end

API.moveTo = function(self, object, position)
    assertClass(object, "Block")
    object.Position = position
end



psuedoPhysics = API;
return API;
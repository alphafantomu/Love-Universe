local API = {};
local currentLines = {}
API.update = function(self, dt)
    local CurrentStack = psuedoWorkspace:getStack();
    currentLines = {}
    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') then
            velocityUpdate(actualObject, dt)
            defineLines(actualObject)
            checkCollisions()
        end

    end
end

function checkCollisions()
    for selectedLine, name in pairs(currentLines) do
        for comparingLine, name2 in pairs(currentLines) do
            if name ~= name2 then
                print(solveEquation(selectedLine, comparingLine))
            end
        end
    end
end

function inBounds(bound1, bound2)
    local b1a = bound1[1]
    local b1b = bound1[2]

    local b2a = bound2[1]
    local b2b = bound2[2]
    if (b1a >= b2a and b1a <= b2b) and b1b >= b2a then
        return true
    end

    if (b1b >= b2a and b1b <= b2b)  and b1a <= b2b then
        return true
    end

    if (b2a >= b1a and b2a <= b1b) and b2b >= b1a then
        return true
    end

    if (b2b >= b1a and b2b <= b1b)  and b2a <= b1b then
        return true
    end
    

    return false

end

function solveEquation(line1, line2)
    local result = false
    if line1[1] == "x" then
        if line2[1] == "x" then
            result = inBounds(line1[3], line2[3])
        elseif line2[1] == "y" then
            local y = line1[2] * line2[2] + line2[3]
            result = inBounds({y,y}, line2[4])
        end
    elseif line1[1] == "y" then
        if line2[1] == "x" then
            local y = line2[2] * line1[2] + line1[3]
            result =  inBounds({y,y}, line1[4])
        elseif line2[1] == "y" then
            local x = (line2[3] - line1[3]) / (line1[2] - line2[2])
            if line1[4][2] - line1[4][1] > line2[4][2] - line2[4][1] then
                result =  inBounds({X,x}, line2[4])
            else
                result =  inBounds({x,x}, line1[4])
            end
        end
    end
    return result
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
function assertClass(object, desiredClass)
    assert(object.ClassName == "Block", object.ClassName .. "class cannot use this function")
end

function defineLines(object)
    local type = object.ClassName
    --when defining polygons, give them a table that includes location of all their points relative to the main point (top left corner)
    --in future, use ^^^ to get list of p1, p2, p3, ...
    if type == "Block" then
        local points = {
        object.Position,
        Vector.new(object.Position.x + object.Size.x, object.Position.y),
        Vector.new(object.Position.x + object.Size.x, object.Position.y + object.Size.y),
        Vector.new(object.Position.x, object.Position.y + object.Size.y),
        }
        --print(1, #points)
        pointsToLines(points, object.Name)

    end
end

function vectorToString(vector)
    return("("..vector.x..", "..vector.y..")")
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

    function order(a, b) -- MAKE A CASE FOR WHEN A = B
        if a > b then
            return {b, a}
        else
            return {a, b}
        end
    end
    
   -- print(#points)
    for i = 1, #points do
        if i+1 <= #points then
            i2 = i+1
        else
            i2 = 1
        end
        slope = findSlope(points[i], points[i2])
        yIntercept = findYIntercept(slope, points[i])
        line = {slope, yIntercept}
        if  math.abs(slope) == math.huge then
            var = "x"
            bounds = order(points[i].y, points[i2].y)
            line = {var, points[i].x, bounds}
           -- print(i..": ".. line[1] .." = ".. line[2] .. ", for " .. line[3][1] .. "<".. "y".."<"..line[3][2])
        else
            var = "y"
            bounds = order(points[i].x, points[i2].x)
            line = {var, slope, yIntercept, bounds}
           -- print(i..": ".. line[1] .." = ".. line[2].."x + "..line[3].. ", for " .. line[4][1] .. "<".. "y".."<"..line[4][2])
        end

        currentLines[line] = name
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
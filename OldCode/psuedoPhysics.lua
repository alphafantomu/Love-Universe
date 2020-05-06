local API = {};

API.update = function(dt)
    local CurrentStack = psuedoWorkspace:getStack();
    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') then
            velocityUpdate(actualObject)
        end

    end
end

function assertClass(object, desiredClass)
    assert(object.ClassName == "Block", object.ClassName .. "class cannot use this function")
end

function checkCollisions(object)
    local x1 = object.Position
    local x2 = x1 + object.Size.x
    local y1 = x1
    local y2 = y1 + object.Size.Y

    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') then
            velocityUpdate(object)
        end

    end

end

function velocityUpdate(object)
    local newV = getUnit(object.Velocity)
    object.Position.x = object.Position.x + newV[1]
    object.Position.y = object.Position.y + newV[2]
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

API.setWorld = function()
    local world = love.physics.newWorld(0, 0, false)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)
    return world
end

function beginContact(objectA, objectB, objectColl)
    print(objectA.Name .. "just collided with " .. objectB.Name)
end

function endContact(objectA, objectB, objectColl)
    print(objectA.Name .. "just stopped colliding with " .. objectB.Name)
end

function preSolve(objectA, objectB, objectColl)
    print(objectA.Name .. "is currently colliding with " .. objectB.Name)
end

function postSolve(objectA, objectB, objectColl, normalV, tangentV)
   -- print(objectA.Name .. "just collided with " .. objectB.Name)
end


psuedoPhysics = API;
return API;
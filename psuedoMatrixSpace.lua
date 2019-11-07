
--[[
    array = {
        [x..':'..y] = {x, y};
    }
]]
local API = {
    dx = 1;
    dy = 1;
};

spacedOccupied = {};

getSpaceCoordinates = function(arr, val)
    return arr[val[1]..':'..val[2]];
end;

local spaceExists = function(arr, val)
    return getSpaceCoordinates(arr, val) ~= nil;
end;

local spacialPlane = newproxy(true);
local meta = getmetatable(spacialPlane);
meta.__index = function(self, index)
    if (type(index):lower() == 'table') then
        local exists = spaceExists(spacedOccupied, index);
        if (exists == true) then
            return 1;
        elseif (exists == false) then
            return 0;
        end;
    end;
end;
--space[{5, 2}] = true;

meta.__newindex = function(self, index, value)
    if (type(index):lower() == 'table' and type(value):lower() == 'boolean') then
        local exists = spaceExists(spacedOccupied, index);
        if (value == true) then --we want this value to exist
            if (exists == false) then --it doesnt exist yet
                spacedOccupied[index[1]..':'..index[2]] = index;
            elseif (exists == true) then --it exists?? That means there must be another object that's colliding.
                
            end;
        elseif (value == false) then --we want this value to not exist
            if (exists == true) then --this already exists, we want to remove
                local coords = getSpaceCoordinates(spacedOccupied, index);
                if (coords ~= nil) then
                    spacedOccupied[index[1]..':'..index[2]] = nil;
                end;
            end;
        end;
    end;
end;
meta.__metatable = 'Locked';
meta.__tostring = function()
    return 'Spacial Plane';
end;

--spacialPlane has to reset every frame
analyzeBlock = function(block)
    local dx = 1;
    local dy = 1;
    local Size = block.Size;
    local Position = block.Position;
    local Ac = Size.x;
    local Ar = Size.y;
    local elementalc = Size.x/dx;
    local elementalr = Size.y/dy;
    local eposc = Ac/elementalc;
    local eposr = Ar/elementalr;
    for c = 0, elementalc do
        for r = 0, elementalr do
            local ctox = Position.x + (eposc * c);
            local rtoy = Position.y + (eposr * r);
            local coords = {ctox, rtoy};
            spacialPlane[coords] = true;
        end;
    end;
end;

love.handlers.blockMoved = function(block)
    --we need to actively change elements that the block occupies in the plane.
    --convert a square into a whole chunk of elements
    --find the x and y coordinates of the elements
    --input into the matrix space

    --we'll just redfine our theorems in local space, so position = 0, 0
    analyzeBlock(block);
end;

API.spacialPlane = spacialPlane;

psuedoMatrixSpace = API;
return API;
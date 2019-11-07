
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
    local exists = spaceExists(spacedOccupied, index);
    if (exists == true) then
        return 1;
    end;
    return 0;
end;
--space[{5, 2}] = true;

meta.__newindex = function(self, index, value)
    if (type(index):lower() == 'table' and type(value):lower() == 'boolean') then
        local exists = spaceExists(spacedOccupied, index);
        if (value == true and exists == false) then --we want this value to exist
            spacedOccupied[index[1]..':'..index[2]] = index;
        elseif (value == true and exists == true) then
            --collision occurs here
            print'hey! collision is occuring!';
        elseif (value == false) then --we want this value to not exist
            if (exists == true and spaceExists(spacedOccupied, index) == true) then --this already exists, we want to remove
                spacedOccupied[index[1]..':'..index[2]] = nil;
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
    local Size = block.Size;
    local Position = block.Position;
    local elementalc = Size.x/API.dx;
    local elementalr = Size.y/API.dy;
    local eposc = Size.x/elementalc;
    local eposr = Size.y/elementalr;
    for c = 0, elementalc do
        for r = 0, elementalr do
            spacialPlane[{Position.x + (eposc * c), Position.y + (eposr * r)}] = true;
        end;
    end;
end;

API.spacialPlane = spacialPlane;

psuedoMatrixSpace = API;
return API;

--[[
    local Vector = Vector.new(5, 3);
    Vector.Magnitude --this has to be constantly calculated
    Vector.Unit --this has to be constantly calculated

    local newVector = Vector * Vector;
]]
local API = {};
local types = {};
local userdataCache = {};

API.standardType = type;

API.createType = function(self, classType) --creates an object of type
    assert(types[classType] ~= nil, classType..' does not exist as a userdata class');
	local data = newproxy(true);
	local meta = getmetatable(data);
	local psuedostasis = {};
	meta.__index = function(self, index)
		return rawget(psuedostasis, index) or rawget(types[classType], index);
	end;
	meta.__newindex = function(self, index, value)
    	if (rawget(types[classType], index) ~= nil) then --have to make sure it exists
         	if (type(rawget(types[classType], index)) == type(value)) then --some variables can have multiple types, we need to modify this at some point
            	return rawset(psuedostasis, index, value);
			end;
    	end;
    end;
    meta.__tostring = function(self) 
        return classType;
    end;
    meta.__metatable = 'Locked';
    userdataCache[data] = meta;
    return data;
end;

API.newType = function(self, name, dictionary) --creates a new type itself
    types[name] = dictionary;
end;

API.getTypeMetadata = function(self, var)
    return userdataCache[var];
end;

API.modType = function(self, var)
    local defaultType = API.standardType(var);
    local low = defaultType:lower();
    if (low == 'userdata') then
        if (userdataCache[var] ~= nil) then
            return userdataCache[var]:__tostring();
        end;
    end;
    return defaultType;
end;

API:newType('Vector', {
    x = 0;
    y = 0;
}, {
    __add = function(self, )
})
API:newType('Color', {
    r = 0;
    g = 0;
    b = 0;
});

API:newType('Vector', {
    x = 0;
    y = 0;
});

API:newType('Ray', {
    status = false;
})

--the global variable itself is connected since by doing Block.Position, we're grabbing the vector that's already preset in the class, we need to make a new class everytime its changed
Vector = setmetatable({
    new = function(x, y)
        local obj = API:createType('Vector');
        obj.x = x;
        obj.y = y;
        return obj;
    end;
}, {
    __newindex = function(self, index, value)
        fatal('Attempt to add a new index ('..tostring(index)..') to Vector');
        return nil;
    end;
    __metatable = 'Locked';
})

psuedoObjects = API;
type = function(var)
    return API:modType(var);
end;

return API;
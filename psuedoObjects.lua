
--[[
    local Vector = Vector.new(5, 3);
    Vector.Magnitude --this has to be constantly calculated
    Vector.Unit --this has to be constantly calculated

    local newVector = Vector * Vector;
]]
local API = {};
local types = {}; --type data
local userdataCache = {}; --essentially a "stack" for all types
API.standardType = type;

API.parseProperties = function(self, obj, properties)
    local propApi = {};
    propApi.GetProperty = function(self, index)
        for i, v in next, properties do
            if (type(v):lower() == 'table') then
                if (v.index == index) then
                    return v;
                end;
            end;
        end;
    end;
    propApi.PropertyExists = function(self, index)
        return propApi:GetProperty(index) ~= nil;
    end;
    propApi.GetDefaultValue = function(self, index)
        local property = propApi:GetProperty(index);
        if (property.function_dependent == true) then
            if (type(property.default):lower() == 'function') then
                return property.default(obj); --send the object
            end;
        end;
        return property.default;
    end;
    --[[
        Only times when you can rewrite are
        - when the default value isn't a function AND IsCallback is false
        - when the default value is a function AND IsCallback is true
    ]]
    propApi.CanRewrite = function(self, index) --uhh wtf?, so basically standard 
        local default = propApi:GetDefaultValue(index);
        local property = propApi:GetProperty(index);
        return (type(default):lower() ~= 'function' and property.is_callback == false) or (type(default):lower() == 'function' and property.is_callback == true);
    end;
    propApi.NewValueAcceptable = function(self, index, value) --uhhhhh wtf?!?!?!
        local default = propApi:GetDefaultValue(index);
        return API:modType(default):lower() == API:modType(value):lower(); --needs to be replaced with the modified type
    end;
    return propApi;
end;

API.createType = function(self, classType) --creates an object of type
    assert(types[classType] ~= nil, classType..' does not exist as a userdata class');
	local data = newproxy(true);
	local meta = getmetatable(data);
    local stasis = {};
    local typeData = types[classType];
    local dictionary = typeData[1];
    local methods = typeData[2];
    for i, v in next, methods do
        meta[i] = v;
    end;
    local parsedDictionary = API:parseProperties(data, dictionary);
    meta.__index = function(self, index)
        local value = rawget(stasis, index);
        local Property = parsedDictionary:GetProperty(index);
        assert(parsedDictionary:PropertyExists(index), 'Property doesn\'t exist');
        assert(Property.edit_mode == 1 or Property.edit_mode == 3, 'Cannot read this property');
        return value or parsedDictionary:GetDefaultValue(index);
    end;
    meta.__newindex = function(self, index, value)
        local Property = parsedDictionary:GetProperty(index);
        assert(parsedDictionary:PropertyExists(index), 'Property doesn\'t exist');
        assert(Property.edit_mode == 2 or Property.edit_mode == 3, 'Cannot write this property');
        assert(Property.function_dependent == false, 'Cannot write to a property that\'s function dependent');
        assert(parsedDictionary:CanRewrite(index), 'Cannot write a function');
        assert(parsedDictionary:NewValueAcceptable(index, value), 'Attempt to write '..index..' to a '..type(value));
        rawset(stasis, index, value);
    end;
    meta.__tostring = function(self) 
        return classType;
    end;
    meta.__metatable = 'Locked';
    userdataCache[data] = meta;
    return data;
end;

API.newType = function(self, name, dictionary, methods) --creates a new type itself
    types[name] = {dictionary, methods};
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
--[[
    0 - no edit
    1 - readonly
    2 - writeonly
    3 - read+writeonly
]]
API:newType('Vector', {
    {
        index = 'x';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'y';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'Magnitude';
        function_dependent = true;
        is_callback = false;
        default = function(self)
            return math.sqrt(self.x^2 + self.y^2);
        end;
        edit_mode = 1;
    };
}, {
    --[[__add = function(vector1, vector2)

    end;
    __sub = function(vector1, vector2)

    end;
    __mul = function(vector1, vector2)

    end;
    __div = function(vector1, vector2)

    end;]]
});

API:newType('Color', {
    {
        index = 'r';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'g';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
    {
        index = 'b';
        function_dependent = false;
        is_callback = false;
        default = 0;
        edit_mode = 3;
    };
}, {});
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
Color = setmetatable({
    new = function(r, g, b)
        local obj = API:createType('Color');
        obj.r = r;
        obj.g = g;
        obj.b = b;
        return obj;
    end;
}, {
    __newindex = function(self, index, value)
        fatal('Attempt to add a new index ('..tostring(index)..') to Color');
        return nil;
    end;
    __metatable = 'Locked';
})
psuedoObjects = API;
type = function(var)
    return API:modType(var);
end;

return API;
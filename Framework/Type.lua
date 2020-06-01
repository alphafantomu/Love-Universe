
--[[
    local Vector = Vector.new(5, 3);
    Vector.Magnitude --this has to be constantly calculated
    Vector.Unit --this has to be constantly calculated

    local newVector = Vector * Vector;
]]
local API = {};
local types = {}; --type data
local originalType = type;
local Metatables = {};
local getrawmetatable = function(obj)
    return Metatables[obj];
end;
--API.type = originalType;
local BasePropertyAPI = {
    getProperty = function(self, index)
        for i, v in next, self.Properties do
            if (type(v):lower() == 'table') then
                if (v.index == index) then
                    return v;
                end;
            end;
        end;
    end;
    PropertyExists = function(self, index, callback)
        assert(callback ~= nil, 'Callback for PropertyExists does not exist');
		local Property = self:getProperty(index)
		return callback(Property ~= nil, Property);
    end;
    GetDefaultValue = function(self, index)
        local property = self:getProperty(index);
        if (property.function_dependent == true and type(property.default):lower() == 'function') then
            return property.default(self.Object); --send the object
        end;
        return property.default;
    end;
    CanRewrite = function(self, index) --uhh wtf?, so basically standard 
        local default = self:GetDefaultValue(index);
        local property = self:getProperty(index);
        return (type(default):lower() ~= 'function' and property.is_callback == false) or (type(default):lower() == 'function' and property.is_callback == true);
    end;
    NewValueAcceptable = function(self, index, value) --uhhhhh wtf?!?!?!
        local default = self:GetDefaultValue(index);
        return API:modType(default):lower() == API:modType(value):lower(); --needs to be replaced with the modified type
    end;
};

API.parseProperties = function(self, obj, properties)
    local API = {};
    API.Object = obj;
    API.Properties = properties;
    for i, v in next, BasePropertyAPI do --optimized, are not writing functions like a mad man
        API[i] = v;
    end;
    return API;
end;

API.forceNewIndex = function(self, obj, index, value)
    local meta = getrawmetatable(obj);
    local stasis = meta.stasis;
    rawset(stasis, index, value);
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
	local locked_indexes = {};
	local changesAttached = {};
	local attachIndex = {};
    meta.stasis = stasis;
    meta.__call = function(self, cmd, ...)
        local indexes = {...};
        if (cmd ~= nil and type(cmd):lower() == 'string') then
            if (cmd == 'lock') then
                for i = 1, #indexes do
                    locked_indexes[indexes[i]] = 0;
                end;
            elseif (cmd == 'unlock') then
                for i = 1, #indexes do
                    locked_indexes[indexes[i]] = nil;
                end;
            elseif (cmd == 'attachChange') then
				local Object, Index = unpack(indexes);
				local CalculatedIndex = #changesAttached + 1;
				changesAttached[CalculatedIndex] = {Object, Index};
				attachIndex[Object] = CalculatedIndex;
			elseif (cmd == 'detachChange') then
				local Object = unpack(indexes);
				local CalculatedIndex = attachIndex[Object];
				changesAttached[CalculatedIndex] = nil;
				attachIndex[Object] = nil;
            end;
        end;
        return data;
    end;
    meta.__index = function(self, index)
        if (index == 'ClassName') then
            return classType;
        end;
        local Property = parsedDictionary:getProperty(index);
        assert(Property ~= nil, 'Property doesn\'t exist');
        assert(Property.edit_mode == 1 or Property.edit_mode == 3, 'Cannot read this property');
        local Value = rawget(stasis, index);
        if (Value == nil) then
            return parsedDictionary:GetDefaultValue(index);
        end;
        return Value;
    end;
    
    meta.__newindex = function(self, index, value)
        local Property = parsedDictionary:getProperty(index);
        assert(Property ~= nil, 'Property doesn\'t exist');
        assert(Property.edit_mode == 2 or Property.edit_mode == 3, 'Cannot write this property');
        assert(Property.function_dependent == false, 'Cannot write to a property that\'s function dependent');
        assert(parsedDictionary:CanRewrite(index), 'Cannot write a function');
        assert(parsedDictionary:NewValueAcceptable(index, value), 'Attempt to write '..index..' to a '..type(value));
        if (locked_indexes[index] == nil) then
			rawset(stasis, index, value);
			for i = 1, #changesAttached do
                local Data = changesAttached[i];
                if (Data ~= nil) then
					local UniObject, Index = unpack(Data);
					local Manager = Ripple:ManageRipple('Changed');
                    Manager:FireRippleProcessorConnections(UniObject, Index, self);
					if (Object.PropertyChanged ~= nil) then
						local ManageRipple = Ripple:ManageRipple('PropertyChanged');
                        ManageRipple:FireConnections(UniObject, Index, self);
					end;
				end;
			end;
        end;
    end;
    meta.__tostring = function(self) --we didnt do the same thing in Object.lua because it did some intensive weird shit and I couldn't handle it because it gave me a fucking headache.
        return classType;
    end;
    meta.__metatable = 'Locked';
    Metatables[data] = meta;
    return data;
end;

API.newType = function(self, name, dictionary, methods) --creates a new type itself
    types[name] = {dictionary, methods};
end;

API.modType = function(self, var)
    local defaultType = originalType(var);
    local low = defaultType:lower();
    if (low == 'userdata') then
        local meta = getrawmetatable(var);
        if (meta ~= nil) then
            return meta.__tostring(meta.__object);
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

type = function(var)
    return API:modType(var);
end;

CustomTypes = API;
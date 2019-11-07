
--[[
    ok so apparently the FUCKING PROPERTIES FOR SELF-CREATED PROPERTIES ARE SHARED BETWEEN EACH OTHER LIKE DF???
]]
local http = require('socket.http'); --Http extension for lua, provides socket usage etc

local API = {}; --main psuedoWorkspace API framework
local Classes = {}; --contains all the classes that you can create objects from, information about the class included
local Stack = {}; --Psuedo Environment Memory
local NullStack = {}; --this is actually equivalent to the children_stack standard objects have
local Singularities = {}; --container storage for services, where only one service can exist
local Worlds = {};
--local Runtime = {};
--[[
    Worlds[worldName] = {

        Utilities = {};
    }
]]
--so apparently null objects are considered objects rather than a namespace like in roblox's environment. Most likely to avoid weird ass errors but some of the functions are unusuable since the object itself doesn't have a physical object like a standard object does.
API.NullMetatable = {
    __isPartOfChildren = function(self, obj)
        return NullStack[obj] ~= nil;
    end;
    __addChildren = function(self, ...)
        local adding = {...};
        for i, v in next, adding do
            if (NullStack[v] == nil) then
                NullStack[v] = v;
                if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = nil;
                end;
            end;
        end;
    end;
    __getChildren = function(self)
        local children = {};
        for i, v in next, NullStack do
            table.insert(children, v);
        end;
        return children;
    end;
    __removeChildren = function(self, ...)
        local removing = {...};
        for i, v in next, removing do
            if (NullStack[v] ~= nil) then
                NullStack[v] = nil;
                if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = nil;
                end;
            end;
        end;
    end;
};

API.stringRandom = function(self, max, includeNumbers)
	local str = '';
	for i = 1, max or 0 do
		local randomLimit = 1;
		if (includeNumbers == true or includeNumbers == nil) then
			randomLimit = 2;
		end;
		local chanceOfWords = math.random(1, randomLimit);
		if (chanceOfWords == 1) then
			local capital = math.random(1, 2);
			local min, max;
			if (capital == 1) then
				min = 65;
				max = 90;
			elseif (capital == 2) then
				min = 97;
				max = 122;
			end;
			str = str..tostring(string.char(math.random(min or 97, max or 122)));
		elseif (chanceOfWords == 2) then
			str = str..tostring(string.char(math.random(48, 57)));
		end;
	end;
	return str;
end;

API.parseProperties = function(self, obj, properties) --properties is the class data supplied
    local propApi = {};
    propApi.getProperty  = function(self, index) --get the property data
        for i, v in next, properties do
            if (type(v):lower() == 'table') then
                if (v.Name == index) then
                    return v;
                end;
            end;
        end;
    end;
    propApi.PropertyExists = function(self, index) --make sure the property exists
        return propApi:getProperty(index) ~= nil;
    end;
    propApi.GetDefaultValue = function(self, index)  --get the default value of properties
        local property = propApi:getProperty(index);
        if (property.Generator == true) then
            if (type(property.Default):lower() == 'function') then
                return property.Default(obj); --send the object
            end;
        end;
        return property.Default;
    end;
    --[[
        Only times when you can rewrite are
        - when the default value isn't a function AND IsCallback is false
        - when the default value is a function AND IsCallback is true
    ]]
    propApi.CanRewrite = function(self, index) --uhh wtf?, so basically standard 
        local default = propApi:GetDefaultValue(index);
        local property = propApi:getProperty(index);
        return (type(default):lower() ~= 'function' and property.IsCallback == false) or (type(default):lower() == 'function' and property.IsCallback == true);
    end;
    propApi.NewValueAcceptable = function(self, index, value) --uhhhhh wtf?!?!?!
        local default = propApi:GetDefaultValue(index);
        return psuedoObjects:modType(default):lower() == psuedoObjects:modType(value):lower(); --needs to be replaced with the modified type
    end;
    return propApi;
end;

API.isWorldObject = function(self, obj)
    return Worlds[obj] ~= nil;
end;

API.getFirstAncestor = function(self, obj)
    if (obj == nil) then return nil; end;
	local firstAncestor = obj;
	local locatedAncestor = false;
	repeat
		local nextAncestor = firstAncestor.Parent;
		if (nextAncestor == nil) then
			locatedAncestor = true;
			break;
		else
			firstAncestor = nextAncestor;
		end;
	until 
		locatedAncestor == true;
	return firstAncestor;
end;

API.newObject = function(self, className, parent)
    assert(Classes[className] ~= nil, className..' Class does not exist'); --We need to check if the class actually exists first
    local obj = newproxy(true);
    local meta = getmetatable(obj);
    local classdata = Classes[className]; --get information about the class
    --Service limited to only 1 object per world
    if (className == 'World' and Worlds[obj] == nil) then
        Worlds[obj] = {
            Utilities = {};
        };
    end;
    if (classdata.Limited == true) then
        if (parent ~= nil) then
            local getObjectWorld = API:getFirstAncestor(parent);
            assert(Worlds[getObjectWorld].Utilities[classdata.Name] == nil, 'Object already exists'); --Error is service already exists
            Worlds[getObjectWorld].Utilities[classdata.Name] = obj;
        end;
        --[[assert(Singularities[classdata.Name] == nil, 'Object already exists'); --Error is service already exists
        Singularities[classdata.Name] = obj;]]
    end;
    --[[g
        !! I have to fix the table replicator and also I have to add support for default properties and standard properties
    ]]
    local children_stack = {};
    local defaultProperties = { --omg this has to be hard coded kms
        ClassName = classdata.Name;
        Parent = parent or nil;
        Destroy = function(self)
            local descendant = obj.Parent;
            if (Stack[descendant].__object ~= nil) then
                Stack[descendant].__metatable:__removeChildren(obj);
            end;
            Stack[obj] = nil;
            return Stack[obj] == nil;
        end;
        FindChild = function(self, name)
            local all = meta:__getChildren();
            for i, v in next, all do
                if (v.Name == name) then
                    return v;
                end;
            end;
        end;
        IsA = function(self, className)
            return className == classdata.Name;
        end;
        GetChildren = function(self)
            return meta:__getChildren();
        end;
        ClearAllChildren = function(self)
            for i, v in next, meta:__getChildren() do
                v:Destroy();
            end;
        end;
    };
    --[[
        This is a little strange, but there are three different type of properties:
        - Class Properties - Pre-defined properties for a certain class, not actively changing and is only used as reference
        - Default Properties - Properties at the inherit level, also actively changing but is also universal over all instances, in roblox
        this would be described as the <<<ROOT>>> class or the Instance base class.
        - Standard Properties - Properties at the surface level, actively changing etc.
    ]]
    local standardProperties = {}; --the new set being written
    local classProperties = classdata.Properties;
    local parsed = API:parseProperties(obj, classProperties);
    meta.__index = function(self, index)
        if (Stack[obj] == nil and obj ~= nil) then
            --print('Memory warning: You\'re trying to interact with an object that\'s not part of the stack');
        end;
        if (parsed:PropertyExists(index) == true) then --if the property exists in class properties
            local property = parsed:getProperty(index);
            assert(property.EditMode == 1 or property.EditMode == 3, 'Property '..index..' cannot be read');
            --this was confusing at first, but essentially
            --[[
                this is assuming "index" exists in class properties, like "Name" or something
                if "index" doesn't exist in standard properties, then we're basically setting it for standard properties
                so that it exists, value being the default value. Then it'll grab the index or the default value if it's somehow missing?
            ]]
            if (rawget(standardProperties, index) == nil and property.Generator == true) then
                rawset(standardProperties, index, parsed:GetDefaultValue(index));
            end;
            return rawget(standardProperties, index) or parsed:GetDefaultValue(index);
        end;
        return rawget(defaultProperties, index) or rawget(defaultProperties, 'FindChild')(obj, index); --find index in default 
    end;
    --[[
        meta.__index will be fired when we're trying to find a default property FIRST, a standard property SECOND, and lastly one of their own children THIRD
    ]]
    meta.__newindex = function(self, index, value) 
        --print(index, value);
        local isParent = false;
        if (index ~= 'Parent') then
            if (defaultProperties[index] == nil) then
                if (parsed:PropertyExists(index) == false) then
                    assert(false, 'Property cannot be found');
                end;
            end;
        else
            isParent = true;
        end;
        if (isParent == false) then
            assert(parsed:PropertyExists(index), 'Property cannot be found');
        end;
        if (Stack[obj] == nil and obj ~= nil) then
            --print('Memory warning: You\'re trying to interact with an object that\'s not part of the stack');
        end;
        if (parsed:PropertyExists(index) == true) then
            local property = parsed:getProperty(index);
            assert(property.EditMode == 2 or property.EditMode == 3, 'Property '..index..' cannot be rewritten');
        end;
        --this is the parenting functionality, need to fix objects parenting themselves and attaching utilities to new worlds
        if (type(index):lower() == 'string') then
            if (index == 'Parent') then --special condition for index "Parent"
                return pcall(function()
                    failure(value ~= obj, 'Attempting to change the parent of an object to itself');
                    --value is the actual object
                    if (value ~= rawget(defaultProperties, 'Parent') and value ~= obj) then --don't let it through if we're literally just spamming the parent to itself
                        --where it says NewParentObject and OldParentObject, we're targeting the STACK OBJECT, not the actual object itself.
                        local NewParentObject = Stack[value] or {__metatable = API.NullMetatable;}; --if the new parent is found in memory or replace with nil
                        local OldParentObject = Stack[rawget(defaultProperties, 'Parent')] or {__metatable = API.NullMetatable;}; --if the old parent is found in memory or replace with nil
                        --NewParentObject is the parent we're trying to set to
                        --OldParentObject is the current parent we're grabbing the object 
                        local NewMeta, OldMeta = NewParentObject.__metatable, OldParentObject.__metatable; --grab both parent's metatables
                        --obj is described as OldMeta, the actual object not the stack object
                        --print(NewMeta:__isPartOfChildren(obj), OldMeta:__isPartOfChildren(obj), OldMeta == API.NullMetatable);
                        --[[
                            NewMeta.obj == nil; --the new parent doesn't have the object
                            OldMeta.obj ~= nil; --the old parent has the object

                            NewMeta.obj == nil --the new parent doesn't have the object
                            OldMeta == nil; --the current parent doesn't exist
                        ]]
                        if (NewMeta:__isPartOfChildren(obj) == false and --have to make sure the new parent already doesn't have the object
                            OldMeta:__isPartOfChildren(obj) == true or  --and we have to make sure the old parent already has the object in its children
                            NewMeta:__isPartOfChildren(obj) == false and --or we can check that the new parent doesnt have the object
                            OldMeta == API.NullMetatable) then --and make it so that it's okay if the old parent is actually nil
                            --[[
                                part.Parent = workspace;
                                part.Parent = nil;
                            ]]
                            --if the old parenting and new parenting checks are passed, then
                            --shit we need to remove utilities if it's ever destroyed
                            if (classdata.Limited == true) then --probably means the obj is one per world, probably a utility
                                local getCurrentWorld = API:getFirstAncestor(rawget(defaultProperties, 'Parent'));
                                failure(getCurrentWorld == nil, 'Utility already in parent of another world');
                                assert(getCurrentWorld == nil, 'Utility already in parent of another world');
                                if (getCurrentWorld == nil) then --new utility doesn't exist in a world yet
                                    --then we need to check if the new parent has an ancestor that's a world
                                    local nextWorld = API:getFirstAncestor(NewParentObject.__object);
                                    if (nextWorld ~= nil) then --if it doesn't exist then, we'll assume it's also nil, so shit
                                        if (Worlds[nextWorld] == nil) then
                                            Worlds[nextWorld] = {
                                                Utilities = {};
                                            };
                                        end;
                                        if (Worlds[nextWorld].Utilities[classdata.Name] == nil) then
                                            Worlds[nextWorld].Utilities[classdata.Name] = obj;
                                        end;
                                    end;
                                end;
                            end;
                            OldMeta:__removeChildren(obj); --we need to remove the old parent's object from its children
                            if (OldMeta:__isPartOfChildren(obj) == false) then --we need to make sure that the old parent no longer has the object in their children
                                NewMeta:__addChildren(obj); --if it passes then the new parent will inherit the object in its children
                                rawset(defaultProperties, 'Parent', NewParentObject.__object); --we need to set the parent property of properties to the new object
                            else
                                OldMeta:__addChildren(obj); --for some fucking reason it failed, so uhh we have to add the obj back into the old parent just incase
                                if (rawget(defaultProperties, 'Parent') ~= OldParentObject.__object) then
                                    rawset(defaultProperties, 'Parent', OldParentObject.__object); --we need to set the parent property of properties to the old object JUST INCASE
                                end;
                            end;
                        end;
                        
                    end;
                end);

            end;
        end;
        --[[
            we need to modify the canceling method, because now we want callbacks to be implemented
        ]]
        if (defaultProperties[index] ~= nil and parsed:PropertyExists(index) == true) then --prioritize default properties
            --default properties probably shouldn't have any callbacks
            assert(type(defaultProperties[index]):lower() ~= 'function', 'Property cannot be overrided'); --can't override functions at all
            assert(index ~= 'ClassName', 'Property ClassName cannot be overrided');
            if (psuedoObjects:modType(value):lower() == psuedoObjects:modType(defaultProperties[index]):lower()) then --must be the same type
                rawset(defaultProperties, index, value);
            end;
        elseif (parsed:PropertyExists(index) == true) then --secondary standard properties
            assert(parsed:CanRewrite(index), 'Property cannot be overrided');
            assert(parsed:NewValueAcceptable(index, value), 'Property type not acceptable');
            rawset(standardProperties, index, value);
        end;
    end;
    --[[
        meta.__index will be fired when we want to rewrite a property of the object to something new.
        if the property is parent then we need to make a custom function for when someone wants to override it.
            if the new parent isnt the old parent then
                we want to get the core functions of both parents


    ]]
    meta.__tostring = function(self)
        local TrueName = rawget(standardProperties, 'Name') or parsed:GetDefaultValue('Name');
        if (Stack[obj] == nil and obj ~= nil) then
            return 'Object removed from stack';
        end;
        return TrueName;
    end;
    --[[
        meta.__tostring will be fired whenever you try to print the object, it'll come out as whatever the object is named as.
    ]]

    meta.__isPartOfChildren = function(self, child)
        return children_stack[child] ~= nil;
    end;
    meta.__addChildren = function(self, ...)
        local adding = {...};
        for i, v in next, adding do
            if (children_stack[v] == nil) then
                children_stack[v] = v;
                if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = obj;
                end;
            end;
        end;
    end;
    meta.__getChildren = function(self)
        local children = {};
        for i, v in next, children_stack do
            table.insert(children, v);
        end;
        return children;
    end;
    meta.__removeChildren = function(self, ...) --I just realize I have to replicate this on the actual objects themselves
        --because this function currently only changes the current object stack, but we have to also change the stack's children parenting to match its new object parent
        local removing = {...};
        for i, v in next, removing do
            if (children_stack[v] ~= nil) then
                children_stack[v] = nil;
                if (Stack[v] ~= nil) then
                    local Object = Stack[v].__object;
                    Stack[v].__object.Parent = nil;
                    local ClassName = Object.ClassName;
                    local classdata = Classes[ClassName];
                    if (classdata.Limited == true) then --probably means the obj is one per world, probably a utility
                        local getCurrentWorld = API:getFirstAncestor(Object.Parent);
                        if (Worlds[getCurrentWorld] ~= nil) then
                            Worlds[getCurrentWorld].Utilities[classdata.Name] = nil;
                        end;
                    end;
                end;
                --check if v is a utility, if it is, then remove
            end;
        end;
    end;


    meta.__metatable = 'Locked';
    --[[
        We need to add all the userdatas to the stack memory
    ]]
    local hashIdentify;
    repeat hashIdentify = self:stringRandom(255, true); until API:getStackObjectByHash(hashIdentify) == nil;
    Stack[obj] = {
        __hash = self:stringRandom(255, true); --object identification
        __object = obj;
        __metatable = meta;
        --__Runtime = runtime_data;
    };
    --[[if (classdata.Runtime ~= nil) then
        Runtime[runtime_data.functionIndex] = runtime_data.void;
    end;]]

    if (Stack[parent] ~= nil) then --stack object exists?
        local StackObject = Stack[parent];
        local meta = StackObject.__metatable;
        meta:__addChildren(obj);
    end;

    return obj;
end;

API.newClass = function(self, className, defaultValues, existOne)
    assert(Classes[className] == nil, className..' already exists');
    local Classdata = {
        Name = className;
        Properties = defaultValues;
        Limited = existOne or false;
    };
    Classes[className] = Classdata;
end;

API.getStackObjectByHash = function(self, hash)
    for i, v in next, Stack do
        if (v.__hash == hash) then
            return v;
        end;
    end;
end;

API.getStack = function(self)
    return Stack;
end;

World = setmetatable({
    new = function()
        local NewWorld = API:newObject('World');
        API:newObject('Space', NewWorld);
        API:newObject('Time', NewWorld);
        API:newObject('Players', NewWorld);
        API:newObject('Storage', NewWorld);
        API:newObject('Database', NewWorld);
        API:newObject('Http', NewWorld);
        return NewWorld;
    end;
}, {
    __newindex = function(self, index, value)
        fatal('Attempt to add a new index ('..tostring(index)..') to Vector');
        return nil;
    end;
    __metatable = 'Locked';
});

Instance = setmetatable({
    new = function(className, parent)
        return API:newObject(className, parent);
    end;
}, {
    __newindex = function(self, index, value)
        fatal('Attempt to add a new index ('..tostring(index)..') to Vector');
        return nil;
    end;
    __metatable = 'Locked';
});
--[[
    Edit modes:
    0 - No edit
    1 - ReadOnly
    2 - WriteOnly
    3 - Read+WritePerms
]]
API:newClass('World', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'World';
        EditMode = 3;
    };
    {
        Name = 'GetUtility';
        Generator = false;
        IsCallback = false;
        Default = function(self, utilityClass)
            return Worlds[self].Utilities[utilityClass];
        end;
        EditMode = 1;
    };
}, true);
API:newClass('Space', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Space';
        EditMode = 3;
    };
}, true);
API:newClass('Time', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Time';
        EditMode = 3;
    };
}, true);
API:newClass('Players', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Players';
        EditMode = 3;
    };
}, true);
API:newClass('Storage', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Storage';
        EditMode = 3;
    };
}, true);
API:newClass('Database', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Database';
        EditMode = 3;
    };
}, true);
API:newClass('Audio', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        EditMode = 3;
        Default = 'Audio';
    };
}, true);
API:newClass('Window', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Window';
        EditMode = 3;
    };
    {
        Name = 'Close';
        Generator = false;
        Default = function(self)
            return love.window.close();
        end;
    };
}, true);
API:newClass('Http', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Http';
        EditMode = 3;
    };
    {
        Name = 'Get';
        Generator = false;
        IsCallback = false;
        Default = function(self, url)
            local res = {};
            local responseData = http.request{
                url = url;
                method = 'GET';
                sink = ltn12.sink.table(res);
            };
            return table.concat(res, '');
        end;
        EditMode = 1;
    };
    {
        Name = 'Post';
        Generator = false;
        IsCallback = false;
        Default = function(self, url, body)
            local res = {};
            local responseData = http.request{
                url = url;
                method = 'POST';
                source = ltn12.source.string(body);
                sink = ltn12.sink.table(res);
            };
            return table.concat(res, '');
        end;
        EditMode = 1;
    };
}, true);

--------------------------------------Objects-----------------------------------------

API:newClass('Block', {
    {
        Name = 'Name';
        Generator = false;
        IsCallback = false;
        Default = 'Name';
        EditMode = 3;
    };
    {
        Name = 'Color';
        Generator = true;
        IsCallback = false;
        Default = function() 
            local color = psuedoObjects:createType('Color');
            color.r = 255;
            color.g = 255;
            color.b = 255;
            return color;
        end;
        EditMode = 3;
    };
    {
        Name = 'Size';
        Generator = true;
        IsCallback = false;
        Default = function() 
            local vector = psuedoObjects:createType('Vector');
            vector.x = 100;
            vector.y = 100;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Position';
        Generator = true;
        IsCallback = false;
        Default = function() 
            local vector = psuedoObjects:createType('Vector');
            vector.x = 0;
            vector.y = 0;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Touched';
        Generator = true;
        IsCallback = false;
        Default = function() 
            return psuedoObjects:createType('Event');
        end;
        EditMode = 1;
    };
    {
        Name = 'Velocity';
        Generator = true;
        Default = function() 
            local vector = psuedoObjects:createType('Vector');
            vector.x = 0;
            vector.y = 0;
            return vector;
        end;
        EditMode = 3;
    };
    {
        Name = 'Collidable';
        Generator = true;
        Default = true;
        EditMode = 3;
     };
    {
        Name = 'Rotation';
        Generator = false;
        IsCallback = false;
        Default = 0;
        EditMode = 3;
    };
    {
        Name = 'Type';
        Generator = false;
        IsCallback = false;
        Default = 'line';
        EditMode = 3;
    };
}, false);
--we should be able to recreate objects in new worlds

API.CurrentWorld = API:newObject('World');
API:newObject('Space', API.CurrentWorld);
API:newObject('Time', API.CurrentWorld);
API:newObject('Players', API.CurrentWorld);
API:newObject('Storage', API.CurrentWorld);
API:newObject('Database', API.CurrentWorld);
API:newObject('Http', API.CurrentWorld);

psuedoWorkspace = API;
return API;
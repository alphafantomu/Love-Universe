
local http = require('socket.http');
local API = {};
local Classes = {};
local Stack = {};
local NullStack = {};
local Singularities = {};
local Runtime = {};

API.NullMetatable = {
    __isPartOfChildren = function(self, obj)
        return NullStack[obj] ~= nil;
    end;
    __addChildren = function(self, ...)
        local adding = {...};
        for i, v in next, adding do
            if (NullStack[v] == nil) then
                NullStack[v] = v;
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
            end;
        end;
    end;
};

API.replicateTable = function(self, tab)
    local n_t = {};
    for i, v in next, tab do
        rawset(n_t, i, v);
    end;
    return n_t;
end;

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

API.newObject = function(self, className, parent)
    assert(Classes[className] ~= nil, className..' Class does not exist');
    local obj = newproxy(true);
    local meta = getmetatable(obj);
    local classdata = Classes[className];
    if (classdata.Limited == true) then
        assert(Singularities[classdata.Name] == nil, 'Object already exists');
        Singularities[classdata.Name] = obj;
    end;
    local properties = self:replicateTable(classdata.Properties);
    local children_stack = {};
    local runtime_data = {
        functionIndex = #Runtime + 1;
        void = function(int)
            classdata.Runtime(obj);
            if (Runtime[int + 1] ~= nil) then
                pcall(Runtime[int + 1], int + 1);
            end;
        end;
    };
    local defaultProperties = {
        ClassName = classdata.Name;
        Parent = parent or nil;
        Destroy = function(self)
            self.Parent = nil;
            table.remove(Runtime, runtime_data.functionIndex);
            return obj.Parent == nil;
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
    meta.__index = function(self, index)
        return rawget(defaultProperties, index) or rawget(properties, index) or rawget(defaultProperties, 'FindChild')(obj, index);
    end;
    meta.__newindex = function(self, index, value) 
        if (type(index):lower() == 'string') then
            if (index:lower() == 'parent') then
                return pcall(function()
                    if (value ~= rawget(defaultProperties, 'Parent')) then
                        local NewParentObject = Stack[value] or {__metatable = API.NullMetatable;};
                        local OldParentObject = Stack[rawget(defaultProperties, 'Parent')] or {__metatable = API.NullMetatable;};
                        local NewMeta, OldMeta = NewParentObject.__metatable, OldParentObject.__metatable;
                        if (NewMeta:__isPartOfChildren(NewParentObject, obj) == false and OldMeta:__isPartOfChildren(OldParentObject, obj) == true or NewMeta:__isPartOfChildren(NewParentObject, obj) == false and OldMeta == API.NullMetatable) then
                            OldMeta:__removeChildren(obj);
                            if (OldMeta.__isPartOfChildren(OldParentObject, obj) == false) then
                                NewMeta:__addChildren(obj);
                            else
                                OldMeta:__addChildren(obj);
                            end;
                        end;
                        return rawset(defaultProperties, 'Parent', NewParentObject.__object);
                    end;
                end);
            end;
        end;
        assert(rawget(properties, index) ~= nil, index..' not found');
        return rawset(properties, index, value);
    end;
    meta.__tostring = function(self)
        return rawget(properties, 'Name');
    end;
    meta.__isPartOfChildren = function(self, obj)
        return children_stack[obj] ~= nil;
    end;
    meta.__addChildren = function(self, ...)
        local adding = {...};
        for i, v in next, adding do
            if (children_stack[v] == nil) then
                children_stack[v] = v;
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
    meta.__removeChildren = function(self, ...)
        local removing = {...};
        for i, v in next, removing do
            if (children_stack[v] ~= nil) then
                children_stack[v] = nil;
            end;
        end;
    end;
    meta.__metatable = 'Locked';
    Stack[obj] = {
        __hash = self:stringRandom(255, true); --object identification
        __object = obj;
        __metatable = meta;
        __Runtime = runtime_data;
    };
    if (classdata.Runtime ~= nil) then
        Runtime[runtime_data.functionIndex] = runtime_data.void;
    end;
    return obj;
end;

API.newClass = function(self, className, defaultValues, existOne, runT)
    assert(Classes[className] == nil, className..' already exists');
    local Classdata = {
        Name = className;
        Properties = defaultValues;
        Runtime = runT;
        Limited = existOne or false;
    };
    Classes[className] = Classdata;
end;

API:newClass('World', {
    Name = 'World';
    GetUtility = function(self, utilityClass)
        return Singularities[utilityClass];
    end;
}, true);
API:newClass('Space', {
    Name = 'Space';
}, true);
API:newClass('Time', {
    Name = 'Time';
}, true);
API:newClass('Players', {
    Name = 'Players';
}, true);
API:newClass('Storage', {
    Name = 'Storage';
}, true);
API:newClass('Database', {
    Name = 'Database';
}, true);
API:newClass('Http', {
    Name = 'Http';
    Get = function(self, url)
        local res = {};
        local responseData = http.request{
            url = url;
            method = 'GET';
            sink = ltn12.sink.table(res);
        };
        return table.concat(res, '');
    end;
    Post = function(self, url, body)
        local res = {};
        local responseData = http.request{
            url = url;
            method = 'POST';
            source = ltn12.source.string(body);
            sink = ltn12.sink.table(res);
        };
        return table.concat(res, '');
    end;
}, true);

API:newClass('Block', {
    Name = 'Block';
    Color = {r = 255, g = 0, b = 0;};
    Size = {x = 100; y = 100};
    Position = {x = 0; y = 0};
    Rotation = 0;
    Type = 'line';
}, false, function(obj)
    love.graphics.push();
    love.graphics.rotate(obj.Rotation);
    love.graphics.setColor(obj.Color.r/255, obj.Color.g/255, obj.Color.b/255);
    love.graphics.rectangle(obj.Type, obj.Position.x, obj.Position.y, obj.Size.x, obj.Size.y);
    love.graphics.pop();
end);

API.CurrentWorld = API:newObject('World');
API:newObject('Space', API.CurrentWorld);
API:newObject('Time', API.CurrentWorld);
API:newObject('Players', API.CurrentWorld);
API:newObject('Storage', API.CurrentWorld);
API:newObject('Database', API.CurrentWorld);
API:newObject('Http', API.CurrentWorld);

function love.draw() --ok this lags way too much, needs to be more efficent
    if (#Runtime >= 1) then
        pcall(Runtime[1], 1);
    end;
end;

return API;

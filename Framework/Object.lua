
--I'm going to be honest with everyone that is reading this, this single script gave me a huge fucking headache.

local API = {}; --main psuedoWorkspace API framework
local Classes = {}; --contains all the classes that you can create objects from, information about the class included
local Stack = {}; --Psuedo Environment Memory
local StackByHash = {};
local NullStack = {}; --this is actually equivalent to the children_stack standard objects have
local Worlds = {};

local ObjectsByClass = {};

local UniqueIDs = {};
local Metatables = {};
local Descendants = {};
local DescendantIndexes = {};

local getrawmetatable = function(obj)
	return Metatables[obj];
end;

API.Worlds = Worlds;

local BasePropertyAPI = {
    getProperty = function(self, index)
        for i, v in next, self.Properties do
            if (type(v):lower() == 'table') then
                if (v.Name == index) then
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
		if (property ~= nil) then
			if ((property.Generator == true or property.Updater == true) and type(property.Default):lower() == 'function') then
				return property.Default(self.Object);
			end;
			return property.Default;
		end;
	end;
	CanRewrite = function(self, index) 
        local default = self:GetDefaultValue(index);
		local property = self:getProperty(index);
		return (type(default):lower() ~= 'function' and property.IsCallback == false) or (type(default):lower() == 'function' and property.IsCallback == true);
	end;
	NewValueAcceptable = function(self, index, value)
		local default = self:GetDefaultValue(index);
        return type(default):lower() == type(value):lower(); --needs to be replaced with the modified type
    end;
};
local DefaultProperties = {
    Clone = function(self)
        local ClonedObject = Instance.new(self.ClassName, self.Parent);
        --default properties is automatically handled for us
        --class and standard properties no however
        local StandardProperties = getrawmetatable(self).standardProperties;
        for i, v in next, StandardProperties do
            ClonedObject[i] = v;
        end;
        return ClonedObject;
    end;
    GetFullName = function(self)
        local Branch = API:getBranch(self);
        local FullName = '';
        for i = #Branch, 1, -1 do
            FullName = FullName..tostring(Branch[i].Name)
            if (i ~= 1) then
                FullName = FullName..'.';
            end;
        end;
        return FullName;
    end;
    FindFirstAncestor = function(self, name)
        local Branch = API:getBranch(self);
        for i = 1, #Branch do
            local Object = Branch[i];
            if (Object.Name == name) then
                return Object;
            end;
        end;
        return nil;
    end;
    FindFirstAncestorOfClass = function(self, className)
        local Branch = API:getBranch(self);
        for i = 1, #Branch do
            local Object = Branch[i];
            if (Object.ClassName == className) then
                return Object;
            end;
        end;
        return nil;
    end;
    FindFirstAncestorWhichIsA = function(self, className)
        local Branch = API:getBranch(self);
        for i = 1, #Branch do
            local Object = Branch[i];
            if (Object:IsA(className) == true) then
                return Object;
            end;
        end;
        return nil;
    end;
    FindFirstChild = function(self, name, recursive)
        local meta = getrawmetatable(self);
        local children_stack = meta.children_stack;
        if (recursive == false or recursive == nil) then
            for i, v in next, children_stack do
                if (v.Name == name) then
                    return v;
                end;
            end;
        elseif (recursive == true) then
            local Object = nil;
            for i, v in next, children_stack do
                if (v.Name == name and Object == nil) then
                    Object = v;
                elseif (Object == nil) then
                    local DescendantSearch = v:FindFirstChild(name, true);
                    if (DescendantSearch ~= nil) then
                        Object = DescendantSearch;
                    end;
                end;
            end;
            return Object;
        end;
        return nil;
    end;
    FindFirstChildOfClass = function(self, className, recursive)
        local meta = getrawmetatable(self);
        local children_stack = meta.children_stack;
        if (recursive == false or recursive == nil) then
            for i, v in next, children_stack do
                if (v.ClassName == className) then
                    return v;
                end;
            end;
        elseif (recursive == true) then
            local Object = nil;
            for i, v in next, children_stack do
                if (v.ClassName == className and Object == nil) then
                    Object = v;
                elseif (Object == nil) then
                    local DescendantSearch = v:FindFirstChildOfClass(className, true);
                    if (DescendantSearch ~= nil) then
                        Object = DescendantSearch;
                    end;
                end;
            end;
            return Object;
        end;
        return nil;
    end;
    FindFirstChildWhichIsA = function(self, className, recursive)
        local meta = getrawmetatable(self);
        local children_stack = meta.children_stack;
        if (recursive == false or recursive == nil) then
            for i, v in next, children_stack do
                if (v:IsA(className) == true) then
                    return v;
                end;
            end;
        elseif (recursive == true) then
            local Object = nil;
            for i, v in next, children_stack do
                if (v:IsA(className) == true and Object == nil) then
                    Object = v;
                elseif (Object == nil) then
                    local DescendantSearch = v:FindFirstChildWhichIsA(className, true);
                    if (DescendantSearch ~= nil) then
                        Object = DescendantSearch;
                    end;
                end;
            end;
            return Object;
        end;
        return nil;
    end;
	Destroy = function(self) --when we stick it to the object, self should be the object and not the table.
		local descendant = self.Parent;
        local stackDescendant = Stack[descendant];
        if (stackDescendant ~= nil) then
            local meta = stackDescendant.__metatable;
            if (stackDescendant.__object ~= nil) then
                meta.__removeChildren(Stack[descendant].__object, self);
            end;
        end;
        local meta = getrawmetatable(self);
        Stack[self] = nil;
        local Value = ObjectsByClass[self.ClassName][meta.ClassIndex];
        if (Value ~= self) then
            print('Calculation went wrong? Impossible');
        end;
        ObjectsByClass[self.ClassName][meta.ClassIndex] = nil;
        if (API.ObjectDestroyed ~= nil) then
            local Manage = Ripple:ManageRipple('ObjectDestroyed');
            Manage:FireConnections(self);
        end;
        return Stack[self] == nil;
	end;
	IsA = function(self, className) --IsA uhhh doesn't support superclasses so this has to be revamped in later versions
		return className == getrawmetatable(self).classdata.Name;
	end;
	FindChild = function(self, name)
		local all = getrawmetatable(self).__getChildren(self);
		for i = 1, #all do
			local Object = all[i];
			if (Object.Name == name) then
				return Object;
			end;
		end;
		return nil;
	end;
	GetDescendants = function(self)
		return API:getDescendants(self);
	end;
	GetChildren = function(self)
		return getrawmetatable(self).__getChildren(self);
	end;
	ClearAllChildren = function(self)
		local meta = getrawmetatable(self);
		meta.__removeChildren(self, unpack(meta.__getChildren(self)));
	end;
};

local DefaultMetatable = {
    {'__tostring', function(self)
		local meta = getrawmetatable(self);
		local standardProperties, defaultProperties, parsed = meta.standardProperties, meta.defaultProperties, meta.parsed;
        if (Stack[self] == nil and self ~= nil) then
            return 'Object removed from stack';
		end;
        return rawget(standardProperties, 'Name') or parsed:GetDefaultValue('Name') or rawget(defaultProperties, 'ClassName');
    end;};
    {'__isPartOfChildren', function(self, child)
        return getrawmetatable(self).children_stack[child] ~= nil;
    end;};
    {'__addChildren', function(self, ...)
		local meta = getrawmetatable(self);
		local children_stack = meta.children_stack;
        local adding = {...};
        for i = 1, #adding do
            local v = adding[i];
            if (children_stack[v] == nil) then
                children_stack[v] = v;
				if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = self;
                end;
            end;
        end;
    end;};
    {'__getChildren', function(self) --we can optimize this
		local meta = getrawmetatable(self);
		local children_stack = meta.children_stack;
        local children = {};
        for i, v in next, children_stack do
            table.insert(children, v);
        end;
        return children;
    end;};
    {'__removeChildren', function(self, ...)
		local meta = getrawmetatable(self);
		local children_stack = meta.children_stack;
        local removing = {...};
        for i = 1, #removing do
            local v = removing[i];
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
            end;
        end;
    end;};
    {'__metatable', 'Locked'};
}

API.NullMetatable = {
	__null = true;
	__object = nil;
    __isPartOfChildren = function(self, obj)
        return NullStack[obj] ~= nil;
    end;
    __addChildren = function(self, ...)
        local adding = {...};
        for i = 1, #adding do
            local v = adding[i];
            if (NullStack[v] == nil) then
                NullStack[v] = v;
                if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = nil;
                end;
            end;
        end;
    end;
    __getChildren = function(self) --we can optimize this
        local children = {};
        for i, v in next, NullStack do
            table.insert(children, v);
        end;
        return children;
    end;
    __removeChildren = function(self, ...)
        local removing = {...};
        for i = 1, #removing do
            local v = removing[i];
            if (NullStack[v] ~= nil) then
                NullStack[v] = nil;
                if (Stack[v] ~= nil) then
                    Stack[v].__object.Parent = nil;
                end;
            end;
        end;
    end;
};

local Null = {__metatable = API.NullMetatable;};

API.generateString = function(self, n) --fuck it dude, made it super short, lesser calculations and randomness
	local str = '';
	for i = 1, n or 1 do
		str = str..tostring(string.char(math.random(32, 126)));
	end;
	return str;
end;

API.generateUnique = function(self, n)
	local String;
	repeat
		String = self:generateString(n);
	until
		UniqueIDs[String] == nil;
	UniqueIDs[String] = 0;
	return String;
end;

API.parseProperties = function(self, obj, properties)  --super-optimized
    local API = {};
    API.Object = obj;
    API.Properties = properties;
    for i, v in next, BasePropertyAPI do --optimized, are not writing functions like a mad man
        API[i] = v;
    end;
    return API;
end;

API.isWorldObject = function(self, obj) return Worlds[obj] ~= nil; end;

API.getBranch = function(self, obj, selfInclude)
    if (obj ~= nil) then
        local Ancestors = {};
		--goes from most recent to oldest
		if (selfInclude == true) then
			table.insert(Ancestors, obj);
		end;
        local Ancestor = obj;
        repeat
            local Parent = Ancestor.Parent;
            if (Parent == nil) then break; end;
            table.insert(Ancestors, Parent);
            Ancestor = Parent;
        until
            Ancestor.Parent == nil;
        return Ancestors;
	end;
	return {};
end;

API.getObjectsByClass = function(self, ClassName)
    return ObjectsByClass[ClassName];
end;

API.getDescendants = function(self, obj)
    local Descendants = Descendants[obj];
    local Replicate = {};
    for i = 1, #Descendants do
        Replicate[i] = Descendants[i];
    end;
    return Replicate;
end;

API.getFirstAncestor = function(self, obj) --optimized
	if (obj ~= nil) then
		local Ancestor = obj;
		repeat
			local Parent = Ancestor.Parent;
			if (Parent == nil) then break; end;
			Ancestor = Parent;
		until
			Ancestor.Parent == nil;
		return Ancestor;
	end;
end;

API.forceNewIndex = function(self, obj, index, value)
    local meta = getrawmetatable(obj);
    local standardProperties = meta.standardProperties;
    rawset(standardProperties, index, value);
    if (API.PropertyChanged ~= nil) then
        local ManageRipple = Ripple:ManageRipple('PropertyChanged');
        ManageRipple:FireConnections(obj, index, value);
    end;
end;

API.addDescendantToBranch = function(self, obj, Ancestor)
	local AncestorDescendants = Descendants[Ancestor];
	local CalculateIndex = #AncestorDescendants + 1;
	AncestorDescendants[CalculateIndex] = obj;
	local IndexTable = DescendantIndexes[obj];
	if (IndexTable == nil) then
		IndexTable = {};
		DescendantIndexes[obj] = IndexTable;
	end;
	IndexTable[Ancestor] = CalculateIndex;
end;

API.removeDescendantFromBranch = function(self, obj, Ancestor)
	local AncestorDescendants = Descendants[Ancestor];
	local IndexTable = DescendantIndexes[obj];
	if (IndexTable == nil) then
		IndexTable = {};
		DescendantIndexes[obj] = IndexTable;
	end;
	local CalculatedIndex = IndexTable[Ancestor];
	AncestorDescendants[CalculatedIndex] = nil;
	IndexTable[Ancestor] = nil;
end;

API.updateTransferAncestors = function(self, obj, OldMeta, NewMeta)
	local ObjectDescendants, OldBranch, NewBranch = Descendants[obj], self:getBranch(OldMeta.__object, true), self:getBranch(NewMeta.__object, true);
	for i = 1, #OldBranch do
		local Ancestor = OldBranch[i];
		self:removeDescendantFromBranch(obj, Ancestor);
		for o = 1, #ObjectDescendants do
			local Descendant = ObjectDescendants[o];
			self:removeDescendantFromBranch(Descendant, Ancestor);
		end;
	end;
	for i = 1, #NewBranch do
		local Ancestor = NewBranch[i];
		self:addDescendantToBranch(obj, Ancestor);
		for o = 1, #ObjectDescendants do
			local Descendant = ObjectDescendants[o];
			self:addDescendantToBranch(Descendant, Ancestor);
		end;
	end;
end;

API.newObject = function(self, className, parent) --optimized like a madman
    assert(Classes[className] ~= nil, className..' Class does not exist'); --We need to check if the class actually exists first
    local obj = newproxy(true);
    local meta = getmetatable(obj);
    local classdata = Classes[className]; --get information about the class
    --Service limited to only 1 object per world
	local children_stack = {};
	local DescendantsTable = {}; --this is only a reference to this object's descendants table, but inside the object will never be referenced
    local defaultProperties = {
        ClassName = classdata.Name;
        Parent = nil;
	};
	for i, v in next, DefaultProperties do
		defaultProperties[i] = v;
	end;
    --[[
        This is a little strange, but there are three different type of properties:
        - Class Properties - Pre-defined properties for a certain class, not actively changing and is only used as reference
        - Default Properties - Properties at the inherit level, also actively changing but is also universal over all instances, in roblox
        this would be described as the <<<ROOT>>> class or the Instance base class.
        - Standard Properties - Properties at the surface level, actively changing etc.
    ]]
    local standardProperties = {}; --the new set being written
    local classProperties = classdata.Properties;
	local parsed = self:parseProperties(obj, classProperties);
	meta.parsed = parsed;
	meta.standardProperties = standardProperties;
	meta.defaultProperties = defaultProperties;
	meta.children_stack = children_stack;
	meta.classdata = classdata;
	meta.__object = obj;
    meta.__index = function(self, index)
        if (Stack[self] == nil and self ~= nil) then
            --print('Memory warning: You\'re trying to interact with an object that\'s not part of the stack');
        end;
		return parsed:PropertyExists(index, function(res, property) --property data does not exist
			if (res == true) then
				assert(property.EditMode == 1 or property.EditMode == 3, 'Property '..index..' cannot be read');
				if (rawget(standardProperties, index) == nil and property.Generator == true) then
					rawset(standardProperties, index, parsed:GetDefaultValue(index));
				end;
                if (rawget(standardProperties, index) == nil and property.Updater == true) then
					return parsed:GetDefaultValue(index);
				end;
                local Value = rawget(standardProperties, index);
                if (Value == nil) then
                    return parsed:GetDefaultValue(index);
                end;
                return Value;
            end;
            local Value = rawget(defaultProperties, index);
            if (Value == nil) then
                return rawget(defaultProperties, 'FindChild')(self, index);
            end;
            return Value;
		end);
    end;

    meta.__newindex = function(self, index, value) 
        if (Stack[self] == nil and self ~= nil) then
            --print('Memory warning: You\'re trying to interact with an object that\'s not part of the stack');
		end;
		assert(not (index ~= 'Parent' and defaultProperties[index] == nil and parsed:getProperty(index) == nil), 'Property cannot be found');
		parsed:PropertyExists(index, function(res, property)
			if (res == true) then
				assert(property.EditMode == 2 or property.EditMode == 3, 'Property '..index..' cannot be rewritten');
			end;
		end);
        --[[
            When I was optimizing this, just needed to define the purpose of "Null" and "NullMetatable".
            The code for Parent and everything else is made to be flexible with things like Destroy, and Parenting, I don't know if I will ever remove it
            I'm actually not even sure if it's super optimized.
        ]]
        if (type(index):lower() == 'string') then
			if (index == 'Parent') then
				assert(value ~= self, 'Attempting to change the parent of an object to itself');
				local CurrentParent = rawget(defaultProperties, 'Parent');
                if (value ~= CurrentParent and value ~= obj) then
					local NewParentObject, OldParentObject = Stack[value] or Null, Stack[CurrentParent] or Null;
					local NewMeta, OldMeta = NewParentObject.__metatable, OldParentObject.__metatable;
					local NewLocalObject, OldLocalObject = NewMeta.__isPartOfChildren(NewMeta.__object, self), OldMeta.__isPartOfChildren(OldMeta.__object, self);
					if (NewLocalObject == false and OldLocalObject == true or
						NewLocalObject == false and OldMeta == API.NullMetatable) then
						OldMeta.__removeChildren(OldMeta.__object, self); --rereading my code I just have to hope I know what I'm doing bc I don't remember
						if (OldMeta.__isPartOfChildren(OldMeta.__object, self) == false) then
							NewMeta.__addChildren(NewMeta.__object, self);
                            API:updateTransferAncestors(self, OldMeta, NewMeta);
                            -----------------------------UTILITY SPECIAL---------------------------does not account for nil values
                            if (classdata.Limited == true) then
                                local getCurrentWorld = API:getFirstAncestor(CurrentParent);
                                if (getCurrentWorld ~= nil) then
                                    local nextWorld = API:getFirstAncestor(NewParentObject.__object);
                                    if (nextWorld ~= nil) then
                                        if (Worlds[nextWorld] == nil) then
                                            Worlds[nextWorld] = {
                                                Utilities = {};
                                            };
                                        end;
                                        if (Worlds[nextWorld].Utilities[classdata.Name] == nil) then
                                            Worlds[nextWorld].Utilities[classdata.Name] = obj;
                                            if (Worlds[getCurrentWorld].Utilities[classdata.Name] ~= nil and World[nextWorld].Utilities[classdata.Name] == obj) then
                                                Worlds[nextWorld].Utilities[classdata.Name] = nil;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                            ------------------------------------------------------------------------
							rawset(defaultProperties, 'Parent', NewParentObject.__object);
							if (API.PropertyChanged ~= nil) then
                                local ManageRipple = Ripple:ManageRipple('PropertyChanged');
                                ManageRipple:FireConnections(self, index, value);
							end;
						else
							OldMeta.__addChildren(OldMeta.__object, self); --for some fucking reason it failed, so uhh we have to add the obj back into the old parent just incase
                            if (rawget(defaultProperties, 'Parent') ~= OldParentObject.__object) then
                                rawset(defaultProperties, 'Parent', OldParentObject.__object); --we need to set the parent property of properties to the old object JUST INCASE
                            end;
                        end;
                    end;
				end;
				return;
            end;
        end;
		parsed:PropertyExists(index, function(res, property)
			if (res == true) then
				if (defaultProperties[index] ~= nil) then
					assert(type(defaultProperties[index]):lower() ~= 'function', 'Property cannot be overrided'); --can't override functions at all
					assert(index ~= 'ClassName', 'Property ClassName cannot be overrided');
					if (type(value):lower() == type(defaultProperties[index]):lower()) then --must be the same type
                        rawset(defaultProperties, index, value);
                        if (API.PropertyChanged ~= nil) then
                            local ManageRipple = Ripple:ManageRipple('PropertyChanged');
                            ManageRipple:FireConnections(self, index, value);
                        end;
					end;
				else
					assert(parsed:CanRewrite(index), 'Property cannot be overrided');
					assert(parsed:NewValueAcceptable(index, value), 'Property type not acceptable');
					rawset(standardProperties, index, value);
                    if (API.PropertyChanged ~= nil) then
                        local ManageRipple = Ripple:ManageRipple('PropertyChanged');
						ManageRipple:FireConnections(self, index, value);
                    end;
				end;
			end;
		end);
    end;
    for i = 1, #DefaultMetatable do
        local Data = DefaultMetatable[i];
        meta[Data[1]] = Data[2];
    end;
    
    local UniqueHash = self:generateUnique(10);
    local StackObject = {
        __hash = UniqueHash;
        __object = obj;
        __metatable = meta;
	};
    Stack[obj] = StackObject;
    StackByHash[UniqueHash] = StackObject;
    Metatables[obj] = meta;
    Descendants[obj] = DescendantsTable;

    local ClassList = ObjectsByClass[className];
    if (ClassList == nil) then
        ClassList = {};
        ObjectsByClass[className] = ClassList;
    end;
    local ObjectIndex = #ClassList + 1;
    meta.ClassIndex = ObjectIndex;
    ClassList[ObjectIndex] = obj;
    if (ClassList[ObjectIndex] ~= obj) then
        print('There was an error calculating objects');
    end;
	if (classdata.Limited == true and parent ~= nil) then
        local getObjectWorld = API:getFirstAncestor(parent);
        local WorldData = Worlds[getObjectWorld];
        assert(WorldData.Utilities[classdata.Name] == nil, 'Object already exists');
        WorldData.Utilities[classdata.Name] = obj;
    end;
    if (API.ObjectCreated ~= nil) then
        local Manage = Ripple:ManageRipple('ObjectCreated');
        Manage:FireConnections(obj);
	end;
    obj.Parent = parent;
    return obj;
end;

API.newClass = function(self, className, defaultValues, existOne)
    assert(Classes[className] == nil, className..' already exists');
    Classes[className] = {
        Name = className;
        Properties = defaultValues;
        Limited = existOne or false;
    };
end;

API.getObjectByHash = function(self, hash)
    return StackByHash[hash];
end;

API.getStack = function(self)
    return Stack;
end;

--[[
    Edit modes:
    0 - No edit
    1 - ReadOnly
    2 - WriteOnly
    3 - Read+WritePerms
]]

Object = API;
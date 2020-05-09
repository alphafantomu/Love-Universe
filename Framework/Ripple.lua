
--[[
    First, we need to lay out the concepts of how I think roblox events work.

    Roblox's management on the surface works like this:
    ‣ Instance
        ‣ Event (RBXScriptSignal)
            ‣ Connect
                ‣ Connection Data (RBXScriptConnection)
                    ‣ Connected
                    ‣ Disconnect
            ‣ Wait

    That looks pretty simple, but that's only on the surface, internally we need to be able to fire the connections.
    Obviously I don't have the internal source code for Roblox and how everything works, kinda. So here's my theory on how events work.

    ‣ Object
		‣ Ripple (Much like one person, but exists across different timelines)
			‣ Processor (One per event copy of an object)
				‣ Connect
					‣ Connection
						‣ Connected
						‣ Disconnect
				‣ Wait

    ‣ Ripple Handler (We can modify the ripple across different spaces at once)
        ‣ GetConnections
        ‣ DisconnectConnections
        ‣ FireConnections
        ‣ GetDisconnections

        ‣ Connection Handlers (Connects to ‣ Connection) (There can be multiple connections per ripple)
            ‣ Disconnect (‣ Connection ‣ Disconnect)
            ‣ Connected (‣ Connection ‣ Disconnect)
            ‣ GetCallback
            ‣ SetCallback
            ‣ FireCallback

    PerProcessor
        ‣ Object
            ‣ RippleName
                ‣ Connections
]]
--[[
    0 - no edit
    1 - readonly
    2 - writeonly
    3 - read+writeonly
]]
local API = {
    Mode = 0;
};
local Ripples = {};
local RipplesCache = {};
local ConnectionsCache = {}; --connection cache for managers
local ProcessorCache = {};
local PerProcessor = {};

API.Ripples = Ripples;
local RippleOptions = {
	GetProcessorConnections = function(self, className)
		local Processors = self.Object.Processors;
		return Processors[className];
    end;
    FireRippleProcessorConnections = function(self, obj, ...)
		local ProcessorObject = API:GetProcessorObject(obj);
		local Connections = ProcessorObject[self.Name];
		if (Connections ~= nil) then
			for i = 1, #Connections do
				local Connection = Connections[i];
				if (Connection.Connected == true) then
					local Manager = API:ManageConnection(Connection);
					Manager:FireCallback(...);
				end;
			end;
		end;
	end;
	FireProcessorConnections = function(self, className, ...)
        local Processors = self.Object.Processors;
		local ClassProcessor = Processors[className];
        if (ClassProcessor ~= nil) then
			for i = 1, #ClassProcessor do
				local Connection = ClassProcessor[i];
				if (Connection.Connected == true) then
					local Manager = API:ManageConnection(Connection);
					Manager:FireCallback(...);
				end;
			end;
		end;
	end;
	DisconnectProcessorConnections = function(self, className)
		local Processors = self.Object.Processors;
		local ClassProcessor = Processors[className];
		if (ClassProcessor ~= nil) then
			for i = 1, #ClassProcessor do
				local Connection = ClassProcessor[i];
				if (Connection.Connected == true) then
					Connection:Disconnect();
				end;
			end;
		end;
	end;
    GetConnections = function(self)
        local All = self.Object.Connections;
        local Valid = {};
        for i = 1, #All do
            local Connection = All[i];
            if (Connection.Connected == true) then
                table.insert(Valid, Connection);
            end;
        end;
        return Valid;
    end;
    DisconnectConnections = function(self)
        local All = self.Object.Connections;
        for i = 1, #All do
            local Connection = All[i];
            if (Connection.Connected == true) then
                Connection:Disconnect();
            end;
        end;
    end;
    FireConnections = function(self, ...)
        local All = self.Object.Connections;
        for i = 1, #All do
            local Connection = All[i];
            if (Connection.Connected == true) then
                local Manager = API:ManageConnection(Connection);
                Manager:FireCallback(...);
            end;
        end;
    end;
};

local ConnectionOptions = {
    Disconnect = function(self)
        self.Object:Disconnect();
    end;
    Connected = function(self)
        return self.Object.Connected;
    end;
    GetCallback = function(self)
        if (API.Mode == 1 and self.Object.LoveId ~= false) then
            return love.handlers[self.Object.LoveId];
        end;
        return self.Callback;
    end;
    SetCallback = function(self, Callback)
        if (API.Mode == 1 and self.Object.LoveId ~= false) then
            love.handlers[self.Object.LoveId] = Callback;
        else
            self.Callback = Callback;
        end;
    end;
    FireCallback = function(self, ...)
        if (API.Mode == 1 and self.Object.LoveId ~= false and self.Object.Connected == true and API:LoveHandlerExists(self.Object.LoveId) == true) then
            love.event.push(self.Object.LoveId, ...);
        elseif (self.Callback ~= nil and self.Object.Connected == true) then
            self.Callback(...);
        end;
    end;
};

API.GetProcessorObject = function(self, obj)
    local PerObject = PerProcessor[obj];
    if (PerObject == nil) then
        PerObject = {};
        PerProcessor[obj] = PerObject;
    end;
    return PerObject;
end;

API.LoveHandlerExists = function(self, id)
    local ran, result = pcall(function()
        return love.handlers[id] ~= nil;
    end);
    return result;
end;

API.AttachProcessor = function(self, classObject, name)
    if (ProcessorCache[classObject] ~= nil and ProcessorCache[classObject][name] ~= nil) then print'found old'; return ProcessorCache[classObject][name]; end; --something must be wrong here
    local RippleData = Ripples[name];
    if (RippleData ~= nil and classObject ~= nil) then
		local Processors = RippleData.Processors;
		local className = classObject.ClassName;
		local ClassProcessor = Processors[className];
		if (ClassProcessor ==  nil) then
			ClassProcessor = {};
			Processors[className] = ClassProcessor;
		end;
        local Proxy = CustomTypes:createType('Processor');
		CustomTypes:forceNewIndex(Proxy, 'Ripple', RippleData.Object);
        CustomTypes:forceNewIndex(Proxy, 'Object', classObject);

        local CacheObject = ProcessorCache[classObject];
        if (CacheObject == nil) then CacheObject = {}; ProcessorCache[classObject] = CacheObject; end;
        CacheObject[name] = Proxy;

        local PerObject = PerProcessor[classObject];
        if (PerObject == nil) then
            PerObject = {};
            PerProcessor[classObject] = PerObject;
        end;
        if (PerObject[name] == nil) then
            PerObject[name] = {};
        end;
		return Proxy;
	end;
end;

API.TearRipple = function(self, name)
    if (Ripples[name] ~= nil) then return Ripples[name].Object; end;
    local Object = CustomTypes:createType('Ripple');
    CustomTypes:forceNewIndex(Object, 'Name', name);
    Ripples[name] = {
		Object = Object;
		Processors = {};
        Connections = {};
    };
    return Object;
end;

API.ManageConnection = function(self, obj) --there is only one per connection so we can rereference it
    if (ConnectionsCache[obj] ~= nil) then return ConnectionsCache[obj]; end;
    local Options = {
		Object = obj;
		Records = {};
    };
    for i, v in next, ConnectionOptions do Options[i] = v; end;
    ConnectionsCache[obj] = Options;
    return Options;
end;

API.ManageRipple = function(self, name)
    if (RipplesCache[name] ~= nil) then return RipplesCache[name]; end;
    local Object = Ripples[name]; --make sure ripple is registered
    if (Object ~= nil) then
        local Options = {
            Name = name;
            Object = Object;
        };
        for i, v in next, RippleOptions do Options[i] = v; end;
        RipplesCache[name] = Options;
        return Options;
    end;
end;

Ripple = API;

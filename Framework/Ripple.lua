
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
]]
--[[
    0 - no edit
    1 - readonly
    2 - writeonly
    3 - read+writeonly
]]
local API = {
    Mode = 1;
};
local Ripples = {};
local RipplesCache = {};
local ConnectionsCache = {}; --connection cache for managers

API.Ripples = Ripples;
local RippleOptions = {
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
    GetDisconnections = function(self)
        local All = self.Object.Connections;
        local Valid = {};
        for i = 1, #All do
            local Connection = All[i];
            if (Connection.Connected == false) then
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

API.LoveHandlerExists = function(self, id)
    local ran, result = pcall(function()
        return love.handlers[id] ~= nil;
    end);
    return result;
end;

API.TearRipple = function(self, name)
    if (Ripples[name] ~= nil) then return Ripples[name]; end;
    local Object = CustomTypes:createType('Ripple');
    CustomTypes:forceNewIndex(Object, 'Name', name);
    Ripples[name] = {
        Object = Object;
        Connections = {};
    };
    return Object;
end;

API.ManageConnection = function(self, obj) --there is only one per connection so we can rereference it
    if (ConnectionsCache[obj] ~= nil) then return ConnectionsCache[obj]; end;
    local Options = {
        Object = obj;
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

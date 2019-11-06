
--[[
    EventFramework = {
        registerListener
        destroy
        disconnectall
        fireall
    }
    ListenerFramework = {
        Fire
        Disconnect
    }
    Listener = {
        Disconnect
        Wait
        Disabled
    }

    the difference between love.timer.sleep() and wait() is that one freezes the game, the other doesn't.

    We also can switch between Love Universe events and Love Engine events
    Mode:
    0 - Love Universe event management
    1 - Love Engine event management
]]
local API = {
    Mode = 1;
};
local triggers = {};
local connectionsCache = {};
local signalNetwork = {};
 
API.eventExists = function(self, event)
    return triggers[event] ~= nil;
end;

API.destroyEvent = function(self, event)
    if (API:eventExists(event) == true) then
        triggers[event] = nil;
    end;
end;

API.getEvent = function(self, event)
    return triggers[event];
end;

API.loveHandlerExists = function(self, handlerName)
    local ran, result = pcall(function()
        return love.handlers[handlerName] ~= nil;
    end);
    return ran;
end;

API.getAllListeners = function(self, event)
    return triggers[event].Listeners;
end;

API.registerListener = function(self, event)
    assert(API:eventExists(event), 'Event doesn\'t exist');
    local remote = API:createListenerRemote(event);
    local eventTrigger = triggers[event];
    eventTrigger.Listeners[remote] = remote;
    return remote;
end;

API.registerEvent = function(self, event)
    if (API:eventExists(event) == false) then
        triggers[event] = {Listeners = {}};
        triggers[event].Remote = API:createEventRemote(event, triggers[event]);
        return triggers[event].Remote;
    else
        return triggers[event].Remote;
    end;
end;

API.createEventRemote = function(self, event)
    local remote = {};
    remote.registerListener = function(self)
        return API:registerListener(event);
    end;
    remote.Destroy = function(self)
        return API:destroyEvent(event);
    end;
    remote.DisconnectAll = function(self)
        if (triggers[event] ~= nil) then
            for i, v in next, triggers[event].Listeners do
                v:disconnect();
            end;
        end;
    end;
    remote.FireAll = function(self, ...)
        --probably need threading here
        if (triggers[event] ~= nil) then
            for i, v in next, triggers[event].Listeners do
                v:fire(...);
            end;
        end;
    end;
    remote.destroy = remote.Destroy;
    return remote;
end;

API.createListenerRemote = function(self, event)
    local remote = {};
    local listener = API:createListenerObject(event, remote);
    local cause;
    if (API.Mode == 1) then
        remote.loveId = psuedoWorkspace:stringRandom(255, true);
        if (API:loveHandlerExists(remote.Id) == true) then
            repeat
                remote.loveId = psuedoWorkspace:stringRandom(255, true);
            until
                API:loveHandlerExists(remote.Id) == false;
        end;
    end;
    remote.connected = true;
    remote.getListener = function(self)
        if (self.connected == true) then
            return listener;
        end;
    end;
    remote.setCause = function(self, causeFunction)
        if (API.Mode == 1) then
            love.handlers[remote.loveId] = causeFunction;
        elseif (API.Mode == 0) then
            cause = causeFunction;
        end;  
    end;
    remote.disconnect = function(self)
        if (self.connected == true) then
            self.connected = false;
            if (connectionsCache[listener] ~= nil) then
                connectionsCache[listener] = nil;
            end;
            if (triggers[event].Listeners[listener] ~= nil) then
                triggers[event].Listeners[listener] = nil;
            end;
            if (API.Mode == 1) then
                love.handlers[remote.loveId] = nil;
            end;
        end;
    end;
    remote.fire = function(self, ...)
        if (self.connected == true) then
            --we are probably supposed to add threading here
            if (API.Mode == 0) then
                if (cause ~= nil) then
                    connectionsCache[listener] = listener;
                    cause(...);
                    connectionsCache[listener] = nil;
                end;
            elseif (API.Mode == 1) then
                if (API:loveHandlerExists(remote.loveId) == true) then
                    connectionsCache[listener] = listener;
                    love.event.push(remote.loveId, ...);
                    connectionsCache[listener] = nil;
                end;
            end;
        end;
    end;
    remote.Disconnect = remote.disconnect;
    remote.Fire = remote.fire;
    return remote;
end;

API.createListenerObject = function(self, event, remote)
    assert(event ~= nil or API:eventExists(event), 'Event doesn\'t exist');
    local listener = newproxy(true);
    local meta = getmetatable(listener);
    meta.__index = function(self, index)
        if (index == 'Connected' or index == 'connected') then
            return remote.connected;
        end;
        if (type(index):lower() == 'string' and remote.connected == true) then
            if (index:lower() == 'disconnect') then
                return function(self)
                    remote.connected = false;
                    remote:disconnect();
                end;
            end;
        end;
    end;
    meta.__newindex = function(self, index, value)
        fatal('Attempt to index a new value for a listener object')
    end;
    meta.__tostring = function() return 'Listener'; end;
    return listener;
end;

local eventProperties = {
    {
        index = 'connect';
        function_dependent = false;
        default = function(self, void)
            --self is the event
            if (type(self):lower() == 'event') then
                if (API.Mode == 0) then --love universe
                    if (type(self):lower() == 'event') then
                        local remote = API:registerEvent(self);
                        local listenerFramework = remote:registerListener();
                        listenerFramework:setCause(void);
                        local listener = listenerFramework:getListener();
                        return listener;
                    end;
                elseif (API.Mode == 1) then --love engine
                    if (type(self):lower() == 'event') then
                        local remote = API:registerEvent(self);
                        local listenerFramework = remote:registerListener();
                        listenerFramework:setCause(void);
                        local listener = listenerFramework:getListener();
                        return listener;
                    end;
                end;
            end;
        end;
        edit_mode = 1;
    };
    { --so i investigated what wait was, so essentially it yields the script until it fires, but oddly enough the print after thw wait printed faster than the connection itself, so it's sort of weird?
        index = 'wait';
        function_dependent = false;
        default = function(self, void)
            --self is the event
            if (type(self):lower() == 'event') then
                --[[psuedoThreading:waitUntil(function()
                    return #signalNetwork[event] > 0;
                end, 10);
                
                So the thing with this is, #signalNetwork[event] tells us that a signal is coming in to
                be looked at and be fired. then the signal will be removed from signalNetwork
                    essentially for this event system to work we need a runtime listener
                ]]
            end;
        end;
        edit_mode = 1;
    };
}
table.insert(eventProperties, {
    index = 'Connect';
    function_dependent = (function()
        for i, v in next, eventProperties do
            if (v.index == 'connect') then
                return v.function_dependent;
            end;
        end;
    end)();
    default = (function()
        for i, v in next, eventProperties do
            if (v.index == 'connect') then
                return v.default;
            end;
        end;
    end)();
    edit_mode = (function()
        for i, v in next, eventProperties do
            if (v.index == 'connect') then
                return v.edit_mode;
            end;
        end;
    end)();
});
table.insert(eventProperties, {
    index = 'Wait';
    function_dependent = (function()
        for i, v in next, eventProperties do
            if (v.index == 'wait') then
                return v.function_dependent;
            end;
        end;
    end)();
    default = (function()
        for i, v in next, eventProperties do
            if (v.index == 'wait') then
                return v.default;
            end;
        end;
    end)();
    edit_mode = (function()
        for i, v in next, eventProperties do
            if (v.index == 'wait') then
                return v.edit_mode;
            end;
        end;
    end)();
});
psuedoObjects:newType('Event', eventProperties, {})

psuedoEvents = API;
return API;
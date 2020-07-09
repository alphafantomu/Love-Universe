
--[[
    I had to rewrite the Optimizer, the way I was doing things was getting complicated and I needed a fresh start.

    My purpose in writing Optimizer.lua is:
        ‣ I realized having a shit ton of children objects and trying to loop through all of them to search for a child kinda hurts.
        ‣ Also the issue with the optimization for children currently is that #table does not return the highest index, it only returns the highest
            index until the next value is nil, we should use maxn but it's said that with larger tables it impacts performance
        ‣ I am hoping that Optimizer.lua will improve performance for games that require a lot of data.

    If we have highest section with all the highest indexes, and then every new index is put in a queue for the highest section
    
    
]]

local oldInsert, oldRemove = table.insert, table.remove;
local API = {
    FinalSize = 5;
    ArrayData = {};
};

API.OptimizerMetatable = {
    __newindex = function(self, index, value, preset)
        local Data = API:ReceiveData(self);
        if (Data ~= nil and tonumber(index) ~= nil) then
           
        end;
    end;
    __len = function(self)
        local Data = API:ReceiveData(self);
        if (Data ~= nil) then
            return Data[1][1];
        end;
        return 0;
    end;
};

API.Sort = function(a, b)
    return a > b;
end;

API.ReceiveData = function(self, t)
    return self.ArrayData[t];
end;

API.

API.IsAcceptable = function(self, t)
    local n = #t;
    return n ~= nil and tonumber(n) ~= nil and n > 0;
end;

API.Optimize = function(self, t)
    local Data = self:ReceiveData(t);
    if (Data == nil) then
        local ArrayData = {};
        if (self:IsAcceptable(t) == true) then
            local Final = {};
            
        end;
        self.ArrayData[t] = ArrayData;
        return setmetatable(t, self.OptimizerMetatable);
    end;
end;

Optimizer = API;
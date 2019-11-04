
local API = {};

API.waitms = function(self, ms)
    local currentTime = os.clock()*1000; --convert seconds to milliseconds
    repeat until (os.clock()*1000 - currentTime) >= ms;
end;

API.waitUntil = function(self, void, msPerCheck)
    if (msPerCheck == nil) then msPerCheck = 10; end;
    repeat
        API:waitms(msPerCheck);
    until
        void() == true;
end;

psuedoThreading = API;
return API;
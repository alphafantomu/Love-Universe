
local API = {};

API.wait = function(self, s)
    local currentTime = os.clock();
    repeat until (os.clock() - currentTime) >= s;
end;

roblox = API;
return API;

--this also wont be done in awhile, not even sure if we'll need this
local API = {};

API.wait = function(self, s)
    local currentTime = os.clock();
    repeat until (os.clock() - currentTime) >= s;
end;

roblox = API;
return API;
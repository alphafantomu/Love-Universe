
--Runtime for the engine
local API = {};

local Manager;

love.update = function(dt) --dt is the change in time
    if (API.TimeChanged ~= nil) then
        if (Manager == nil) then
            Manager = Ripple:ManageRipple('TimeChanged');
        end;
        Manager:FireConnections(dt);
    end;
end;

Waterfall = API;
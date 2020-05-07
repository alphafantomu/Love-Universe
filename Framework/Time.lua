
local API = {};

API.delay = function(s, callback)
    local Timer = CustomTypes:createType('Timer');
    Timer:Start(s, callback);
end;

wait = API.delay;
delay = API.delay;
Time = API;
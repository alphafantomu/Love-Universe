
local API = {};

API.failure = function(self, condition, ...)
    if (condition == false) then
        print('[Failure]: ', ...);
    end;
end;

API.warn = function(self, ...)
    print('[Warning]: ', ...);
end;

API.fatalerror = function(self, ...)
    print('[Fatal Error]: ', ...);
end;

failure = function(...)
    return API:failure(...);
end;

warn = function(...)
    return API:warn(...);
end;

fatal = function(...)
    return API:fatalerror(...);
end;

psuedoOutput = API;
return API;
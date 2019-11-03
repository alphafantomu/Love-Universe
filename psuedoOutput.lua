
local API = {};

API.warn = function(self, ...)
    print('[WARNING]: ', ...);
end;

API.fatalerror = function(self, ...)
    print('[FATAL ERROR]: ', ...);
end;

warn = function(...)
    return API:warn(...);
end;

fatal = function(...)
    return API:fatalerror(...);
end;

psuedoOutput = API;
return API;

--[[
    We're going to use Love2D's default physics handler to utilize with our objects, but have to break down how we're going to do it first.
]]
local API = {};
local UniverseToLove = {};

API.BlendObjects = function(self, UniverseObject, LoveObject)
    UniverseToLove[UniverseObject] = LoveObject;
end;

Physics = API;
local run = game:service'RunService';
local plr = game.Players.LocalPlayer;
local char = plr.Character;
local Longsword = char.Longsword;
local Hitbox = Longsword.Hitbox;
local child = Hitbox:children();
_G.rot = 0;
_G.rotChange = .001;
_G.world = false;
local sin, cos = math.sin, math.cos;

local dmgPoints = {};
for i = 1, #child do
    local obj = child[i];
    if (obj:IsA('Attachment') and obj.Name == 'DmgPoint') then
        obj.Visible = true;
        for i = 1, 5 do
            local a = obj:clone();
            a.Parent = obj.Parent;
            table.insert(dmgPoints, a);
        end;
        table.insert(dmgPoints, obj);
    end;
end;

run.RenderStepped:connect(function(dt)
    _G.rot = _G.rot + _G.rotChange;
    for i = 1, #dmgPoints do
        local point = dmgPoints[i];
        local x = 5 * cos(_G.rot * i);
        local y = 5 * sin(_G.rot * i);
        local z = 5 * sin(_G.rot * i);
        if (_G.world == false) then
            point.CFrame = CFrame.new((function() 
                if (_G.x ~= nil) then
                    return _G.x(_G.rot, i);
                end;
            end)() or x, (function() 
                if (_G.y ~= nil) then
                    return _G.y(_G.rot, i);
                end;
            end)() or y, (function() 
                if (_G.z ~= nil) then
                    return _G.z(_G.rot, i);
                end;
            end)() or z);
        elseif (_G.world == true) then
            point.WorldCFrame = CFrame.new((function() 
                if (_G.x ~= nil) then
                    return _G.x(_G.rot, i);
                end;
            end)() or x, (function() 
                if (_G.y ~= nil) then
                    return _G.y(_G.rot, i);
                end;
            end)() or y, (function() 
                if (_G.z ~= nil) then
                    return _G.z(_G.rot, i);
                end;
            end)() or z);
        end;
    end;
end);

--[[

_G.x = function(rot, index)
	local x = rot * index;
	return 5 * math.cos(x);
end;
_G.y = function(rot, index)
	local x = rot * index;
	return 5 * math.sin(x);
end;
_G.z = function(rot, index)
	local x = rot * index;
	return 25 * math.cos(99999 * x);
end;

_G.x = function(rot, index)
    local x = rot * index;
	return math.cos(6 * x);
end;
_G.y = function(rot, index)
    local x = rot * index;
	return index
end;
_G.z = function(rot, index)
    local x = rot * index;
	return math.sin(6 * x);
end;
]]


--[[EFFECT USING WEED FORMULA
local sin, cos, tan = math.sin, math.cos, math.tan;
_G.x = function(rot, index)
    local x = rot * index;
	return (1 + .9 * cos(8 * x)) * (1 + .1 * cos(24 * x)) * (.9 + .05 * cos(200 * x)) * (1 + sin(x));
end;
_G.y = function(rot, index)
    local x = rot * index;
	return index
end;
_G.z = function(rot, index)
    local x = rot * index;
	return (1 + .9 * cos(8 * x)) * (1 + .1 * cos(24 * x)) * (.9 + .05 * cos(200 * x)) * (1 + sin(x));
end;
]]

--[[TITS Formula
local sin, cos, tan = math.sin, math.cos, math.tan;
_G.x = function(rot, index)
    local x = rot * index;
	return (1 + .9 * cos(8 * x)) * (1 + .1 * cos(24 * x)) * (.9 + .05 * cos(200 * x)) * (1 + sin(x));
end;
_G.y = function(rot, index)
    local x = rot * index;
	return (25 - )^(1/3)
end;
_G.z = function(rot, index)
    local x = rot * index;
	return (1 + .9 * cos(8 * x)) * (1 + .1 * cos(24 * x)) * (.9 + .05 * cos(200 * x)) * (1 + sin(x));
end;
]]
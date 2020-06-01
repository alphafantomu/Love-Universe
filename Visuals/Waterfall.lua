
--Runtime for the engine
local API = {};
local MouseCache = {};
local ClassUpdate = {
    {'Mouse', function(MouseObjects)
        local Position = {love.mouse.getPosition();};
        for i = 1, #MouseObjects do
            local Mouse = MouseObjects[i];
            if (MouseCache[1] == Position[1] and MouseCache[2] == Position[2]) then
                Ripple:FireClassRipple('Idle', 'Mouse', unpack(Position));
            end;
            local Hit = Mouse.Hit;
            CustomTypes:forceNewIndex(Hit, 'x', Position[1]);
            CustomTypes:forceNewIndex(Hit, 'y', Position[2]);
            MouseCache[1] = Position[1];
            MouseCache[2] = Position[2];
        end;
	end;};
};

love.update = function(dt) --dt is the change in time
    if (API.TimeChanged ~= nil) then
        Ripple:FireRipple('TimeChanged', dt);
    end;
    Physics:UpdateRenderWorld(dt);
    for i = 1, #ClassUpdate do
        local Data = ClassUpdate[i];
        local Objects = Object:getObjectsByClass(Data[1]);
        Data[2](Objects);
    end;
end;

Waterfall = API;
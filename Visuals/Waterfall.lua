
--Runtime for the engine
local API = {};
local MouseCache = {};
local ClassUpdate = {
    {'Mouse', function(MouseObjects)
        local Position = {love.mouse.getPosition();};
        for i = 1, #MouseObjects do
            local Mouse = MouseObjects[i];
            local Cache = MouseCache[Mouse];
            if (Cache == nil) then Cache = {}; MouseCache[Mouse] = Cache; end;
            if (Cache[1] == Position[1] and Cache[2] == Position[2]) then
                Ripple:FireClassRipple('Idle', 'Mouse', unpack(Position));
            end;
            local Hit = Mouse.Hit;
            CustomTypes:forceNewIndex(Hit, 'x', Position[1]);
            CustomTypes:forceNewIndex(Hit, 'y', Position[2]);
            Cache[1] = Position[1];
            Cache[2] = Position[2];
        end;
	end;};
	{'Keyboard', function(KeyboardObjects)
		local screenboardEnabled = love.keyboard.hasScreenKeyboard();
        for i = 1, #KeyboardObjects do
            local Keyboard = KeyboardObjects[i];
			if (Keyboard.ScreenKeyboardEnabled ~= screenboardEnabled) then
				Object:forceNewIndex(Keyboard, 'ScreenKeyboardEnabled', screenboardEnabled);
			end;
        end;
    end;};
};

love.update = function(dt) --dt is the change in time
    Ripple:FireRipple('TimeChanged', dt);
    for i = 1, #ClassUpdate do
        local Data = ClassUpdate[i];
        local Objects = Object:getObjectsByClass(Data[1]);
        Data[2](Objects);
    end;
end;

Waterfall = API;
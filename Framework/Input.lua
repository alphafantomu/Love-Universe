
local API = {
	Mouse = {};
};

love.keypressed = function(key, scancode, rep)
    if (API.InputDown ~= nil) then
        local ManageRipple = Ripple:ManageRipple('InputDown');
        ManageRipple:FireConnections(key, scancode, rep);
    end;
end;

love.keyreleased = function(key, scancode)
    if (API.InputUp ~= nil) then
		local ManageRipple = Ripple:ManageRipple('InputUp');
        ManageRipple:FireConnections(key, scancode);
    end;
end;

love.mousemoved = function(x, y, dx, dy, isTouch) --idle functionality might be hard
	local ManageRipple = Ripple:ManageRipple('Moved');
	if (ManageRipple ~= nil) then
		ManageRipple:FireProcessorConnections('Mouse', x, y, dx, dy);
	end;
end;

love.mousepressed = function(x, y, button, isTouch, presses)
	if (button == 1) then
		local Manager = Ripple:ManageRipple('Button1Down');
		if (Manager ~= nil) then
			Manager:FireProcessorConnections('Mouse', x, y, presses);
		end;
	elseif (button == 2) then
		local Manager = Ripple:ManageRipple('Button2Down');
		if (Manager ~= nil) then
			Manager:FireProcessorConnections('Mouse', x, y, presses);
		end;
	end;
	local Manager = Ripple:ManageRipple('ButtonDown');
	if (Manager ~= nil) then
		Manager:FireProcessorConnections('Mouse', x, y, button, presses);
	end;
end;

love.mousereleased = function(x, y, button, isTouch, presses)
    if (button == 1) then
		local Manager = Ripple:ManageRipple('Button1Up');
		if (Manager ~= nil) then
			Manager:FireProcessorConnections('Mouse', x, y, presses);
		end;
	elseif (button == 2) then
		local Manager = Ripple:ManageRipple('Button2Up');
		if (Manager ~= nil) then
			Manager:FireProcessorConnections('Mouse', x, y, presses);
		end;
	end;
	local Manager = Ripple:ManageRipple('ButtonUp');
	if (Manager ~= nil) then
		Manager:FireProcessorConnections('Mouse', x, y, button, presses);
	end;
end;

love.wheelmoved = function(x, y)

end;



Input = API;
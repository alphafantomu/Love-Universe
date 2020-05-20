
local API = {
	Mouse = {};
};

love.touchmoved = function(id, x, y, dx, dy, pressure)
    print('touch moved');
end;

love.touchpressed = function(id, x, y, dx, dy, pressure)
    print('touch pressed');
end;

love.touchreleased = function(id, x, y, dx, dy, pressure)
    print('touch released');
end;

love.keypressed = function(key, scancode, rep)--
    Ripple:FireClassRipple('InputDown', 'Keyboard', key, scancode, rep);
end;

love.keyreleased = function(key, scancode)--
    Ripple:FireClassRipple('InputUp', 'Keyboard', key, scancode);
end;

love.mousemoved = function(x, y, dx, dy, isTouch) --idle functionality might be hard
    Ripple:FireClassRipple('Moved', 'Mouse', x, y, dx, dy);
end;

love.mousepressed = function(x, y, button, isTouch, presses)
    Ripple:FireClassRipple('ButtonDown', 'Mouse', x, y, button, presses);
end;

love.mousereleased = function(x, y, button, isTouch, presses)
	Ripple:FireClassRipple('ButtonUp', 'Mouse', x, y, button, presses);
end;

love.wheelmoved = function(x, y) --its not possible for x and y to be moved at the same time
    Ripple:FireClassRipple('WheelMoved', 'Mouse', x, y);
end;



Input = API;
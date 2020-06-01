
local API = {};

--Touch operations do infact work on Surface Pro 2015, which means they'll probably work on iPhone as well.
love.touchmoved = function(id, x, y, dx, dy, pressure)
    Ripple:FireClassRipple('Moved', 'Touchscreen', id, x, y, dx, dy, pressure);
end;

love.touchpressed = function(id, x, y, dx, dy, pressure)
    Ripple:FireClassRipple('InputDown', 'Touchscreen', id, x, y, dx, dy, pressure);
end;

love.touchreleased = function(id, x, y, dx, dy, pressure)
    Ripple:FireClassRipple('InputUp', 'Touchscreen', id, x, y, dx, dy, pressure);
end;

love.textinput = function(t)
    Ripple:FireClassRipple('InputTyped', 'Keyboard', t);
end;

love.textedited = function(text, start, length) --NO CLUE HOW TO USE THIS
    --print(text, start, length);
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
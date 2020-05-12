
local API = {};

local Image = Application:loadImage('Assets/Ishtar Avenger 4.png');

love.draw = function()
    love.graphics.draw(Image, love.mouse.getPosition());
    --love.graphics.rectangle("fill", 20, 50, 60, 120 )
    love.graphics.print(love.timer.getFPS(), 20, 50);
end;

Drawing = API;
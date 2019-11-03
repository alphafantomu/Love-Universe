
local psuedoWorkspace = psuedoWorkspace;
local psuedoObjects = psuedoObjects;

function love.draw()
    local CurrentStack = psuedoWorkspace:getStack();
    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') then
            love.graphics.push();
            love.graphics.rotate(actualObject.Rotation);
            love.graphics.setColor(actualObject.Color.r, actualObject.Color.g, actualObject.Color.b, 255);
            love.graphics.rectangle(actualObject.Type, actualObject.Position.x, actualObject.Position.y, actualObject.Size.x, actualObject.Size.y);
            love.graphics.pop();
        end;
    end;
end;
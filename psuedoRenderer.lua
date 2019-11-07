
local psuedoWorkspace = psuedoWorkspace;
local psuedoObjects = psuedoObjects;

text = '';

function love.draw()
    local height, width = love.graphics.getDimensions();
    for y = 1, height, 10 do
        for x = 1, width, 10 do
            local coords = getSpaceCoordinates(spacedOccupied, {x, y});
            if (coords == nil) then
                love.graphics.print('0', x, y);
            elseif (coords ~= nil) then
                love.graphics.print('1', x, y);
            end;
        end;
    end;
    --love.graphics.print(text, 0, 0);
    spacedOccupied = {};
    collectgarbage();
    --[[if (BlockA and BlockB) then
        local pos1, size1 = BlockA.Position, BlockA.Size;
        local pos2, size2 = BlockB.Position, BlockB.Size;
        love.graphics.print('top:'..tostring(pos2.y - pos1.y), 0, 0);
        love.graphics.print('bottom:'..tostring((pos2.y + size1.y)-(pos1.y + size1.y)), 100, 0);
        love.graphics.print('left:'..tostring(pos2.x - pos1.x), 200, 0);
        love.graphics.print('right:'..tostring((pos2.x + size2.x) - (pos1.x + size1.x)), 300, 0);
    end;]]
    local CurrentStack = psuedoWorkspace:getStack();
    for i, v in next, CurrentStack do
        local actualObject = v.__object;
        if (actualObject.ClassName == 'Block') then
            if (actualObject.Parent ~= nil and actualObject.Parent:IsA('Space') == true) then
                love.graphics.push();
                love.graphics.rotate(actualObject.Rotation);
                love.graphics.setColor(actualObject.Color.r, actualObject.Color.g, actualObject.Color.b, 255);
                love.graphics.rectangle(actualObject.Type, actualObject.Position.x, actualObject.Position.y, actualObject.Size.x, actualObject.Size.y);
                love.graphics.pop();
                analyzeBlock(actualObject);
            end;
        end;
    end;
end;
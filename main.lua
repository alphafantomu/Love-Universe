
local psuedoLife = require('psuedoWorkspace');

local World = psuedoLife.CurrentWorld;
local Http = World:GetUtility('Http');
local Space = World:GetUtility('Space');
local Block, Block2;
function love.load()
Block = psuedoLife:newObject('Block', Space);
--Block2 = psuedoLife:newObject('Block');
-- Load some default values for our rectangle.
--print(Http:Post('http://alphaorigin.xyz/lol.php', 'test'))
-- Increase the size of the rectangle every frame.
Block.Name = 'Lol';
Block.Parent = Space;
--Block2.Color.g = 255;
--Block2.Type = 'line';
--print(Block.Type, Block2.Type)
end;

function love.update(dt) --seems to be a loop
    Block.Type = 'fill'
    Block.Position.x = Block.Position.x + 1;
    --Block2.Position.x = Block2.Position.x + 5;
end
-- Draw a coloured rectangle.


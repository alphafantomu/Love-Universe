
--[[
    The system is similar to roblox's tree system. But here are some differences:
    Goes beyond just one server, you can actually create multiple "worlds".
    Instead of game:GetService you do World:GetUtility
    Types like vectors, color etc, you can edit individual properties instead of instancing a new one, saves memory dude
    Love Engine does not support colored outputs in dev console

    Need to improve vectors, colors, etc, add magnitude to vectors
    Add the ability of matrices AFTER YOU LEARN LINEAR ALGEBRA
    Add events and functionality for callbacks
    
    Added EditModes 0, 1, 2, and 3
    Fixed objects parenting to themselves
    Added ability to readd services to worlds, and remove services
]]

local psuedoOutput = require('psuedoOutput');
local psuedoObjects = require('psuedoObjects');
local psuedoPhysics = require('psuedoPhysics');
local psuedoLife = require('psuedoWorkspace');
local psuedoRenderer = require('psuedoRenderer');

local CurrentWorld = psuedoLife.CurrentWorld;
local Http = CurrentWorld:GetUtility('Http');
local Space = CurrentWorld:GetUtility('Space');

local Block;

local Signal = Block.Touched:connect(function()

end)
function love.load(args) --although this is called exactly at the beginning of the game, the rest of the game code outside runs first.
    table.foreach(args, print);
end;

function love.update(dt) --seems to be a loop, this is equivalent to runtime except it's more of a 2d runtime env rather than a 3d runtime env
   -- Block.Position.x = Block.Position.x + .01;
    --[[Block2.Position.y = Block2.Position.y + 1;
    Block3.Position.x = Block3.Position.x + 1;
    Block3.Position.y = Block3.Position.y + 1;]]
    --love.timer.sleep(60);
    --Block.Rotation = Block.Rotation + .001;
    --print(Block.Rotation);
    --print(Block.Rotation);
    --print(Block.Position == Block2.Position);
    --print(Block.Position.x, Block2.Position.x, Block.Position.x == Block2.Position.x)
    --Block2.Position.y = Block2.Position.y + 1;
    --[[Block.Type = 'fill'
    Block.Position.x = Block.Position.x + 1;
    Block2.Position.x = Block2.Position.x + 5;]]
end
-- Draw a coloured rectangle.
